// ============================================================
// profil_medecin_repository.dart – Accès aux données : profil
//
// Chaque méthode est encapsulée dans un try/catch (§20.2 du cahier
// des charges) : toute erreur SQLite est convertie en
// RepositoryException avec un message lisible pour l'utilisateur.
// ============================================================
import 'package:flutter/foundation.dart';
import '../database/base_de_donnees.dart';
import '../models/profil_medecin.dart';
import '../utils/exceptions.dart';

class ProfilMedecinRepository {
  final BaseDeDonnees _bdd = BaseDeDonnees();

  /// Insère le profil initial du médecin.
  Future<int> insererProfil(ProfilMedecin profil) async {
    try {
      final db = await _bdd.obtenirBase();
      return await db.insert('profil_medecin', profil.versMap());
    } catch (e) {
      debugPrint('Erreur insererProfil: $e');
      throw RepositoryException(
        "Impossible d'enregistrer le profil. Veuillez réessayer.",
        causeTechnique: e,
      );
    }
  }

  /// Retourne l'unique profil médecin stocké en base.
  /// Retourne null si aucun profil n'est configuré.
  Future<ProfilMedecin?> obtenirProfil() async {
    try {
      final db = await _bdd.obtenirBase();
      final List<Map<String, dynamic>> lignes = await db.query(
        'profil_medecin',
        limit: 1,
      );
      if (lignes.isEmpty) return null;
      return ProfilMedecin.depuisMap(lignes.first);
    } catch (e) {
      debugPrint('Erreur obtenirProfil: $e');
      throw RepositoryException(
        'Impossible de charger le profil du médecin.',
        causeTechnique: e,
      );
    }
  }

  /// Met à jour le profil du médecin.
  Future<int> mettreAJourProfil(ProfilMedecin profil) async {
    try {
      final db = await _bdd.obtenirBase();
      return await db.update(
        'profil_medecin',
        profil.versMap(),
        where: 'id_profil = ?',
        whereArgs: [profil.idProfil],
      );
    } catch (e) {
      debugPrint('Erreur mettreAJourProfil: $e');
      throw RepositoryException(
        'Impossible de modifier le profil du médecin.',
        causeTechnique: e,
      );
    }
  }

  /// Met à jour uniquement le hash du code PIN.
  Future<int> mettreAJourPin(String nouveauHash) async {
    try {
      final db = await _bdd.obtenirBase();
      return await db.rawUpdate(
        'UPDATE profil_medecin SET code_pin_hash = ?, tentatives_echouees = 0',
        [nouveauHash],
      );
    } catch (e) {
      debugPrint('Erreur mettreAJourPin: $e');
      throw RepositoryException(
        'Impossible de modifier le code PIN.',
        causeTechnique: e,
      );
    }
  }

  /// Incrémente le compteur de tentatives PIN incorrectes.
  Future<int> incrementerTentatives() async {
    try {
      final db = await _bdd.obtenirBase();
      return await db.rawUpdate(
        'UPDATE profil_medecin SET tentatives_echouees = tentatives_echouees + 1',
      );
    } catch (e) {
      debugPrint('Erreur incrementerTentatives: $e');
      throw RepositoryException(
        'Une erreur est survenue lors de la vérification du PIN.',
        causeTechnique: e,
      );
    }
  }

  /// Remet le compteur de tentatives à zéro (après succès PIN).
  Future<int> reinitialiserTentatives() async {
    try {
      final db = await _bdd.obtenirBase();
      return await db.rawUpdate(
        'UPDATE profil_medecin SET tentatives_echouees = 0, date_verrouillage = NULL',
      );
    } catch (e) {
      debugPrint('Erreur reinitialiserTentatives: $e');
      throw RepositoryException(
        'Une erreur est survenue lors de la vérification du PIN.',
        causeTechnique: e,
      );
    }
  }

  /// Enregistre la date et heure du début du verrouillage.
  Future<int> enregistrerVerrouillage(String dateHeure) async {
    try {
      final db = await _bdd.obtenirBase();
      return await db.rawUpdate(
        'UPDATE profil_medecin SET date_verrouillage = ?',
        [dateHeure],
      );
    } catch (e) {
      debugPrint('Erreur enregistrerVerrouillage: $e');
      throw RepositoryException(
        "Impossible de verrouiller l'application.",
        causeTechnique: e,
      );
    }
  }
}
