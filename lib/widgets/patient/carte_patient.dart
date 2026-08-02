// ============================================================
// carte_patient.dart – Carte d'un patient dans la liste
// ============================================================
import 'package:flutter/material.dart';
import '../../constants/couleurs.dart';
import '../../constants/dimensions.dart';
import '../../models/patient.dart';
import '../../utils/date_utils.dart';

/// Carte affichée dans la liste des patients.
/// Affiche : avatar initiales, nom complet, âge, dernier RDV.
class CartePatient extends StatelessWidget {
  final Patient   patient;
  final String?   dateDerniereConsultation;
  final VoidCallback onTap;

  const CartePatient({
    super.key,
    required this.patient,
    this.dateDerniereConsultation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingMoyen,
          vertical: Dimensions.paddingPetit,
        ),
        // Avatar avec les initiales du patient
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Couleurs.primaire,
          child: Text(
            patient.obtenirInitiales(),
            style: const TextStyle(
              color: Couleurs.texteSurFond,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        title: Text(
          patient.obtenirNomComplet(),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${patient.calculerAge()} ans • ${patient.sexe}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (dateDerniereConsultation != null)
              Text(
                'Dernière visite : ${AppDateUtils.formaterDateCourte(dateDerniereConsultation!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Couleurs.texteSecondaire,
                ),
              ),
          ],
        ),
        // Icône allergie si applicable
        trailing: patient.aDesAllergies()
            ? const Tooltip(
                message: 'Allergies connues',
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Couleurs.urgence,
                  size: 20,
                ),
              )
            : const Icon(Icons.chevron_right, color: Couleurs.texteSecondaire),
        onTap: onTap,
      ),
    );
  }
}
