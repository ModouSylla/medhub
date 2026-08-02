// ============================================================
// patient_provider.dart – Gestion d'état : patients
// ============================================================
import 'package:flutter/material.dart';
import '../repositories/patient_repository.dart';
import '../models/patient.dart';
import '../utils/date_utils.dart';
import '../utils/exceptions.dart';

class PatientProvider extends ChangeNotifier {
  final PatientRepository _repo = PatientRepository();

  List<Patient> _listePatients         = [];
  List<Patient> _listePatientsFiltree  = [];
  List<Patient> _listePatientsArchives = [];
  Patient?      _patientSelectionne;
  bool          _enChargement          = false;
  bool          _enChargementArchives  = false;
  String?       _messageErreur;
  bool          _doublon               = false;

  List<Patient> get listePatients         => _listePatientsFiltree;
  List<Patient> get listePatientsArchives => _listePatientsArchives;
  Patient?      get patientSelectionne    => _patientSelectionne;
  bool          get enChargement          => _enChargement;
  bool          get enChargementArchives  => _enChargementArchives;
  String?       get messageErreur         => _messageErreur;
  bool          get doublon               => _doublon;

  Future<void> chargerPatients() async {
    _enChargement = true;
    _messageErreur = null;
    notifyListeners();
    try {
      _listePatients        = await _repo.obtenirTousLesPatients();
      _listePatientsFiltree = List.from(_listePatients);
    } catch (e) {
      _messageErreur = e is RepositoryException
          ? e.message
          : 'Erreur lors du chargement des patients.';
    } finally {
      _enChargement = false;
      notifyListeners();
    }
  }

  Future<void> rechercherPatients(String terme) async {
    if (terme.trim().isEmpty) {
      _listePatientsFiltree = List.from(_listePatients);
      notifyListeners();
      return;
    }
    try {
      _listePatientsFiltree = await _repo.rechercherPatients(terme);
    } catch (e) {
      _messageErreur = e is RepositoryException
          ? e.message
          : 'Erreur lors de la recherche.';
    }
    notifyListeners();
  }

  Future<void> verifierDoublon(String nom, String telephone) async {
    try {
      _doublon = await _repo.verifierDoublon(nom, telephone);
    } catch (e) {
      _messageErreur = e is RepositoryException
          ? e.message
          : 'Erreur lors de la vérification du doublon.';
      _doublon = false;
    }
    notifyListeners();
  }

  Future<bool> inscrirePatient(Patient patient) async {
    _enChargement = true;
    _messageErreur = null;
    notifyListeners();
    try {
      final Patient avecDate = patient.copierAvec(
        dateCreation: AppDateUtils.maintenant(),
      );
      final int idGenere = await _repo.insererPatient(avecDate);
      if (idGenere > 0) {
        await chargerPatients();
        return true;
      }
      return false;
    } catch (e) {
      _messageErreur = e is RepositoryException
          ? e.message
          : "Erreur lors de l'inscription du patient.";
      return false;
    } finally {
      _enChargement = false;
      notifyListeners();
    }
  }

  Future<bool> mettreAJourPatient(Patient patient) async {
    try {
      await _repo.mettreAJourPatient(patient);
      final int index = _listePatients.indexWhere((p) => p.idPatient == patient.idPatient);
      if (index >= 0) {
        _listePatients[index] = patient;
        _listePatientsFiltree = List.from(_listePatients);
      }
      if (_patientSelectionne?.idPatient == patient.idPatient) {
        _patientSelectionne = patient;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _messageErreur = e is RepositoryException
          ? e.message
          : 'Erreur lors de la mise à jour.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> archiverPatient(int idPatient) async {
    try {
      await _repo.archiverPatient(idPatient);
      _listePatients.removeWhere((p) => p.idPatient == idPatient);
      _listePatientsFiltree = List.from(_listePatients);
      notifyListeners();
      return true;
    } catch (e) {
      _messageErreur = e is RepositoryException
          ? e.message
          : "Erreur lors de l'archivage.";
      notifyListeners();
      return false;
    }
  }

  /// Charge la liste des patients archivés (dossiers désactivés mais
  /// dont les données sont conservées).
  Future<void> chargerPatientsArchives() async {
    _enChargementArchives = true;
    _messageErreur = null;
    notifyListeners();
    try {
      _listePatientsArchives = await _repo.obtenirPatientsArchives();
    } catch (e) {
      _messageErreur = e is RepositoryException
          ? e.message
          : 'Erreur lors du chargement des patients archivés.';
    } finally {
      _enChargementArchives = false;
      notifyListeners();
    }
  }

  /// Désarchive un patient : le dossier redevient visible dans la
  /// liste principale et est retiré de la liste des archives.
  Future<bool> desarchiverPatient(int idPatient) async {
    try {
      await _repo.desarchiverPatient(idPatient);
      _listePatientsArchives.removeWhere((p) => p.idPatient == idPatient);
      notifyListeners();
      return true;
    } catch (e) {
      _messageErreur = e is RepositoryException
          ? e.message
          : 'Erreur lors du désarchivage.';
      notifyListeners();
      return false;
    }
  }

  Future<void> selectionnerPatient(int idPatient) async {
    try {
      _patientSelectionne = await _repo.obtenirPatientParId(idPatient);
    } catch (e) {
      _messageErreur = e is RepositoryException
          ? e.message
          : 'Erreur lors du chargement de la fiche patient.';
    }
    notifyListeners();
  }

  void effacerSelection() {
    _patientSelectionne = null;
    notifyListeners();
  }

  void effacerErreur() {
    _messageErreur = null;
    notifyListeners();
  }
}
