// ============================================================
// patient_repository.dart – Accès aux données : patients
//
// Toutes les opérations CRUD sur la table 'patients'.
// Traduit les opérations métier en requêtes SQL via sqflite.
//
// Conformément au cahier des charges (§20.2), chaque méthode est
// encapsulée dans un try/catch : toute erreur SQLite est convertie
// en RepositoryException avec un message lisible pour l'utilisateur.
// ============================================================
import 'package:diacritic/diacritic.dart';
import 'package:flutter/foundation.dart';
import '../database/base_de_donnees.dart';
import '../models/patient.dart';
import '../utils/exceptions.dart';

class PatientRepository {
  /// Instance de la base de données (Singleton).
  final BaseDeDonnees _bdd = BaseDeDonnees();

  // ──────────────────────────────────────────────────────────
  // CRÉATION
  // ──────────────────────────────────────────────────────────

  /// Insère un nouveau patient et retourne son id généré.
  Future<int> insererPatient(Patient patient) async {
    try {
      final db = await _bdd.obtenirBase();
      return await db.insert('patients', patient.versMap());
    } catch (e) {
      debugPrint('Erreur insererPatient: $e');
      throw RepositoryException(
        "Impossible d'enregistrer le patient. Veuillez réessayer.",
        causeTechnique: e,
      );
    }
  }

  // ──────────────────────────────────────────────────────────
  // LECTURE
  // ──────────────────────────────────────────────────────────

  /// Retourne tous les patients actifs (non archivés), triés par nom.
  Future<List<Patient>> obtenirTousLesPatients() async {
    try {
      final db = await _bdd.obtenirBase();
      final List<Map<String, dynamic>> lignes = await db.query(
        'patients',
        where: 'est_archive = ?',
        whereArgs: [0], // 0 = actif
        orderBy: 'nom ASC, prenom ASC',
      );
      // Convertir chaque ligne SQLite en objet Patient
      return lignes.map((ligne) => Patient.depuisMap(ligne)).toList();
    } catch (e) {
      debugPrint('Erreur obtenirTousLesPatients: $e');
      throw RepositoryException(
        'Impossible de charger la liste des patients.',
        causeTechnique: e,
      );
    }
  }

  /// Retourne tous les patients archivés.
  Future<List<Patient>> obtenirPatientsArchives() async {
    try {
      final db = await _bdd.obtenirBase();
      final List<Map<String, dynamic>> lignes = await db.query(
        'patients',
        where: 'est_archive = ?',
        whereArgs: [1],
        orderBy: 'nom ASC, prenom ASC',
      );
      return lignes.map((ligne) => Patient.depuisMap(ligne)).toList();
    } catch (e) {
      debugPrint('Erreur obtenirPatientsArchives: $e');
      throw RepositoryException(
        'Impossible de charger les patients archivés.',
        causeTechnique: e,
      );
    }
  }

  /// Recherche des patients par nom, prénom ou téléphone.
  /// La recherche est insensible à la casse et aux accents.
  Future<List<Patient>> rechercherPatients(String terme) async {
    try {
      if (terme.trim().isEmpty) return obtenirTousLesPatients();

      final db = await _bdd.obtenirBase();
      // Normaliser le terme : minuscules sans accents
      final String termeNormalise = removeDiacritics(terme.toLowerCase());

      // Récupérer tous les patients actifs puis filtrer en mémoire
      // (SQLite LIKE ne gère pas bien les accents français)
      final List<Map<String, dynamic>> lignes = await db.query(
        'patients',
        where: 'est_archive = ?',
        whereArgs: [0],
        orderBy: 'nom ASC, prenom ASC',
      );

      final List<Patient> tous =
          lignes.map((ligne) => Patient.depuisMap(ligne)).toList();

      // Filtrer les patients dont nom, prénom ou téléphone contient le terme
      return tous.where((patient) {
        final String nomNorm    = removeDiacritics(patient.nom.toLowerCase());
        final String prenomNorm = removeDiacritics(patient.prenom.toLowerCase());
        final String tel        = patient.telephone;
        return nomNorm.contains(termeNormalise)   ||
               prenomNorm.contains(termeNormalise) ||
               tel.contains(terme);
      }).toList();
    } on RepositoryException {
      rethrow;
    } catch (e) {
      debugPrint('Erreur rechercherPatients: $e');
      throw RepositoryException(
        'Impossible d\'effectuer la recherche.',
        causeTechnique: e,
      );
    }
  }

