// ============================================================
// agenda_provider.dart – Gestion d'état : agenda
// ============================================================
import 'package:flutter/material.dart';
import '../repositories/rendez_vous_repository.dart';
import '../repositories/patient_repository.dart';
import '../models/rendez_vous.dart';
import '../services/notification_service.dart';
import '../utils/date_utils.dart';
import '../utils/exceptions.dart';

class AgendaProvider extends ChangeNotifier {
  final RendezVousRepository _repoRdv     = RendezVousRepository();
  final PatientRepository    _repoPatient = PatientRepository();
  final NotificationService  _notifs      = NotificationService();

  List<RendezVous> _rdvJour    = [];
  List<RendezVous> _rdvSemaine = [];
  DateTime         _dateSelectionnee = DateTime.now();
  bool             _enChargement     = false;
  String?          _messageErreur;

  List<RendezVous> get rdvJour          => _rdvJour;
  List<RendezVous> get rdvSemaine       => _rdvSemaine;
  DateTime         get dateSelectionnee => _dateSelectionnee;
  bool             get enChargement     => _enChargement;
  String?          get messageErreur    => _messageErreur;

  Future<void> chargerRdvJour(DateTime date) async {
    _dateSelectionnee = date;
    _enChargement     = true;
    notifyListeners();
    try {
      _rdvJour = await _repoRdv.obtenirRdvDuJour(AppDateUtils.dateVersIso(date));
      await _enrichirAvecNomPatients(_rdvJour);
    } catch (e) {
      _messageErreur = e is RepositoryException
          ? e.message
          : "Erreur lors du chargement de l'agenda.";
    } finally {
      _enChargement = false;
      notifyListeners();
    }
  }

  Future<void> chargerRdvSemaine(DateTime dateQuelconque) async {
    _enChargement = true;
    notifyListeners();
    try {
      final String debut = AppDateUtils.debutDeSemaine(dateQuelconque);
      final String fin   = AppDateUtils.finDeSemaine(dateQuelconque);
      _rdvSemaine = await _repoRdv.obtenirRdvSemaine(debut, fin);
      await _enrichirAvecNomPatients(_rdvSemaine);
    } catch (e) {
      _messageErreur = e is RepositoryException
          ? e.message
          : "Erreur lors du chargement de l'agenda.";
    } finally {
      _enChargement = false;
      notifyListeners();
    }
  }

  Future<bool> creerRendezVous(RendezVous rdv) async {
    _enChargement = true;
    notifyListeners();
    try {
      final RendezVous rdvAvecDate =
          rdv.copierAvec(dateCreation: AppDateUtils.maintenant());
      final int idRdv = await _repoRdv.insererRendezVous(rdvAvecDate);

      if (!rdv.estBlocage && rdv.idPatient != null) {
        final nomPatient = rdv.nomPatient ?? 'Patient';
        final DateTime dateRdv = _parseDateHeure(rdv.dateHeure, rdv.heureDebut);
        final DateTime heureNotif = dateRdv.subtract(const Duration(minutes: 30));
        final int idNotif = await _notifs.planifierRappelRdv(
          heureNotif,
          'Rappel rendez-vous',
          'RDV avec $nomPatient à ${rdv.heureDebut}',
          'rdv:$idRdv',
        );
        if (idNotif > 0) {
          await _repoRdv.mettreAJourIdNotification(idRdv, idNotif);
        }
      }

      await chargerRdvJour(_dateSelectionnee);
      return true;
    } catch (e) {
      _messageErreur = e is RepositoryException
          ? e.message
          : 'Erreur lors de la création du rendez-vous.';
      return false;
    } finally {
      _enChargement = false;
      notifyListeners();
    }
  }

  Future<bool> modifierRendezVous(RendezVous rdv) async {
    try {
      if (rdv.idNotification != null) {
        await _notifs.annulerNotification(rdv.idNotification!);
      }
      await _repoRdv.mettreAJourRendezVous(rdv);
      await chargerRdvJour(_dateSelectionnee);
      return true;
    } catch (e) {
      _messageErreur = e is RepositoryException
          ? e.message
          : 'Erreur lors de la modification.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> annulerRendezVous(int idRdv, int? idNotification) async {
    try {
      if (idNotification != null) {
        await _notifs.annulerNotification(idNotification);
      }
      await _repoRdv.changerStatutRdv(idRdv, StatutRendezVous.annule);
      await chargerRdvJour(_dateSelectionnee);
      return true;
    } catch (e) {
      _messageErreur = e is RepositoryException
          ? e.message
          : "Erreur lors de l'annulation.";
      notifyListeners();
      return false;
    }
  }

  Future<List<RendezVous>> verifierConflits(
    String date,
    String heureDebut,
    String heureFin, {
    int? excludeId,
  }) async {
    try {
      return await _repoRdv.verifierConflitHoraire(
        date,
        heureDebut,
        heureFin,
        excludeId: excludeId,
      );
    } catch (e) {
      _messageErreur = e is RepositoryException
          ? e.message
          : 'Impossible de vérifier les conflits de créneaux.';
      notifyListeners();
      return [];
    }
  }

  Future<void> _enrichirAvecNomPatients(List<RendezVous> liste) async {
    for (final rdv in liste) {
      if (rdv.idPatient != null && rdv.nomPatient == null) {
        final patient = await _repoPatient.obtenirPatientParId(rdv.idPatient!);
        if (patient != null) {
          rdv.nomPatient = patient.obtenirNomComplet();
        }
      }
    }
  }

  void effacerErreur() {
    _messageErreur = null;
    notifyListeners();
  }

  DateTime _parseDateHeure(String date, String heure) {
    final List<String> pd = date.split('-');
    final List<String> ph = heure.split(':');
    return DateTime(int.parse(pd[0]), int.parse(pd[1]), int.parse(pd[2]),
        int.parse(ph[0]), int.parse(ph[1]));
  }
}
