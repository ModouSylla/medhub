// ============================================================
// profil_provider.dart – Gestion d'état : profil médecin
// ============================================================
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/profil_medecin_repository.dart';
import '../models/profil_medecin.dart';
import '../utils/exceptions.dart';

class ProfilProvider extends ChangeNotifier {
  final ProfilMedecinRepository _repo = ProfilMedecinRepository();

  static const String _cleConfigEffectuee = 'configuration_effectuee';

  ProfilMedecin? _profil;
  bool           _enChargement = false;
  String?        _messageErreur;

  ProfilMedecin? get profil        => _profil;
  bool           get enChargement  => _enChargement;
  String?        get messageErreur => _messageErreur;

  /// Charge le profil médecin depuis la base.
  Future<void> chargerProfil() async {
    _enChargement = true;
    _messageErreur = null;
    notifyListeners();
    try {
      _profil = await _repo.obtenirProfil();
    } catch (e) {
      _messageErreur = e is RepositoryException
          ? e.message
          : 'Impossible de charger le profil du médecin.';
    } finally {
      _enChargement = false;
      notifyListeners();
    }
  }

  /// Sauvegarde le profil (insertion ou mise à jour).
  Future<bool> sauvegarderProfil(ProfilMedecin profil) async {
    try {
      if (profil.idProfil == null) {
        await _repo.insererProfil(profil);
      } else {
        await _repo.mettreAJourProfil(profil);
      }
      _profil = await _repo.obtenirProfil();
      notifyListeners();
      return true;
    } catch (e) {
      _messageErreur = e is RepositoryException
          ? e.message
          : 'Impossible d\'enregistrer le profil.';
      notifyListeners();
      return false;
    }
  }

  /// Vérifie si la configuration initiale a été effectuée.
  Future<bool> estPremiereLancement() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_cleConfigEffectuee) ?? false);
  }

  /// Marque la configuration comme effectuée dans les préférences.
  Future<void> marquerConfigurationEffectuee() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_cleConfigEffectuee, true);
  }

  void effacerErreur() {
    _messageErreur = null;
    notifyListeners();
  }
}
