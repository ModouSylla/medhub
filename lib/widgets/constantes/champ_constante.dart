// ============================================================
// champ_constante.dart – Champ de saisie pour une constante médicale
// ============================================================
import 'package:flutter/material.dart';
import '../../models/definition_constante.dart';
import '../../utils/validateurs.dart';

class ChampConstante extends StatelessWidget {
  final DefinitionConstante definition;
  final TextEditingController controller;

  const ChampConstante({
    super.key,
    required this.definition,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final bool estNum = definition.estNumerique();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: estNum
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: definition.libelle,
          suffixText: (definition.unite != null && definition.unite!.isNotEmpty)
              ? definition.unite
              : null,
          helperText: definition.unite,
        ),
        validator: (valeur) {
          if (estNum) {
            return Validateurs.validerConstanteNumerique(valeur);
          }
          return Validateurs.validerTexteAvecMax(valeur, 500);
        },
      ),
    );
  }
}
