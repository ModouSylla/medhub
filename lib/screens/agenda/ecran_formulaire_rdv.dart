// ============================================================
// ecran_formulaire_rdv.dart – Création / modification RDV
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/chaines.dart';
import '../../constants/dimensions.dart';
import '../../models/rendez_vous.dart';
import '../../providers/agenda_provider.dart';
import '../../providers/patient_provider.dart';
import '../../utils/date_utils.dart';
import '../../utils/validateurs.dart';
import '../../widgets/commun/bouton_primaire.dart';
import '../../widgets/commun/dialogue_confirmation.dart';

class EcranFormulaireRdv extends StatefulWidget {
  final RendezVous? rdvExistant;
  final int? idPatient;
  final DateTime? dateInitiale;

  const EcranFormulaireRdv({
    super.key,
    this.rdvExistant,
    this.idPatient,
    this.dateInitiale,
  });

  @override
  State<EcranFormulaireRdv> createState() => _EcranFormulaireRdvState();
}

class _EcranFormulaireRdvState extends State<EcranFormulaireRdv> {
  final _formKey = GlobalKey<FormState>();
  final _motifCtrl = TextEditingController();

  late DateTime _date;
  late TimeOfDay _heureDebut;
  late TimeOfDay _heureFin;
  int? _idPatientSelectionne;
  bool _estBlocage = false;
  StatutRendezVous _statut = StatutRendezVous.planifie;

  bool get _estModification => widget.rdvExistant != null;

