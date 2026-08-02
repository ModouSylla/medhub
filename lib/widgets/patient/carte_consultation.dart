// ============================================================
// carte_consultation.dart – Carte d'une consultation dans l'historique
// ============================================================
import 'package:flutter/material.dart';
import '../../constants/couleurs.dart';
import '../../constants/dimensions.dart';
import '../../models/consultation.dart';
import '../../utils/date_utils.dart';

/// Carte représentant une consultation dans l'historique du carnet.
class CarteConsultation extends StatelessWidget {
  final Consultation consultation;
  final VoidCallback onTap;

  const CarteConsultation({
    super.key,
    required this.consultation,
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
        // Date de la consultation
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_note, color: Couleurs.primaire, size: 28),
          ],
        ),
        title: Text(
          consultation.obtenirResumeDiagnostic(),
          style: Theme.of(context).textTheme.titleSmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppDateUtils.formaterDateLongue(consultation.dateConsultation),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            // Indicateurs visuels (examen en attente, urgent)
            if (consultation.examenEnAttente || consultation.rappelUrgent)
              const SizedBox(height: 4),
            Row(
              children: [
                if (consultation.examenEnAttente)
                  _BadgeIndicateur(
                    libelle: 'Examen en attente',
                    couleur: Couleurs.accent,
                  ),
                if (consultation.rappelUrgent) ...[
                  if (consultation.examenEnAttente)
                    const SizedBox(width: 4),
                  _BadgeIndicateur(
                    libelle: 'Rappel urgent',
                    couleur: Couleurs.urgence,
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

/// Badge coloré pour les indicateurs d'état.
class _BadgeIndicateur extends StatelessWidget {
  final String couleur_label;
  final String libelle;
  final Color  couleur;

  const _BadgeIndicateur({
    required this.libelle,
    required this.couleur,
  }) : couleur_label = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: couleur.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        libelle,
        style: TextStyle(
          color: couleur,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
