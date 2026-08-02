// ============================================================
// rendez_vous_repository.dart – Accès aux données : agenda
//
// Chaque méthode est encapsulée dans un try/catch (§20.2 du cahier
// des charges) : toute erreur SQLite est convertie en
// RepositoryException avec un message lisible pour l'utilisateur.
// ============================================================
import 'package:flutter/foundation.dart';
import '../database/base_de_donnees.dart';
import '../models/rendez_vous.dart';
import '../utils/exceptions.dart';

class RendezVousRepository {
  final BaseDeDonnees _bdd = BaseDeDonnees();

  /// Insère un nouveau rendez-vous et retourne son id.
  Future<int> insererRendezVous(RendezVous rdv) async {
    try {
      final db = await _bdd.obtenirBase();
      return await db.insert('rendez_vous', rdv.versMap());
    } catch (e) {
      debugPrint('Erreur insererRendezVous: $e');
      throw RepositoryException(
        "Impossible d'enregistrer le rendez-vous. Veuillez réessayer.",
        causeTechnique: e,
      );
    }
  }

  /// Retourne tous les rendez-vous d'une date donnée, triés par heure.
  Future<List<RendezVous>> obtenirRdvDuJour(String date) async {
    try {
      final db = await _bdd.obtenirBase();
      final List<Map<String, dynamic>> lignes = await db.query(
        'rendez_vous',
        where: 'date_heure = ? AND statut != ?',
        whereArgs: [date, 'ANNULE'],
        orderBy: 'heure_debut ASC',
      );
      return lignes.map((l) => RendezVous.depuisMap(l)).toList();
    } catch (e) {
      debugPrint('Erreur obtenirRdvDuJour: $e');
      throw RepositoryException(
        'Impossible de charger les rendez-vous du jour.',
        causeTechnique: e,
      );
    }
  }

  /// Retourne les rendez-vous entre deux dates (vue hebdomadaire).
  Future<List<RendezVous>> obtenirRdvSemaine(
    String dateDebut,
    String dateFin,
  ) async {
    try {
      final db = await _bdd.obtenirBase();
      final List<Map<String, dynamic>> lignes = await db.query(
        'rendez_vous',
        where: 'date_heure >= ? AND date_heure <= ? AND statut != ?',
        whereArgs: [dateDebut, dateFin, 'ANNULE'],
        orderBy: 'date_heure ASC, heure_debut ASC',
      );
      return lignes.map((l) => RendezVous.depuisMap(l)).toList();
    } catch (e) {
      debugPrint('Erreur obtenirRdvSemaine: $e');
      throw RepositoryException(
        "Impossible de charger l'agenda de la semaine.",
        causeTechnique: e,
      );
    }
  }

  /// Retourne tous les rendez-vous d'un patient (historique).
  Future<List<RendezVous>> obtenirRdvPatient(int idPatient) async {
    try {
      final db = await _bdd.obtenirBase();
      final List<Map<String, dynamic>> lignes = await db.query(
        'rendez_vous',
        where: 'id_patient = ?',
        whereArgs: [idPatient],
        orderBy: 'date_heure DESC, heure_debut DESC',
      );
      return lignes.map((l) => RendezVous.depuisMap(l)).toList();
    } catch (e) {
      debugPrint('Erreur obtenirRdvPatient: $e');
      throw RepositoryException(
        "Impossible de charger l'historique des rendez-vous.",
        causeTechnique: e,
      );
    }
  }

  /// Retourne un rendez-vous par son identifiant.
  Future<RendezVous?> obtenirRdvParId(int idRdv) async {
    try {
      final db = await _bdd.obtenirBase();
      final List<Map<String, dynamic>> lignes = await db.query(
        'rendez_vous',
        where: 'id_rendez_vous = ?',
        whereArgs: [idRdv],
        limit: 1,
      );
      if (lignes.isEmpty) return null;
      return RendezVous.depuisMap(lignes.first);
    } catch (e) {
      debugPrint('Erreur obtenirRdvParId: $e');
      throw RepositoryException(
        'Impossible de charger ce rendez-vous.',
        causeTechnique: e,
      );
    }
  }

