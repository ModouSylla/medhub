// ============================================================
// sauvegarde_service.dart – Export et restauration de la BDD
//
// Permet au médecin de sauvegarder et restaurer la base SQLite
// vers/depuis le stockage externe de l'appareil.
// ============================================================
import 'dart:io';
import 'package:path/path.dart' as path_lib;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../database/base_de_donnees.dart';

class SauvegardeService {
  final BaseDeDonnees _bdd = BaseDeDonnees();

  // ──────────────────────────────────────────────────────────
  // EXPORT
  // ──────────────────────────────────────────────────────────

  /// Exporte la base de données vers le dossier Documents/MediHub/.
  /// Retourne le chemin du fichier exporté, ou null en cas d'échec.
  Future<String?> exporterBaseDeDonnees() async {
    try {
      // Fermer la base pour s'assurer que toutes les données sont écrites
      await _bdd.fermerBase();

      // Chemin source : répertoire privé de l'application
      final String cheminSource = await obtenirCheminBase();

      // Dossier de destination : Documents/MediHub/
      final Directory dossierDocs = await getApplicationDocumentsDirectory();
      final Directory dossierMediHub =
          Directory(path_lib.join(dossierDocs.path, 'MediHub'));

      // Créer le dossier MediHub s'il n'existe pas
      if (!await dossierMediHub.exists()) {
        await dossierMediHub.create(recursive: true);
      }

      // Générer un nom de fichier horodaté
      final String horodatage = _obtenirHorodatage();
      final String cheminDestination = path_lib.join(
        dossierMediHub.path,
        'medihub_backup_$horodatage.db',
      );

      // Copier le fichier de la base vers la destination
      await File(cheminSource).copy(cheminDestination);

      return cheminDestination;
    } catch (e) {
      // Journaliser l'erreur (en production : utiliser un logger)
      return null;
    }
  }

  // ──────────────────────────────────────────────────────────
  // RESTAURATION
  // ──────────────────────────────────────────────────────────

  /// Restaure la base de données depuis un fichier de sauvegarde.
  /// ATTENTION : remplace toutes les données actuelles.
  /// Retourne true en cas de succès.
  Future<bool> restaurerDepuisFichier(String cheminFichier) async {
    try {
      final File fichierSource = File(cheminFichier);

      // Vérifier que le fichier existe
      if (!await fichierSource.exists()) return false;

      // Vérifier l'extension
      if (!cheminFichier.endsWith('.db')) return false;

      // Chemin de la base active
      final String cheminBaseActive = await obtenirCheminBase();

      // Sauvegarder la base actuelle avant restauration (sécurité)
      final String horodatage = _obtenirHorodatage();
      final String cheminTemp = '${cheminBaseActive}_avant_restauration_$horodatage';
      await File(cheminBaseActive).copy(cheminTemp);

      // Fermer la base active
      await _bdd.fermerBase();

      // Remplacer la base active par le fichier de sauvegarde
      await fichierSource.copy(cheminBaseActive);

      return true;
    } catch (e) {
      return false;
    }
  }

  // ──────────────────────────────────────────────────────────
  // UTILITAIRES
  // ──────────────────────────────────────────────────────────

  /// Retourne le chemin complet du fichier SQLite actif.
  Future<String> obtenirCheminBase() async {
    final String dossierBase = await getDatabasesPath();
    return path_lib.join(dossierBase, 'medihub.db');
  }

  /// Génère un horodatage formaté pour les noms de fichiers.
  /// Format : "AAAAMMJJ_HHMMSS"
  String _obtenirHorodatage() {
    final DateTime maintenant = DateTime.now();
    final String annee   = maintenant.year.toString();
    final String mois    = maintenant.month.toString().padLeft(2, '0');
    final String jour    = maintenant.day.toString().padLeft(2, '0');
    final String heure   = maintenant.hour.toString().padLeft(2, '0');
    final String minute  = maintenant.minute.toString().padLeft(2, '0');
    final String seconde = maintenant.second.toString().padLeft(2, '0');
    return '${annee}${mois}${jour}_${heure}${minute}${seconde}';
  }
}
