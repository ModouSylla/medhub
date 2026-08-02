// ============================================================
// consultation_repository.dart – Accès aux données : consultations
//
// Chaque méthode est encapsulée dans un try/catch (§20.2 du cahier
// des charges) : toute erreur SQLite est convertie en
// RepositoryException avec un message lisible pour l'utilisateur.
// ============================================================
import 'package:flutter/foundation.dart';
import '../database/base_de_donnees.dart';
import '../models/consultation.dart';
import '../utils/exceptions.dart';

class ConsultationRepository {
  final BaseDeDonnees _bdd = BaseDeDonnees();

  /// Insère une nouvelle consultation et retourne son id.
  Future<int> insererConsultation(Consultation consultation) async {
    try {
      final db = await _bdd.obtenirBase();
      return await db.insert('consultations', consultation.versMap());
    } catch (e) {
      debugPrint('Erreur insererConsultation: $e');
      throw RepositoryException(
        "Impossible d'enregistrer la consultation. Veuillez réessayer.",
        causeTechnique: e,
      );
    }
  }

  /// Retourne toutes les consultations d'un patient, les plus récentes d'abord.
  Future<List<Consultation>> obtenirConsultationsPatient(int idPatient) async {
    try {
      final db = await _bdd.obtenirBase();
      final List<Map<String, dynamic>> lignes = await db.query(
        'consultations',
        where: 'id_patient = ?',
        whereArgs: [idPatient],
        orderBy: 'date_consultation DESC, date_creation DESC',
      );
      return lignes.map((l) => Consultation.depuisMap(l)).toList();
    } catch (e) {
      debugPrint('Erreur obtenirConsultationsPatient: $e');
      throw RepositoryException(
        "Impossible de charger l'historique des consultations.",
        causeTechnique: e,
      );
    }
  }

  /// Retourne la consultation la plus récente d'un patient.
  Future<Consultation?> obtenirDerniereConsultation(int idPatient) async {
    try {
      final db = await _bdd.obtenirBase();
      final List<Map<String, dynamic>> lignes = await db.query(
        'consultations',
        where: 'id_patient = ?',
        whereArgs: [idPatient],
        orderBy: 'date_consultation DESC',
        limit: 1,
      );
      if (lignes.isEmpty) return null;
      return Consultation.depuisMap(lignes.first);
    } catch (e) {
      debugPrint('Erreur obtenirDerniereConsultation: $e');
      throw RepositoryException(
        'Impossible de charger la dernière consultation.',
        causeTechnique: e,
      );
    }
  }

  /// Retourne une consultation par son identifiant.
  Future<Consultation?> obtenirConsultationParId(int idConsultation) async {
    try {
      final db = await _bdd.obtenirBase();
      final List<Map<String, dynamic>> lignes = await db.query(
        'consultations',
        where: 'id_consultation = ?',
        whereArgs: [idConsultation],
        limit: 1,
      );
      if (lignes.isEmpty) return null;
      return Consultation.depuisMap(lignes.first);
    } catch (e) {
      debugPrint('Erreur obtenirConsultationParId: $e');
      throw RepositoryException(
        'Impossible de charger cette consultation.',
        causeTechnique: e,
      );
    }
  }

  /// Retourne les ids des patients ayant un examen en attente.
  Future<List<int>> obtenirIdsExamenEnAttente() async {
    try {
      final db = await _bdd.obtenirBase();
      final List<Map<String, dynamic>> lignes = await db.rawQuery(
        'SELECT DISTINCT id_patient FROM consultations '
        'WHERE examen_en_attente = 1',
      );
      return lignes.map((l) => l['id_patient'] as int).toList();
    } catch (e) {
      debugPrint('Erreur obtenirIdsExamenEnAttente: $e');
      throw RepositoryException(
        'Impossible de charger les examens en attente.',
        causeTechnique: e,
      );
    }
  }

  /// Met à jour le flag "examen en attente" d'une consultation.
  Future<int> mettreAJourFlagExamen(int idConsultation, bool valeur) async {
    try {
      final db = await _bdd.obtenirBase();
      return await db.update(
        'consultations',
        {'examen_en_attente': valeur ? 1 : 0},
        where: 'id_consultation = ?',
        whereArgs: [idConsultation],
      );
    } catch (e) {
      debugPrint('Erreur mettreAJourFlagExamen: $e');
      throw RepositoryException(
        "Impossible de mettre à jour l'examen.",
        causeTechnique: e,
      );
    }
  }

  /// Met à jour le flag "rappel urgent" de toutes les consultations d'un patient.
  Future<int> mettreAJourFlagUrgent(int idPatient, bool valeur) async {
    try {
      final db = await _bdd.obtenirBase();
      return await db.update(
        'consultations',
        {'rappel_urgent': valeur ? 1 : 0},
        where: 'id_patient = ?',
        whereArgs: [idPatient],
      );
    } catch (e) {
      debugPrint('Erreur mettreAJourFlagUrgent: $e');
      throw RepositoryException(
        'Impossible de mettre à jour le rappel urgent.',
        causeTechnique: e,
      );
    }
  }
}
