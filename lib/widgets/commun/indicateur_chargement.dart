// ============================================================
// indicateur_chargement.dart – Spinner de chargement centré
// ============================================================
import 'package:flutter/material.dart';
import '../../constants/couleurs.dart';

/// Affiche un indicateur de chargement centré avec message optionnel.
class IndicateurChargement extends StatelessWidget {
  final String? message;
  const IndicateurChargement({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: Couleurs.primaire),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
