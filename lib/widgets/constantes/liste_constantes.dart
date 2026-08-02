// ============================================================
// liste_constantes.dart – Affichage des constantes d'une consultation
// ============================================================

import 'package:flutter/material.dart';
import '../../constants/dimensions.dart';
import '../../models/constante_consultation.dart';
import '../../utils/format_utils.dart';

class ListeConstantes extends StatelessWidget {
  final List<ConstanteConsultation> constantes;

  const ListeConstantes({super.key, required this.constantes});

  @override
  Widget build(BuildContext context) {
    if (constantes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Constantes vitales',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: Dimensions.paddingPetit,
          runSpacing: Dimensions.paddingPetit,
          children: constantes.map((co) {
            final String libelle =
                co.definition?.obtenirLibelleComplet() ?? 'Mesure';
            final String valeurFormatee = FormatUtils.formaterConstante(
              co.valeur,
              co.definition?.unite,
            );

            return Chip(
              avatar: const Icon(Icons.favorite_outline, size: 16),
              label: Text('$libelle : $valeurFormatee'),
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            );
          }).toList(),
        ),
      ],
    );
  }
}
