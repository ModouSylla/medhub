// ============================================================
// message_vide.dart – Widget état vide (liste sans éléments)
// ============================================================
import 'package:flutter/material.dart';
import '../../constants/couleurs.dart';
import '../../constants/dimensions.dart';
import 'bouton_primaire.dart';

/// Affiche un message illustré quand une liste est vide.
class MessageVide extends StatelessWidget {
  final IconData icone;
  final String   message;
  final String?  libelleAction;
  final VoidCallback? onAction;

  const MessageVide({
    super.key,
    required this.icone,
    required this.message,
    this.libelleAction,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingTresGrand),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 64, color: Couleurs.texteSecondaire),
            const SizedBox(height: Dimensions.paddingMoyen),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Couleurs.texteSecondaire,
              ),
            ),
            if (libelleAction != null && onAction != null) ...[
              const SizedBox(height: Dimensions.paddingGrand),
              BoutonPrimaire(libelle: libelleAction!, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}