  @override
  void initState() {
    super.initState();
    final rdv = widget.rdvExistant;
    if (rdv != null) {
      _date = DateTime.parse(rdv.dateHeure);
      _heureDebut = AppDateUtils.chaineVersTimeOfDay(rdv.heureDebut);
      _heureFin = AppDateUtils.chaineVersTimeOfDay(rdv.heureFin);
      _idPatientSelectionne = rdv.idPatient;
      _estBlocage = rdv.estBlocage;
      _statut = rdv.statut;
      _motifCtrl.text = rdv.motif ?? '';
    } else {
      _date = widget.dateInitiale ?? DateTime.now();
      _heureDebut = const TimeOfDay(hour: 9, minute: 0);
      _heureFin = const TimeOfDay(hour: 9, minute: 30);
      _idPatientSelectionne = widget.idPatient;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientProvider>().chargerPatients();
    });
  }

  @override
  void dispose() {
    _motifCtrl.dispose();
    super.dispose();
  }

  Future<void> _choisirDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('fr', 'FR'),
    );
    if (date != null) setState(() => _date = date);
  }

  Future<void> _choisirHeure(bool debut) async {
    final TimeOfDay? heure = await showTimePicker(
      context: context,
      initialTime: debut ? _heureDebut : _heureFin,
    );
    if (heure != null) {
      setState(() {
        if (debut) {
          _heureDebut = heure;
        } else {
          _heureFin = heure;
        }
      });
    }
  }

  Future<void> _enregistrer() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_estBlocage && _idPatientSelectionne == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un patient.')),
      );
      return;
    }

    final String dateIso = AppDateUtils.dateVersIso(_date);
    final String debut = AppDateUtils.timeOfDayVersChaine(_heureDebut);
    final String fin = AppDateUtils.timeOfDayVersChaine(_heureFin);

    final conflits = await context.read<AgendaProvider>().verifierConflits(
          dateIso,
          debut,
          fin,
          excludeId: widget.rdvExistant?.idRendezVous,
        );
    if (conflits.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(Chaines.alerteConflit)),
      );
      return;
    }

    final rdv = RendezVous(
      idRendezVous: widget.rdvExistant?.idRendezVous,
      idPatient: _estBlocage ? null : _idPatientSelectionne,
      dateHeure: dateIso,
      heureDebut: debut,
      heureFin: fin,
      motif: _motifCtrl.text.trim().isEmpty ? null : _motifCtrl.text.trim(),
      statut: _statut,
      estBlocage: _estBlocage,
      idNotification: widget.rdvExistant?.idNotification,
      dateCreation: widget.rdvExistant?.dateCreation ?? AppDateUtils.maintenant(),
    );

    final bool ok = _estModification
        ? await context.read<AgendaProvider>().modifierRendezVous(rdv)
        : await context.read<AgendaProvider>().creerRendezVous(rdv);

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _estModification
                ? Chaines.succesRdvModifie
                : Chaines.succesRdvCree,
          ),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  Future<void> _annuler() async {
    final rdv = widget.rdvExistant;
    if (rdv?.idRendezVous == null) return;

    final bool confirme = await afficherDialogueConfirmation(
      context,
      titre: Chaines.boutonAnnulerRdv,
      message: Chaines.confirmationAnnulationRdv,
      libelleConfirmer: Chaines.boutonConfirmer,
    );
    if (!confirme || !mounted) return;

    final bool ok = await context.read<AgendaProvider>().annulerRendezVous(
          rdv!.idRendezVous!,
          rdv.idNotification,
        );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(Chaines.succesRdvAnnule)),
      );
      Navigator.pop(context, true);
    } else {
      final String? erreur = context.read<AgendaProvider>().messageErreur;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erreur ?? Chaines.erreurGenerique)),
      );
      context.read<AgendaProvider>().effacerErreur();
    }
  }

  @override
  Widget build(BuildContext context) {
    final patients = context.watch<PatientProvider>().listePatients;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _estModification
              ? Chaines.titreModifierRdv
              : Chaines.titreNouveauRdv,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.paddingMoyen),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Bloquer une plage horaire'),
                value: _estBlocage,
                onChanged: (v) => setState(() => _estBlocage = v),
              ),
              if (!_estBlocage)
                DropdownButtonFormField<int>(
                  value: _idPatientSelectionne,
                  decoration: const InputDecoration(labelText: 'Patient *'),
                  items: patients
                      .where((p) => p.idPatient != null)
                      .map(
                        (p) => DropdownMenuItem(
                          value: p.idPatient,
                          child: Text(p.obtenirNomComplet()),
                        ),
                      )
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _idPatientSelectionne = v),
                  validator: (v) =>
                      _estBlocage ? null : (v == null ? 'Obligatoire' : null),
                ),
              const SizedBox(height: Dimensions.paddingMoyen),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(Chaines.champDateRdv),
                subtitle: Text(AppDateUtils.formaterDateLongue(
                  AppDateUtils.dateVersIso(_date),
                )),
                trailing: const Icon(Icons.calendar_today),
                onTap: _choisirDate,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(Chaines.champHeureDebut),
                subtitle: Text(AppDateUtils.formaterHeure(
                  AppDateUtils.timeOfDayVersChaine(_heureDebut),
                )),
                trailing: const Icon(Icons.access_time),
                onTap: () => _choisirHeure(true),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(Chaines.champHeureFin),
                subtitle: Text(AppDateUtils.formaterHeure(
                  AppDateUtils.timeOfDayVersChaine(_heureFin),
                )),
                trailing: const Icon(Icons.access_time),
                onTap: () => _choisirHeure(false),
              ),
              FormField<String>(
                validator: (_) => Validateurs.validerHeuresRdv(
                  AppDateUtils.timeOfDayVersChaine(_heureDebut),
                  AppDateUtils.timeOfDayVersChaine(_heureFin),
                ),
                builder: (state) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.errorText != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          state.errorText!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.paddingMoyen),
              TextFormField(
                controller: _motifCtrl,
                decoration: const InputDecoration(labelText: Chaines.champMotif),
                maxLines: 2,
              ),
              if (_estModification) ...[
                const SizedBox(height: Dimensions.paddingMoyen),
                DropdownButtonFormField<StatutRendezVous>(
                  value: _statut,
                  decoration: const InputDecoration(labelText: 'Statut'),
                  items: StatutRendezVous.values
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.obtenirLibelle()),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _statut = v!),
                ),
              ],
              const SizedBox(height: Dimensions.paddingGrand),
              Consumer<AgendaProvider>(
                builder: (context, provider, _) => BoutonPrimaire(
                  libelle: Chaines.boutonEnregistrer,
                  enChargement: provider.enChargement,
                  onPressed: _enregistrer,
                ),
              ),
              if (_estModification &&
                  !_estBlocage &&
                  _statut != StatutRendezVous.annule &&
                  _statut != StatutRendezVous.effectue) ...[
                const SizedBox(height: Dimensions.paddingMoyen),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  onPressed: _annuler,
                  child: const Text(Chaines.boutonAnnulerRdv),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
