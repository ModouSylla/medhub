// ============================================================
// consultation_provider.dart – Gestion d'état : consultations
// ============================================================
import 'package:flutter/material.dart';
import '../repositories/consultation_repository.dart';
import '../repositories/constante_repository.dart';
import '../repositories/definition_constante_repository.dart';
import '../repositories/patient_repository.dart';
import '../models/consultation.dart';
import '../models/constante_consultation.dart';
import '../models/definition_constante.dart';
import '../services/notification_service.dart';
import '../utils/date_utils.dart';
import '../utils/exceptions.dart';

class ConsultationProvider extends ChangeNotifier {
  final ConsultationRepository     _repoConsult   = ConsultationRepository();
  final ConstanteRepository        _repoConstante = ConstanteRepository();
  final DefinitionConstanteRepository _repoDef    = DefinitionConstanteRepository();
  final PatientRepository          _repoPatient   = PatientRepository();
  final NotificationService        _notifs        = NotificationService();

  List<Consultation>         _consultations        = [];
  List<DefinitionConstante>  _definitions          = [];
  bool                       _enChargement         = false;
  String?                    _messageErreur;

  List<Consultation>        get consultations    => _consultations;
  List<DefinitionConstante> get definitions      => _definitions;
  bool                      get enChargement     => _enChargement;
  String?                   get messageErreur    => _messageErreur;

  Future<void> chargerConsultations(int idPatient) async {
    _enChargement = true;
    notifyListeners();
    try {
      _consultations = await _repoConsult.obtenirConsultationsPatient(idPatient);
    } catch (e) {
      _messageErreur = e is RepositoryException
          ? e.message
          : "Erreur lors du chargement de l'historique.";
    } finally {
      _enChargement = false;
      notifyListeners();
    }
  }

  Future<void> chargerDefinitions(String profilMedical) async {
    try {
      _definitions = await _repoDef.obtenirDefinitionsParProfil(profilMedical);
      notifyListeners();
    } catch (e) {
      _messageErreur = e is RepositoryException
          ? e.message
          : 'Erreur lors du chargement des constantes.';
      notifyListeners();
    }
  }

  Future<bool> enregistrerConsultation(
    Consultation consultation,
    List<ConstanteConsultation> constantes,
  ) async {
    _enChargement = true;
    notifyListeners();

    try {
      final Consultation avecDate = consultation.copierAvec(
        dateCreation: AppDateUtils.maintenant(),
      );

      final int idConsultation =
          await _repoConsult.insererConsultation(avecDate);

      final List<ConstanteConsultation> constantesAvecId = constantes
          .where((c) => c.valeur.trim().isNotEmpty)
          .map((c) => ConstanteConsultation(
                idConsultation: idConsultation,
                idDefinition:   c.idDefinition,
                valeur:         c.valeur,
              ))
          .toList();

      await _repoConstante.insererConstantes(constantesAvecId);
      await chargerConsultations(consultation.idPatient);

      // Notification push immédiate si un rappel urgent est demandé
      // sur cette consultation (cahier des charges §19.2, BF-06.3).
      if (avecDate.rappelUrgent) {
        await _notifierRappelUrgent(avecDate.idPatient);
      }

      // Le nombre d'examens en attente a pu changer : on reprogramme
      // le rappel quotidien avec le compte à jour (§19.2, BF-06.2).
      await _reprogrammerRappelExamen();

      return true;
    } catch (e) {
      _messageErreur = e is RepositoryException
          ? e.message
          : "Erreur lors de l'enregistrement de la consultation.";
      return false;
    } finally {
      _enChargement = false;
      notifyListeners();
    }
  }

  Future<List<ConstanteConsultation>> obtenirConstantes(
    int idConsultation,
  ) async {
    try {
      final List<ConstanteConsultation> constantes =
          await _repoConstante.obtenirConstantesConsultation(idConsultation);
      for (final c in constantes) {
        if (_definitions.isNotEmpty) {
          c.definition = _definitions.firstWhere(
            (d) => d.idDefinition == c.idDefinition,
            orElse: () => DefinitionConstante(
              libelle: 'Constante',
              typeValeur: 'texte',
              profilMedical: '',
            ),
          );
        }
      }
      return constantes;
    } catch (e) {
      _messageErreur = e is RepositoryException
          ? e.message
          : 'Erreur lors du chargement des constantes de la consultation.';
      notifyListeners();
      return [];
    }
  }

  /// Active/désactive le rappel urgent d'un patient directement depuis
  /// sa fiche (cahier des charges §16.6, BF-04.4), sans passer par la
  /// création d'une nouvelle consultation.
  ///
  /// Met à jour le flag sur l'ensemble des consultations du patient et
  /// déclenche une notification push immédiate lorsqu'on active le
  /// rappel.
  Future<bool> basculerRappelUrgent(
    int idPatient,
    String nomPatient,
    bool valeur,
  ) async {
    try {
      await _repoConsult.mettreAJourFlagUrgent(idPatient, valeur);

      _consultations = _consultations
          .map((c) => c.idPatient == idPatient
              ? c.copierAvec(rappelUrgent: valeur)
              : c)
          .toList();
      notifyListeners();

      if (valeur) {
        await _notifs.envoyerNotificationUrgence(
          'Rappel urgent',
          '$nomPatient doit être rappelé en urgence.',
          payload: 'urgence:$idPatient',
        );
      }
      return true;
    } catch (e) {
      _messageErreur = e is RepositoryException
          ? e.message
          : 'Erreur lors de la mise à jour du rappel urgent.';
      notifyListeners();
      return false;
    }
  }

  /// Envoie la notification push "rappel urgent" pour un patient donné.
  Future<void> _notifierRappelUrgent(int idPatient) async {
    try {
      final patient = await _repoPatient.obtenirPatientParId(idPatient);
      if (patient == null) return;
      await _notifs.envoyerNotificationUrgence(
        'Rappel urgent',
        '${patient.obtenirNomComplet()} doit être rappelé en urgence.',
        payload: 'urgence:$idPatient',
      );
    } catch (_) {
      // Une notification manquée ne doit jamais faire échouer
      // l'enregistrement de la consultation elle-même.
    }
  }

  /// Recalcule le nombre d'examens en attente et reprogramme (ou
  /// annule) le rappel quotidien correspondant.
  Future<void> _reprogrammerRappelExamen() async {
    try {
      final ids = await _repoConsult.obtenirIdsExamenEnAttente();
      await _notifs.planifierRappelExamen(ids.length);
    } catch (_) {
      // Idem : ne doit jamais faire échouer l'action principale.
    }
  }

  /// Marque un examen comme reçu (§ ticket BF : clôture du badge
  /// "Examen en attente" depuis l'écran de détail de la consultation).
  /// Met également à jour la consultation en mémoire et reprogramme
  /// le rappel quotidien avec le nombre d'examens encore en attente.
  Future<bool> marquerExamenRecu(int idConsultation, int idPatient) async {
    try {
      await _repoConsult.mettreAJourFlagExamen(idConsultation, false);

      _consultations = _consultations
          .map((c) => c.idConsultation == idConsultation
              ? c.copierAvec(examenEnAttente: false)
              : c)
          .toList();
      notifyListeners();

      await _reprogrammerRappelExamen();
      return true;
    } catch (e) {
      _messageErreur = e is RepositoryException
          ? e.message
          : "Impossible de mettre à jour l'examen.";
      notifyListeners();
      return false;
    }
  }

  void effacerErreur() {
    _messageErreur = null;
    notifyListeners();
  }
}
