// ============================================================
// ecran_agenda.dart – Vue agenda quotidienne et hebdomadaire
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/chaines.dart';
import '../../constants/routes.dart';
import '../../models/rendez_vous.dart';
import '../../providers/agenda_provider.dart';
import '../../utils/date_utils.dart';
import '../../widgets/agenda/carte_rendez_vous.dart';
import '../../widgets/agenda/grille_hebdomadaire.dart';
import '../../widgets/commun/indicateur_chargement.dart';
import '../../widgets/commun/message_vide.dart';
import '../../widgets/commun/dialogue_confirmation.dart';

class EcranAgenda extends StatefulWidget {
  const EcranAgenda({super.key});

  @override
  State<EcranAgenda> createState() => _EcranAgendaState();
}

class _EcranAgendaState extends State<EcranAgenda> {
  bool _vueHebdomadaire = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AgendaProvider>().chargerRdvJour(DateTime.now());
    });
  }

  Future<void> _changerJour(int delta) async {
    final date = context.read<AgendaProvider>().dateSelectionnee;
    final nouvelle = date.add(Duration(days: delta));
    await _chargerMode(nouvelle);
  }

  Future<void> _chargerMode(DateTime date) async {
    final agenda = context.read<AgendaProvider>();
    if (_vueHebdomadaire) {
      await agenda.chargerRdvSemaine(date);
    } else {
      await agenda.chargerRdvJour(date);
    }
  }

  Future<void> _basculerVue(bool hebdo) async {
    setState(() => _vueHebdomadaire = hebdo);
    final date = context.read<AgendaProvider>().dateSelectionnee;
    await _chargerMode(date);
  }

  Future<void> _annulerRdv(RendezVous rdv) async {
    final bool confirme = await afficherDialogueConfirmation(
      context,
      titre: Chaines.boutonAnnulerRdv,
      message: Chaines.confirmationAnnulationRdv,
      libelleConfirmer: Chaines.boutonConfirmer,
    );
    if (!confirme || !mounted) return;

    final bool ok = await context.read<AgendaProvider>().annulerRendezVous(
          rdv.idRendezVous!,
          rdv.idNotification,
        );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(Chaines.succesRdvAnnule)),
      );
    } else {
      final String? erreur = context.read<AgendaProvider>().messageErreur;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erreur ?? Chaines.erreurGenerique)),
      );
      context.read<AgendaProvider>().effacerErreur();
    }
  }

  Future<void> _ouvrirFormulaire({RendezVous? rdv}) async {
    final date = context.read<AgendaProvider>().dateSelectionnee;
    await Navigator.pushNamed(
      context,
      Routes.formulaireRdv,
      arguments: {
        'rdv': rdv,
        'date': date,
      },
    );
    if (mounted) {
      await _chargerMode(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Chaines.titreAgenda),
        actions: [
          // Toggle vue Jour / Semaine
          IconButton(
            icon: Icon(_vueHebdomadaire ? Icons.view_day : Icons.view_week),
            tooltip: _vueHebdomadaire ? 'Vue jour' : 'Vue semaine',
            onPressed: () => _basculerVue(!_vueHebdomadaire),
          ),
        ],
      ),
      body: Consumer<AgendaProvider>(
        builder: (context, agenda, _) {
          final date = agenda.dateSelectionnee;

          return Column(
            children: [
              // Barre de navigation temporelle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => _changerJour(_vueHebdomadaire ? -7 : -1),
                    ),
                    Column(
                      children: [
                        Text(
                          _vueHebdomadaire
                              ? 'Semaine du ${AppDateUtils.formaterDateCourte(AppDateUtils.debutDeSemaine(date))}'
                              : AppDateUtils.formaterDateLongue(AppDateUtils.dateVersIso(date)),
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        if (AppDateUtils.dateVersIso(date) == AppDateUtils.aujourdhui())
                          Text(
                            'Aujourd\'hui',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () => _changerJour(_vueHebdomadaire ? 7 : 1),
                    ),
                  ],
                ),
              ),

              // Contenu principal : Grille hebdo ou Liste jour
              Expanded(
                child: agenda.enChargement
                    ? const IndicateurChargement()
                    : _vueHebdomadaire
                        ? GrilleHebdomadaire(
                            dateReference: date,
                            rendezVousSemaine: agenda.rdvSemaine,
                            onJourSelectionne: (j) => agenda.chargerRdvJour(j),
                            onRdvTap: (rdv) => _ouvrirFormulaire(rdv: rdv),
                          )
                        : agenda.rdvJour.isEmpty
                            ? MessageVide(
                                icone: Icons.event_busy,
                                message: 'Aucun rendez-vous ce jour.',
                                libelleAction: Chaines.titreNouveauRdv,
                                onAction: () => _ouvrirFormulaire(),
                              )
                            : RefreshIndicator(
                                onRefresh: () => agenda.chargerRdvJour(date),
                                child: ListView.builder(
                                  itemCount: agenda.rdvJour.length,
                                  itemBuilder: (context, index) {
                                    final rdv = agenda.rdvJour[index];
                                    return CarteRendezVous(
                                      rdv: rdv,
                                      onTap: () => _ouvrirFormulaire(rdv: rdv),
                                      onAnnuler: () => _annulerRdv(rdv),
                                    );
                                  },
                                ),
                              ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _ouvrirFormulaire(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
