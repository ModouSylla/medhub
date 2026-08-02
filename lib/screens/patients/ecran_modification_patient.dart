// ============================================================
// ecran_modification_patient.dart – Modification d'un patient
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/chaines.dart';
import '../../constants/dimensions.dart';
import '../../models/patient.dart';
import '../../providers/patient_provider.dart';
import '../../utils/date_utils.dart';
import '../../utils/validateurs.dart';
import '../../widgets/commun/bouton_primaire.dart';
import '../../widgets/commun/dialogue_confirmation.dart';

class EcranModificationPatient extends StatefulWidget {
  final Patient patient;

  const EcranModificationPatient({super.key, required this.patient});

  @override
  State<EcranModificationPatient> createState() =>
      _EcranModificationPatientState();
}

class _EcranModificationPatientState extends State<EcranModificationPatient> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomCtrl;
  late final TextEditingController _prenomCtrl;
  late final TextEditingController _telCtrl;
  late final TextEditingController _adresseCtrl;
  late final TextEditingController _allergiesCtrl;
  late final TextEditingController _antPersoCtrl;
  late final TextEditingController _antFamCtrl;

  late String _sexe;
  String? _groupeSanguin;
  late DateTime _dateNaissance;

  static const List<String> _groupesSanguins = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.patient;
    _nomCtrl = TextEditingController(text: p.nom);
    _prenomCtrl = TextEditingController(text: p.prenom);
    _telCtrl = TextEditingController(text: p.telephone);
    _adresseCtrl = TextEditingController(text: p.adresse ?? '');
    _allergiesCtrl = TextEditingController(text: p.allergies ?? '');
    _antPersoCtrl =
        TextEditingController(text: p.antecedentsPersonnels ?? '');
    _antFamCtrl =
        TextEditingController(text: p.antecedentsFamiliaux ?? '');
    _sexe = p.sexe;
    _groupeSanguin = p.groupeSanguin;
    _dateNaissance = DateTime.parse(p.dateNaissance);
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _telCtrl.dispose();
    _adresseCtrl.dispose();
    _allergiesCtrl.dispose();
    _antPersoCtrl.dispose();
    _antFamCtrl.dispose();
    super.dispose();
  }

  Future<void> _choisirDateNaissance() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _dateNaissance,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
    );
    if (date != null) setState(() => _dateNaissance = date);
  }

  Future<void> _enregistrer() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final patient = widget.patient.copierAvec(
      nom: _nomCtrl.text.trim(),
      prenom: _prenomCtrl.text.trim(),
      dateNaissance: AppDateUtils.dateVersIso(_dateNaissance),
      sexe: _sexe,
      telephone: _telCtrl.text.trim(),
      adresse: _adresseCtrl.text.trim().isEmpty
          ? null
          : _adresseCtrl.text.trim(),
      groupeSanguin: _groupeSanguin,
      allergies: _allergiesCtrl.text.trim().isEmpty
          ? null
          : _allergiesCtrl.text.trim(),
      antecedentsPersonnels: _antPersoCtrl.text.trim().isEmpty
          ? null
          : _antPersoCtrl.text.trim(),
      antecedentsFamiliaux: _antFamCtrl.text.trim().isEmpty
          ? null
          : _antFamCtrl.text.trim(),
    );

    final bool ok =
        await context.read<PatientProvider>().mettreAJourPatient(patient);
    if (!mounted) return;
    if (ok) Navigator.pop(context, true);
  }

  Future<void> _archiver() async {
    final bool confirme = await afficherDialogueConfirmation(
      context,
      titre: 'Archiver le dossier',
      message: Chaines.confirmationArchivage,
      libelleConfirmer: Chaines.boutonArchiver,
    );
    if (!confirme || !mounted) return;

    final bool ok = await context
        .read<PatientProvider>()
        .archiverPatient(widget.patient.idPatient!);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, true);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier le patient')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.paddingMoyen),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomCtrl,
                decoration: const InputDecoration(labelText: Chaines.champNom),
                validator: Validateurs.validerNom,
              ),
              const SizedBox(height: Dimensions.paddingMoyen),
              TextFormField(
                controller: _prenomCtrl,
                decoration:
                    const InputDecoration(labelText: Chaines.champPrenom),
                validator: Validateurs.validerNom,
              ),
              const SizedBox(height: Dimensions.paddingMoyen),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  AppDateUtils.formaterDateCourte(
                    AppDateUtils.dateVersIso(_dateNaissance),
                  ),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _choisirDateNaissance,
              ),
              const SizedBox(height: Dimensions.paddingMoyen),
              DropdownButtonFormField<String>(
                value: _sexe,
                decoration:
                    const InputDecoration(labelText: Chaines.champSexe),
                items: const [
                  DropdownMenuItem(value: 'M', child: Text('Masculin')),
                  DropdownMenuItem(value: 'F', child: Text('Féminin')),
                  DropdownMenuItem(value: 'Autre', child: Text('Autre')),
                ],
                onChanged: (v) => setState(() => _sexe = v!),
              ),
              const SizedBox(height: Dimensions.paddingMoyen),
              TextFormField(
                controller: _telCtrl,
                keyboardType: TextInputType.phone,
                decoration:
                    const InputDecoration(labelText: Chaines.champTelephone),
                validator: Validateurs.validerTelephone,
              ),
              const SizedBox(height: Dimensions.paddingMoyen),
              TextFormField(
                controller: _adresseCtrl,
                decoration:
                    const InputDecoration(labelText: Chaines.champAdresse),
              ),
              const SizedBox(height: Dimensions.paddingMoyen),
              DropdownButtonFormField<String?>(
                value: _groupeSanguin,
                decoration: const InputDecoration(
                  labelText: Chaines.champGroupeSanguin,
                ),
                items: [
                  const DropdownMenuItem<String?>(value: null, child: Text('—')),
                  ..._groupesSanguins.map(
                    (g) => DropdownMenuItem<String?>(value: g, child: Text(g)),
                  ),
                ],
                onChanged: (v) => setState(() => _groupeSanguin = v),
              ),
              const SizedBox(height: Dimensions.paddingMoyen),
              TextFormField(
                controller: _allergiesCtrl,
                decoration:
                    const InputDecoration(labelText: Chaines.champAllergies),
                maxLines: 2,
              ),
              const SizedBox(height: Dimensions.paddingMoyen),
              TextFormField(
                controller: _antPersoCtrl,
                decoration: const InputDecoration(
                  labelText: Chaines.champAntecedentsPerso,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: Dimensions.paddingMoyen),
              TextFormField(
                controller: _antFamCtrl,
                decoration: const InputDecoration(
                  labelText: Chaines.champAntecedentsFamil,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: Dimensions.paddingGrand),
              BoutonPrimaire(
                libelle: Chaines.boutonEnregistrer,
                onPressed: _enregistrer,
              ),
              const SizedBox(height: Dimensions.paddingMoyen),
              OutlinedButton(
                onPressed: _archiver,
                child: const Text(Chaines.boutonArchiver),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