  /// Retourne un patient par son identifiant unique.
  /// Retourne null si aucun patient trouvé.
  Future<Patient?> obtenirPatientParId(int idPatient) async {
    try {
      final db = await _bdd.obtenirBase();
      final List<Map<String, dynamic>> lignes = await db.query(
        'patients',
        where: 'id_patient = ?',
        whereArgs: [idPatient],
        limit: 1,
      );
      if (lignes.isEmpty) return null;
      return Patient.depuisMap(lignes.first);
    } catch (e) {
      debugPrint('Erreur obtenirPatientParId: $e');
      throw RepositoryException(
        'Impossible de charger la fiche du patient.',
        causeTechnique: e,
      );
    }
  }

  // ──────────────────────────────────────────────────────────
  // MISE À JOUR
  // ──────────────────────────────────────────────────────────

  /// Met à jour les informations d'un patient existant.
  /// Retourne le nombre de lignes modifiées (doit être 1).
  Future<int> mettreAJourPatient(Patient patient) async {
    try {
      final db = await _bdd.obtenirBase();
      return await db.update(
        'patients',
        patient.versMap(),
        where: 'id_patient = ?',
        whereArgs: [patient.idPatient],
      );
    } catch (e) {
      debugPrint('Erreur mettreAJourPatient: $e');
      throw RepositoryException(
        'Impossible de modifier les informations du patient.',
        causeTechnique: e,
      );
    }
  }

  /// Archive un patient (suppression logique : est_archive = 1).
  Future<int> archiverPatient(int idPatient) async {
    try {
      final db = await _bdd.obtenirBase();
      return await db.update(
        'patients',
        {'est_archive': 1},
        where: 'id_patient = ?',
        whereArgs: [idPatient],
      );
    } catch (e) {
      debugPrint('Erreur archiverPatient: $e');
      throw RepositoryException(
        "Impossible d'archiver ce patient.",
        causeTechnique: e,
      );
    }
  }

  /// Désarchive un patient (remet est_archive = 0).
  Future<int> desarchiverPatient(int idPatient) async {
    try {
      final db = await _bdd.obtenirBase();
      return await db.update(
        'patients',
        {'est_archive': 0},
        where: 'id_patient = ?',
        whereArgs: [idPatient],
      );
    } catch (e) {
      debugPrint('Erreur desarchiverPatient: $e');
      throw RepositoryException(
        'Impossible de désarchiver ce patient.',
        causeTechnique: e,
      );
    }
  }

  // ──────────────────────────────────────────────────────────
  // VÉRIFICATION DE DOUBLON
  // ──────────────────────────────────────────────────────────

  /// Vérifie si un patient avec le même nom ET téléphone existe déjà.
  /// Retourne true si un doublon est détecté.
  Future<bool> verifierDoublon(String nom, String telephone) async {
    try {
      final db = await _bdd.obtenirBase();
      final List<Map<String, dynamic>> lignes = await db.query(
        'patients',
        where: 'LOWER(nom) = LOWER(?) AND telephone = ? AND est_archive = 0',
        whereArgs: [nom, telephone],
        limit: 1,
      );
      return lignes.isNotEmpty; // true = doublon trouvé
    } catch (e) {
      debugPrint('Erreur verifierDoublon: $e');
      throw RepositoryException(
        'Impossible de vérifier les doublons.',
        causeTechnique: e,
      );
    }
  }
}
