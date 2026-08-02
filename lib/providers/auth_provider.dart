// ============================================================
// auth_provider.dart – Gestion de l'authentification PIN
// ============================================================
import 'package:flutter/material.dart';
import '../repositories/profil_medecin_repository.dart';
import '../services/auth_service.dart';
import '../models/profil_medecin.dart';
import '../utils/date_utils.dart';
import '../utils/exceptions.dart';

class AuthProvider extends ChangeNotifier {
  final ProfilMedecinRepository _repo = ProfilMedecinRepository();
  final AuthService _auth = AuthService();

  bool     _estDebloque         = false;
  int      _tentativesRestantes = 5;
  bool     _estVerrouille       = false;
  int      _minutesVerrouillage = 0;
  String?  _messageErreur;

  bool    get estDebloque          => _estDebloque;
  int     get tentativesRestantes  => _tentativesRestantes;
  bool    get estVerrouille        => _estVerrouille;
  int     get minutesVerrouillage  => _minutesVerrouillage;
  String? get messageErreur        => _messageErreur;

  Future<void> verifierEtatVerrouillage() async {
    try {
      final ProfilMedecin? profil = await _repo.obtenirProfil();
      if (profil == null) return;

      if (profil.estVerrouillee()) {
        _estVerrouille       = true;
        _minutesVerrouillage = profil.minutesRestantesVerrouillage();
        _tentativesRestantes = 0;
      } else if (profil.tentativesEchouees >= 5) {
        await _repo.reinitialiserTentatives();
        _estVerrouille       = false;
        _tentativesRestantes = 5;
      } else {
        _tentativesRestantes = 5 - profil.tentativesEchouees;
      }
    } catch (e) {
      _messageErreur = e is RepositoryException
          ? e.message
          : "Impossible de vérifier l'état de sécurité de l'application.";
    }
    notifyListeners();
  }

  Future<bool> verifierPin(String pinSaisi) async {
    _messageErreur = null;

    try {
      final ProfilMedecin? profil = await _repo.obtenirProfil();
      if (profil == null) return false;

      if (profil.estVerrouillee()) {
        _estVerrouille       = true;
        _minutesVerrouillage = profil.minutesRestantesVerrouillage();
        notifyListeners();
        return false;
      }

      final bool pinCorrect = _auth.verifierPin(pinSaisi, profil.codePinHash);

      if (pinCorrect) {
        await _repo.reinitialiserTentatives();
        _estDebloque         = true;
        _estVerrouille       = false;
        _tentativesRestantes = 5;
        _messageErreur       = null;
      } else {
        await _repo.incrementerTentatives();
        final ProfilMedecin? profilMaj = await _repo.obtenirProfil();
        final int tentatives = profilMaj?.tentativesEchouees ?? 0;

        if (tentatives >= 5) {
          await _repo.enregistrerVerrouillage(AppDateUtils.maintenant());
          _estVerrouille       = true;
          _minutesVerrouillage = 5;
          _tentativesRestantes = 0;
        } else {
          _tentativesRestantes = 5 - tentatives;
          _messageErreur =
              'PIN incorrect. $_tentativesRestantes tentative(s) restante(s).';
        }
      }

      notifyListeners();
      return pinCorrect;
    } catch (e) {
      _messageErreur = e is RepositoryException
          ? e.message
          : 'Impossible de vérifier le code PIN.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> definirPin(String pin, ProfilMedecin profil) async {
    try {
      final String hash = _auth.hasherPin(pin);
      final ProfilMedecin profilAvecPin = profil.copierAvec(codePinHash: hash);
      await _repo.insererProfil(profilAvecPin);
      _estDebloque = true;
      _messageErreur = null;
      notifyListeners();
      return true;
    } catch (e) {
      _messageErreur = e is RepositoryException
          ? e.message
          : "Impossible d'enregistrer le code PIN.";
      notifyListeners();
      return false;
    }
  }

  Future<bool> changerPin(String ancienPin, String nouveauPin) async {
    try {
      final ProfilMedecin? profil = await _repo.obtenirProfil();
      if (profil == null) return false;

      if (!_auth.verifierPin(ancienPin, profil.codePinHash)) {
        _messageErreur = 'Ancien PIN incorrect.';
        notifyListeners();
        return false;
      }

      await _repo.mettreAJourPin(_auth.hasherPin(nouveauPin));
      _messageErreur = null;
      notifyListeners();
      return true;
    } catch (e) {
      _messageErreur = e is RepositoryException
          ? e.message
          : 'Impossible de modifier le code PIN.';
      notifyListeners();
      return false;
    }
  }

  void seDeconnecter() {
    _estDebloque = false;
    notifyListeners();
  }
}
