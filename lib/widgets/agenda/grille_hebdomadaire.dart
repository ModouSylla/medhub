// ============================================================
// grille_hebdomadaire.dart – Vue grille 7 jours pour l'agenda
// ============================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/couleurs.dart';
import '../../models/rendez_vous.dart';
import '../../utils/date_utils.dart';

class GrilleHebdomadaire extends StatelessWidget {
  final DateTime dateReference;
  final List<RendezVous> rendezVousSemaine;
  final Function(DateTime) onJourSelectionne;
  final Function(RendezVous) onRdvTap;

  const GrilleHebdomadaire({
    super.key,
    required this.dateReference,
    required this.rendezVousSemaine,
    required this.onJourSelectionne,
    required this.onRdvTap,
  });

  List<DateTime> _obtenirJoursSemaine() {
    final int joursDepuisLundi = dateReference.weekday - 1;
    final DateTime lundi = dateReference.subtract(Duration(days: joursDepuisLundi));
    return List.generate(7, (i) => lundi.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    final jours = _obtenirJoursSemaine();
    final DateFormat formatJour = DateFormat('E', 'fr_FR');
    final String aujourdhuiIso = AppDateUtils.aujourdhui();

    return Column(
      children: [
        // En-tête des jours de la semaine (Lun - Dim)
        Container(
          color: Couleurs.surface,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: jours.map((jour) {
              final String iso = AppDateUtils.dateVersIso(jour);
              final bool estAujourdhui = iso == aujourdhuiIso;
              final bool estSelectionne =
                  AppDateUtils.dateVersIso(dateReference) == iso;

              return Expanded(
                child: InkWell(
                  onTap: () => onJourSelectionne(jour),
                  child: Column(
                    children: [
                      Text(
                        formatJour.format(jour).toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: estSelectionne
                              ? Couleurs.primaire
                              : Couleurs.texteSecondaire,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: estSelectionne
                              ? Couleurs.primaire
                              : (estAujourdhui
                                  ? Couleurs.secondaire.withOpacity(0.3)
                                  : Colors.transparent),
                        ),
                        child: Center(
                          child: Text(
                            '${jour.day}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: estSelectionne
                                  ? Colors.white
                                  : Couleurs.textePrimaire,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const Divider(height: 1),
        // Vue 7 colonnes pour les rendez-vous
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: jours.map((jour) {
                final String dateIso = AppDateUtils.dateVersIso(jour);
                final rdvsJour = rendezVousSemaine
                    .where((r) => r.dateHeure == dateIso)
                    .toList();

                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: Couleurs.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Couleurs.separateur),
                    ),
                    constraints: const BoxConstraints(minHeight: 300),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (rdvsJour.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Icon(
                              Icons.remove,
                              size: 16,
                              color: Couleurs.texteSecondaire,
                            ),
                          )
                        else
                          ...rdvsJour.map(
                            (rdv) => InkWell(
                              onTap: () => onRdvTap(rdv),
                              child: Container(
                                margin: const EdgeInsets.all(3),
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: rdv.estBlocage
                                      ? Couleurs.blocagePlage
                                      : rdv.statut.obtenirCouleur(),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      rdv.heureDebut,
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      rdv.estBlocage
                                          ? 'Blocage'
                                          : (rdv.nomPatient ?? 'RDV'),
                                      style: const TextStyle(fontSize: 10),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
