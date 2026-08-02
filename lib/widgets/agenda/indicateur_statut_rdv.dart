// ============================================================
// indicateur_statut_rdv.dart – Badge de statut de rendez-vous
// ============================================================

import 'package:flutter/material.dart';
import '../../models/rendez_vous.dart';

class IndicateurStatutRdv extends StatelessWidget {
  final StatutRendezVous statut;

  const IndicateurStatutRdv({super.key, required this.statut});

  @override
  Widget build(BuildContext context) {
    final Color couleur = statut.obtenirCouleur();
    final String libelle = statut.obtenirLibelle();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: couleur,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        libelle,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _obtenirCouleurTexte(statut),
        ),
      ),
    );
  }

  Color _obtenirCouleurTexte(StatutRendezVous s) {
    switch (s) {
      case StatutRendezVous.annule:
        return Colors.red.shade900;
      case StatutRendezVous.confirme:
        return Colors.green.shade900;
      case StatutRendezVous.effectue:
        return Colors.grey.shade800;
      case StatutRendezVous.absent:
        return Colors.orange.shade900;
      case StatutRendezVous.planifie:
        return Colors.blue.shade900;
    }
  }
}
