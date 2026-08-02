// ============================================================
// constante_repository.dart – Accès aux données : constantes
//
// Chaque méthode est encapsulée dans un try/catch (§20.2 du cahier
// des charges) : toute erreur SQLite est convertie en
// RepositoryException avec un message lisible pour l'utilisateur.
// ============================================================
import 'package:flutter/foundation.dart';
import '../database/base_de_donnees.dart';
import '../models/constante_consultation.dart';
import '../utils/exceptions.dart';

class ConstanteRepository {
  final BaseDeDonnees _bdd = BaseDeDonnees();

  Future<int> insererConstante(ConstanteConsultation constante) async {
    try {
      final db = await _bdd.obtenirBase();
      return await db.insert('constantes_consultation', constante.versMap());
    } catch (e) {
      debugPrint('Erreur insererConstante: $e');
      throw RepositoryException(
        "Impossible d'enregistrer cette constante.",
        causeTechnique: e,
      );
    }
  }

  Future<void> insererConstantes(List<ConstanteConsultation> constantes) async {
    try {
      if (constantes.isEmpty) return;
      final db = await _bdd.obtenirBase();
      final batch = db.batch();
      for (final c in constantes) {
        batch.insert('constantes_consultation', c.versMap());
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Erreur insererConstantes: $e');
      throw RepositoryException(
        "Impossible d'enregistrer les constantes de la consultation.",
        causeTechnique: e,
      );
    }
  }

  Future<List<ConstanteConsultation>> obtenirConstantesConsultation(
    int idConsultation,
  ) async {
    try {
      final db = await _bdd.obtenirBase();
      final List<Map<String, dynamic>> lignes = await db.query(
        'constantes_consultation',
        where: 'id_consultation = ?',
        whereArgs: [idConsultation],
      );
      return lignes.map((l) => ConstanteConsultation.depuisMap(l)).toList();
    } catch (e) {
      debugPrint('Erreur obtenirConstantesConsultation: $e');
      throw RepositoryException(
        'Impossible de charger les constantes de cette consultation.',
        causeTechnique: e,
      );
    }
  }

  Future<int> supprimerConstantesConsultation(int idConsultation) async {
    try {
      final db = await _bdd.obtenirBase();
      return await db.delete(
        'constantes_consultation',
        where: 'id_consultation = ?',
        whereArgs: [idConsultation],
      );
    } catch (e) {
      debugPrint('Erreur supprimerConstantesConsultation: $e');
      throw RepositoryException(
        'Impossible de supprimer les constantes de cette consultation.',
        causeTechnique: e,
      );
    }
  }
}
