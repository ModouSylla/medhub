// ============================================================
// dialogue_confirmation.dart – Boîte de dialogue de confirmation
// ============================================================
import 'package:flutter/material.dart';

/// Affiche une boîte de dialogue de confirmation et retourne true/false.
Future<bool> afficherDialogueConfirmation(
  BuildContext context, {
  required String titre,
  required String message,
  String libelleConfirmer = 'Confirmer',
  String libelleAnnuler   = 'Annuler',
}) async {
  final bool? resultat = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title:   Text(titre),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(libelleAnnuler),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(libelleConfirmer),
        ),
      ],
    ),
  );
  return resultat ?? false;
}
