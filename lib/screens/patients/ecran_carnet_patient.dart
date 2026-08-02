// ============================================================
// ecran_carnet_patient.dart – Carnet médical d'un patient
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/chaines.dart';
import '../../constants/couleurs.dart';
import '../../constants/routes.dart';
import '../../models/patient.dart';
import '../../providers/consultation_provider.dart';
import '../../providers/patient_provider.dart';
import '../../providers/suggestion_provider.dart';
import '../../repositories/consultation_repository.dart';
import '../../widgets/commun/dialogue_confirmation.dart';
import '../../widgets/commun/indicateur_chargement.dart';
import '../../widgets/commun/message_vide.dart';
import '../../widgets/patient/bandeau_suggestions.dart';
import '../../widgets/patient/carte_consultation.dart';
import '../../widgets/patient/en_tete_patient.dart';

enum _ActionCarnet { modifier, archiver, basculerRappelUrgent }

class EcranCarnetPatient extends StatefulWidget {
  final int idPatient;

  const EcranCarnetPatient({super.key, required this.idPatient});

  @override
  State<EcranCarnetPatient> createState() => _EcranCarnetPatientState();
}

class _EcranCarnetPatientState extends State<EcranCarnetPatient> {
  Patient? _patient;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _charger());
  }

  Future<void> _charger() async {
    await context.read<PatientProvider>().selectionnerPatient(widget.idPatient);
    _patient = context.read<PatientProvider>().patientSelectionne;
    if (_patient == null) return;

    await context
        .read<ConsultationProvider>()
        .chargerConsultations(widget.idPatient);

    final derniere = await ConsultationRepository()
        .obtenirDerniereConsultation(widget.idPatient);
    if (!mounted) return;
    context.read<SuggestionProvider>().analyserDossier(_patient!, derniere);
    setState(() {});
  }

  /// true si la dernière consultation du patient a le rappel urgent
  /// actif (source de vérité utilisée par le carnet et les
  /// suggestions).
  bool get _rappelUrgentActif {
    final consultations = context.read<ConsultationProvider>().consultations;
    return consultations.isNotEmpty && consultations.first.rappelUrgent;
  }

  Future<void> _archiverPatient() async {
    final bool confirme = await afficherDialogueConfirmation(
      context,
      titre: 'Archiver le dossier',
      message: Chaines.confirmationArchivage,
      libelleConfirmer: Chaines.boutonArchiver,
    );
    if (!confirme || !mounted) return;

    final bool ok = await context
        .read<PatientProvider>()
        .archiverPatient(widget.idPatient);
    if (!mounted) return;
    if (ok) Navigator.pop(context, true);
  }

  /// Bascule le rappel urgent directement depuis la fiche patient,
  /// sans passer par la création d'une nouvelle consultation
  /// (cahier des charges §16.6, BF-04.4).
  Future<void> _basculerRappelUrgent() async {
    if (_patient == null) return;
    final bool nouvelleValeur = !_rappelUrgentActif;

    final bool ok = await context.read<ConsultationProvider>().basculerRappelUrgent(
          widget.idPatient,
          _patient!.obtenirNomComplet(),
          nouvelleValeur,
        );
    if (!mounted || !ok) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          nouvelleValeur
              ? Chaines.succesRappelUrgentActive
              : Chaines.succesRappelUrgentDesactive,
        ),
      ),
    );
    // Rafraîchit le bandeau de suggestions pour refléter le changement.
    await _charger();
  }

  @override
  Widget build(BuildContext context) {
    if (_patient == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(Chaines.titreCarnet)),
        body: const IndicateurChargement(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_patient!.obtenirNomComplet()),
        actions: [
          Consumer<ConsultationProvider>(
            builder: (context, consultProvider, _) {
              final bool rappelUrgentActif = consultProvider
                      .consultations.isNotEmpty &&
                  consultProvider.consultations.first.rappelUrgent;

              return PopupMenuButton<_ActionCarnet>(
                onSelected: (action) {
                  switch (action) {
                    case _ActionCarnet.modifier:
                      Navigator.pushNamed(
                        context,
                        Routes.modificationPatient,
                        arguments: _patient,
                      ).then((modifie) {
                        if (modifie == true) _charger();
                      });
                      break;
                    case _ActionCarnet.archiver:
                      _archiverPatient();
                      break;
                    case _ActionCarnet.basculerRappelUrgent:
                      _basculerRappelUrgent();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: _ActionCarnet.modifier,
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text(Chaines.boutonModifier),
                    ),
                  ),
                  const PopupMenuItem(
                    value: _ActionCarnet.archiver,
                    child: ListTile(
                      leading: Icon(Icons.archive_outlined),
                      title: Text(Chaines.boutonArchiver),
                    ),
                  ),
                  PopupMenuItem(
                    value: _ActionCarnet.basculerRappelUrgent,
                    child: ListTile(
                      leading: Icon(
                        rappelUrgentActif
                            ? Icons.notifications_off_outlined
                            : Icons.priority_high,
                        color: rappelUrgentActif ? null : Couleurs.urgence,
                      ),
                      title: Text(
                        rappelUrgentActif
                            ? Chaines.menuDesactiverRappelUrgent
                            : Chaines.menuActiverRappelUrgent,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _charger,
        child: Consumer2<ConsultationProvider, SuggestionProvider>(
          builder: (context, consultProvider, suggestionProvider, _) {
            if (consultProvider.enChargement &&
                consultProvider.consultations.isEmpty) {
              return const IndicateurChargement();
            }

            return ListView(
              children: [
                EnTetePatient(patient: _patient!),
                BandeauSuggestions(
                  suggestions: suggestionProvider.suggestions,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Historique des consultations',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                if (consultProvider.consultations.isEmpty)
                  SizedBox(
                    height: 200,
                    child: MessageVide(
                      icone: Icons.medical_information_outlined,
                      message: Chaines.aucuneConsultation,
                      libelleAction: Chaines.boutonNouvelleConsult,
                      onAction: () => Navigator.pushNamed(
                        context,
                        Routes.formulaireConsultation,
                        arguments: widget.idPatient,
                      ).then((_) => _charger()),
                    ),
                  )
                else
                  ...consultProvider.consultations.map(
                    (c) => CarteConsultation(
                      consultation: c,
                      onTap: () => Navigator.pushNamed(
                        context,
                        Routes.detailConsultation,
                        arguments: {
                          'idConsultation': c.idConsultation!,
                          'idPatient': widget.idPatient,
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: 80),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(
          context,
          Routes.formulaireConsultation,
          arguments: widget.idPatient,
        ).then((_) => _charger()),
        icon: const Icon(Icons.add),
        label: const Text(Chaines.boutonNouvelleConsult),
      ),
    );
  }
}
