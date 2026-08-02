// ============================================================
// journal_erreurs_service.dart – Journalisation des erreurs
//
// Capture les erreurs non gérées (FlutterError.onError et
// PlatformDispatcher.onError, cf. cahier des charges §20.2) et les
// écrit dans un fichier local logs/erreurs.log, afin de pouvoir
// diagnostiquer un problème signalé par le médecin sans avoir accès
// à un outil de débogage connecté.
// ============================================================
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path_lib;
import 'package:path_provider/path_provider.dart';

class JournalErreursService {
  /// Ajoute une ligne horodatée au fichier logs/erreurs.log.
  /// Ne lève jamais d'exception : une erreur de journalisation ne doit
  /// jamais provoquer un second crash.
  static Future<void> journaliser(String source, Object erreur, [StackTrace? pile]) async {
    try {
      final Directory dossierDocs = await getApplicationDocumentsDirectory();
      final Directory dossierLogs =
          Directory(path_lib.join(dossierDocs.path, 'logs'));
      if (!await dossierLogs.exists()) {
        await dossierLogs.create(recursive: true);
      }

      final File fichierLog =
          File(path_lib.join(dossierLogs.path, 'erreurs.log'));

      final String horodatage = DateTime.now().toIso8601String();
      final StringBuffer ligne = StringBuffer()
        ..writeln('[$horodatage] [$source] $erreur');
      if (pile != null) {
        ligne.writeln(pile.toString());
      }
      ligne.writeln('---');

      await fichierLog.writeAsString(
        ligne.toString(),
        mode: FileMode.append,
        flush: true,
      );
    } catch (e) {
      // On journalise juste en console : on ne doit jamais faire
      // planter l'app à cause d'un échec de journalisation.
      debugPrint('Impossible d\'écrire dans le journal d\'erreurs: $e');
    }
  }
}
