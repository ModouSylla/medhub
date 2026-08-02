// ============================================================
// ecran_formulaire_consultation.dart – Nouvelle consultation
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/chaines.dart';
import '../../constants/dimensions.dart';
import '../../models/consultation.dart';
import '../../models/constante_consultation.dart';
import '../../providers/consultation_provider.dart';
import '../../providers/profil_provider.dart';
import '../../models/profil_medecin.dart';
import '../../utils/date_utils.dart';
import '../../utils/validateurs.dart';
import '../../widgets/commun/bouton_primaire.dart';
import '../../widgets/constantes/champ_constante.dart';

class EcranFormulaireConsultation extends StatefulWidget {
  final int idPatient;

  const EcranFormulaireConsultation({super.key, required this.idPatient});

  @override
  State<EcranFormulaireConsultation> createState() =>
      _EcranFormulaireConsultationState();
}

class _EcranFormulaireConsultationState
    extends State<EcranFormulaireConsultation> {
  final _formKey = GlobalKey<FormState>();
  final _diagnosticCtrl = TextEditingController();
  final _traitementCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final Map<int, TextEditingController> _constantesCtrl = {};

  DateTime _dateConsultation = DateTime.now();
  bool _examenEnAttente = false;
  bool _rappelUrgent = false;
  bool _definitionsChargees = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _chargerDefinitions());
  }

  Future<void> _chargerDefinitions() async {
    await context.read<ProfilProvider>().chargerProfil();
    final profil = context.read<ProfilProvider>().profil;
    if (profil == null) return;

    await context
        .read<ConsultationProvider>()
        .chargerDefinitions(profil.profilMedical.versChaine());

    for (final def in context.read<ConsultationProvider>().definitions) {
      if (def.idDefinition != null) {
        _constantesCtrl[def.idDefinition!] = TextEditingController();
      }
    }
    setState(() => _definitionsChargees = true);
  }

  @override
  void dispose() {
    _diagnosticCtrl.dispose();
    _traitementCtrl.dispose();
    _notesCtrl.dispose();
    for (final c in _constantesCtrl.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _choisirDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _dateConsultation,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
    );
    if (date != null) setState(() => _dateConsultation = date);
  }

  Future<void> _enregistrer() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final consultation = Consultation(
      idPatient: widget.idPatient,
      dateConsultation: AppDateUtils.dateVersIso(_dateConsultation),
      diagnostic: _diagnosticCtrl.text.trim(),
      traitement: _traitementCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      examenEnAttente: _examenEnAttente,
      rappelUrgent: _rappelUrgent,
      dateCreation: AppDateUtils.maintenant(),
    );

    final List<ConstanteConsultation> constantes = [];
    for (final def in context.read<ConsultationProvider>().definitions) {
      if (def.idDefinition == null) continue;
      final ctrl = _constantesCtrl[def.idDefinition!];
      if (ctrl == null || ctrl.text.trim().isEmpty) continue;
      constantes.add(ConstanteConsultation(
        idConsultation: 0,
        idDefinition: def.idDefinition!,
        valeur: ctrl.text.trim(),
        definition: def,
      ));
    }

    final bool ok = await context
        .read<ConsultationProvider>()
        .enregistrerConsultation(consultation, constantes);

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(Chaines.succesConsultation)),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final definitions =
        context.watch<ConsultationProvider>().definitions;

    return Scaffold(
      appBar: AppBar(title: const Text(Chaines.titreNouvelleConsult)),
      body: !_definitionsChargees
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(Dimensions.paddingMoyen),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Date de consultation'),
                      subtitle: Text(
                        AppDateUtils.formaterDateLongue(
                          AppDateUtils.dateVersIso(_dateConsultation),
                        ),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _choisirDate,
                    ),
                    const SizedBox(height: Dimensions.paddingMoyen),
                    if (definitions.isNotEmpty) ...[
                      Text(
                        'Constantes vitales',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      ...definitions.map((def) {
                        if (def.idDefinition == null) {
                          return const SizedBox.shrink();
                        }
                        return ChampConstante(
                          definition: def,
                          controller: _constantesCtrl[def.idDefinition!]!,
                        );
                      }),
                      const Divider(height: 32),
                    ],
                    TextFormField(
                      controller: _diagnosticCtrl,
                      decoration: const InputDecoration(
                        labelText: Chaines.champDiagnostic,
                      ),
                      maxLines: 3,
                      validator: Validateurs.validerDiagnostic,
                    ),
                    const SizedBox(height: Dimensions.paddingMoyen),
                    TextFormField(
                      controller: _traitementCtrl,
                      decoration: const InputDecoration(
                        labelText: Chaines.champTraitement,
                      ),
                      maxLines: 3,
                      validator: Validateurs.validerTraitement,
                    ),
                    const SizedBox(height: Dimensions.paddingMoyen),
                    TextFormField(
                      controller: _notesCtrl,
                      decoration: const InputDecoration(
                        labelText: Chaines.champNotes,
                      ),
                      maxLines: 2,
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(Chaines.champExamenEnAttente),
                      value: _examenEnAttente,
                      onChanged: (v) => setState(() => _examenEnAttente = v),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(Chaines.champRappelUrgent),
                      value: _rappelUrgent,
                      onChanged: (v) => setState(() => _rappelUrgent = v),
                    ),
                    const SizedBox(height: Dimensions.paddingGrand),
                    Consumer<ConsultationProvider>(
                      builder: (context, provider, _) => BoutonPrimaire(
                        libelle: Chaines.boutonEnregistrer,
                        enChargement: provider.enChargement,
                        onPressed: _enregistrer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
