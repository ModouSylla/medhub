// ============================================================
// carte_rendez_vous.dart – Carte d'un rendez-vous dans l'agenda
// ============================================================
import 'package:flutter/material.dart';
import '../../constants/chaines.dart';
import '../../constants/couleurs.dart';
import '../../constants/dimensions.dart';
import '../../models/rendez_vous.dart';
import '../../utils/date_utils.dart';

/// Carte affichant un rendez-vous dans la vue quotidienne.
class CarteRendezVous extends StatelessWidget {
  final RendezVous    rdv;
  final VoidCallback? onTap;
  final VoidCallback? onAnnuler;

  const CarteRendezVous({
    super.key,
    required this.rdv,
    this.onTap,
    this.onAnnuler,
  });

  bool get _peutEtreAnnule =>
      !rdv.estBlocage &&
      rdv.statut != StatutRendezVous.annule &&
      rdv.statut != StatutRendezVous.effectue;

  @override
  Widget build(BuildContext context) {
    final Color couleurStatut = rdv.statut.obtenirCouleur();

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimensions.rayonCarte),
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingMoyen),
          child: Row(
            children: [
              // Indicateur coloré du statut (barre verticale)
              Container(
                width: 4,
                height: 50,
                decoration: BoxDecoration(
                  color: rdv.estBlocage ? Couleurs.blocagePlage : couleurStatut,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              // Contenu principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rdv.estBlocage
                          ? 'Plage bloquée'
                          : (rdv.nomPatient ?? 'Patient'),
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${AppDateUtils.formaterHeure(rdv.heureDebut)} – '
                      '${AppDateUtils.formaterHeure(rdv.heureFin)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (rdv.motif != null)
                      Text(
                        rdv.motif!,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: Couleurs.texteSecondaire),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              // Badge statut
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: couleurStatut,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  rdv.statut.obtenirLibelle(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (onAnnuler != null && _peutEtreAnnule)
                PopupMenuButton<void>(
                  tooltip: Chaines.boutonAnnulerRdv,
                  icon: const Icon(
                    Icons.more_vert,
                    color: Couleurs.texteSecondaire,
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: onAnnuler,
                      child: const Row(
                        children: [
                          Icon(Icons.event_busy, color: Couleurs.urgence),
                          SizedBox(width: 8),
                          Text(
                            Chaines.boutonAnnulerRdv,
                            style: TextStyle(color: Couleurs.urgence),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
