// ============================================================
// en_tete_patient.dart – En-tête du carnet médical patient
// ============================================================
import 'package:flutter/material.dart';
import '../../constants/couleurs.dart';
import '../../constants/dimensions.dart';
import '../../models/patient.dart';

/// Affiche les informations clés du patient en haut du carnet.
class EnTetePatient extends StatelessWidget {
  final Patient patient;
  const EnTetePatient({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(Dimensions.paddingMoyen),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingMoyen),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Ligne : avatar + nom + âge ─────────────────
            Row(
              children: [
                CircleAvatar(
                  radius: Dimensions.tailleAvatar / 2,
                  backgroundColor: Couleurs.primaire,
                  child: Text(
                    patient.obtenirInitiales(),
                    style: const TextStyle(
                      color: Couleurs.texteSurFond,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.obtenirNomComplet(),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${patient.calculerAge()} ans • ${patient.sexe}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                // Badge groupe sanguin
                if (patient.groupeSanguin != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Couleurs.urgence.withOpacity(0.15),
                      borderRadius: const BorderRadius.all(
                          Radius.circular(Dimensions.rayonCirculaire)),
                    ),
                    child: Text(
                      patient.groupeSanguin!,
                      style: const TextStyle(
                        color: Couleurs.urgence,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),

            // ── Allergies ─────────────────────────────────
            if (patient.aDesAllergies()) ...[
              const Divider(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Couleurs.urgence, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Allergies : ${patient.allergies}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Couleurs.urgence,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // ── Antécédents ───────────────────────────────
            if (patient.antecedentsPersonnels != null &&
                patient.antecedentsPersonnels!.isNotEmpty) ...[
              const Divider(height: 24),
              Text(
                'Antécédents',
                style: Theme.of(context).textTheme.labelMedium
                    ?.copyWith(color: Couleurs.texteSecondaire),
              ),
              const SizedBox(height: 4),
              Text(
                patient.antecedentsPersonnels!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