  /// Met à jour un rendez-vous existant.
  Future<int> mettreAJourRendezVous(RendezVous rdv) async {
    try {
      final db = await _bdd.obtenirBase();
      return await db.update(
        'rendez_vous',
        rdv.versMap(),
        where: 'id_rendez_vous = ?',
        whereArgs: [rdv.idRendezVous],
      );
    } catch (e) {
      debugPrint('Erreur mettreAJourRendezVous: $e');
      throw RepositoryException(
        'Impossible de modifier ce rendez-vous.',
        causeTechnique: e,
      );
    }
  }

  /// Change le statut d'un rendez-vous.
  Future<int> changerStatutRdv(
    int idRdv,
    StatutRendezVous statut,
  ) async {
    try {
      final db = await _bdd.obtenirBase();
      return await db.update(
        'rendez_vous',
        {'statut': statut.versChaine()},
        where: 'id_rendez_vous = ?',
        whereArgs: [idRdv],
      );
    } catch (e) {
      debugPrint('Erreur changerStatutRdv: $e');
      throw RepositoryException(
        'Impossible de mettre à jour le statut du rendez-vous.',
        causeTechnique: e,
      );
    }
  }

  /// Met à jour l'id de la notification planifiée pour un RDV.
  Future<int> mettreAJourIdNotification(
    int idRdv,
    int? idNotification,
  ) async {
    try {
      final db = await _bdd.obtenirBase();
      return await db.update(
        'rendez_vous',
        {'id_notification': idNotification},
        where: 'id_rendez_vous = ?',
        whereArgs: [idRdv],
      );
    } catch (e) {
      debugPrint('Erreur mettreAJourIdNotification: $e');
      throw RepositoryException(
        'Impossible de mettre à jour la notification associée.',
        causeTechnique: e,
      );
    }
  }

  /// Supprime un rendez-vous définitivement.
  Future<int> supprimerRendezVous(int idRdv) async {
    try {
      final db = await _bdd.obtenirBase();
      return await db.delete(
        'rendez_vous',
        where: 'id_rendez_vous = ?',
        whereArgs: [idRdv],
      );
    } catch (e) {
      debugPrint('Erreur supprimerRendezVous: $e');
      throw RepositoryException(
        'Impossible de supprimer ce rendez-vous.',
        causeTechnique: e,
      );
    }
  }

  /// Vérifie si un créneau est déjà occupé (conflit horaire).
  /// [excludeId] permet d'exclure le RDV en cours de modification.
  Future<List<RendezVous>> verifierConflitHoraire(
    String date,
    String heureDebut,
    String heureFin, {
    int? excludeId,
  }) async {
    try {
      final db = await _bdd.obtenirBase();

      // Un conflit existe si : heure_début_existant < heure_fin_nouveau
      //                    ET  heure_fin_existante  > heure_début_nouveau
      String where = '''
        date_heure = ? AND statut != ? AND
        heure_debut < ? AND heure_fin > ?
      ''';
      final List<dynamic> args = [date, 'ANNULE', heureFin, heureDebut];

      // Exclure le RDV lui-même lors d'une modification
      if (excludeId != null) {
        where += ' AND id_rendez_vous != ?';
        args.add(excludeId);
      }

      final List<Map<String, dynamic>> lignes = await db.query(
        'rendez_vous',
        where: where,
        whereArgs: args,
      );
      return lignes.map((l) => RendezVous.depuisMap(l)).toList();
    } catch (e) {
      debugPrint('Erreur verifierConflitHoraire: $e');
      throw RepositoryException(
        'Impossible de vérifier les conflits de créneaux.',
        causeTechnique: e,
      );
    }
  }
}
