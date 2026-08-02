// ============================================================
// definition_constante_repository.dart – Définitions de constantes
//
// Chaque méthode est encapsulée dans un try/catch (§20.2 du cahier
// des charges) : toute erreur SQLite est convertie en
// RepositoryException avec un message lisible pour l'utilisateur.
// ============================================================
import 'package:flutter/foundation.dart';
import '../database/base_de_donnees.dart';
import '../models/definition_constante.dart';
import '../utils/exceptions.dart';

class DefinitionConstanteRepository {
  final BaseDeDonnees _bdd = BaseDeDonnees();

  /// Retourne les définitions de constantes pour un profil médical donné.
  /// Triées par ordre_affichage croissant.
  Future<List<DefinitionConstante>> obtenirDefinitionsParProfil(
    String profilMedical,
  ) async {
    try {
      final db = await _bdd.obtenirBase();
      final List<Map<String, dynamic>> lignes = await db.query(
        'definitions_constantes',
        where: 'profil_medical = ?',
        whereArgs: [profilMedical],
        orderBy: 'ordre_affichage ASC',
      );
      return lignes.map((l) => DefinitionConstante.depuisMap(l)).toList();
    } catch (e) {
      debugPrint('Erreur obtenirDefinitionsParProfil: $e');
      throw RepositoryException(
        'Impossible de charger les constantes du profil médical.',
        causeTechnique: e,
      );
    }
  }

  /// Insère une définition de constante personnalisée.
  Future<int> insererDefinition(DefinitionConstante definition) async {
    try {
      final db = await _bdd.obtenirBase();
      return await db.insert('definitions_constantes', definition.versMap());
    } catch (e) {
      debugPrint('Erreur insererDefinition: $e');
      throw RepositoryException(
        "Impossible d'enregistrer cette constante personnalisée.",
        causeTechnique: e,
      );
    }
  }

  /// Supprime toutes les définitions du profil personnalisé.
  /// Appelée avant la re-configuration du profil personnalisé.
  Future<int> supprimerDefinitionsPersonnalisees() async {
    try {
      final db = await _bdd.obtenirBase();
      return await db.delete(
        'definitions_constantes',
        where: 'profil_medical = ?',
        whereArgs: ['personnalise'],
      );
    } catch (e) {
      debugPrint('Erreur supprimerDefinitionsPersonnalisees: $e');
      throw RepositoryException(
        'Impossible de réinitialiser les constantes personnalisées.',
        causeTechnique: e,
      );
    }
  }
}
