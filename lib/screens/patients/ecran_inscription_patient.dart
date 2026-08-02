// ============================================================
// ecran_inscription_patient.dart – Formulaire d'inscription patient
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

class EcranInscriptionPatient extends StatefulWidget {
  const EcranInscriptionPatient({super.key});

  @override
  State<EcranInscriptionPatient> createState() =>
      _EcranInscriptionPatientState();
}

class _EcranInscriptionPatientState extends State<EcranInscriptionPatient> {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  final _prenomCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _adresseCtrl = TextEditingController();
  final _allergiesCtrl = TextEditingController();
  final _antPersoCtrl = TextEditingController();
  final _antFamCtrl = TextEditingController();

  String _sexe = 'M';
  String? _groupeSanguin;
  DateTime? _dateNaissance;

  static const List<String> _groupesSanguins = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-',
  ];

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
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
    );
    if (date != null) setState(() => _dateNaissance = date);
  }

  Future<void> _enregistrer() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final erreurDate = Validateurs.validerDateNaissance(_dateNaissance);
    if (erreurDate != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erreurDate)),
      );
      return;
    }

    await context.read<PatientProvider>().verifierDoublon(
          _nomCtrl.text.trim(),
          _telCtrl.text.trim(),
        );
    if (!mounted) return;
    if (context.read<PatientProvider>().doublon) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Un patient avec ce nom et ce téléphone existe déjà.',
          ),
        ),
      );
      return;
    }

    final patient = Patient(
      nom: _nomCtrl.text.trim(),
      prenom: _prenomCtrl.text.trim(),
      dateNaissance: AppDateUtils.dateVersIso(_dateNaissance!),
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
      dateCreation: AppDateUtils.maintenant(),
    );

    final bool ok =
        await context.read<PatientProvider>().inscrirePatient(patient);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(Chaines.succesPatient)),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(Chaines.titreNouveauPatient)),
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
                  _dateNaissance == null
                      ? Chaines.champDateNaissance
                      : AppDateUtils.formaterDateCourte(
                          AppDateUtils.dateVersIso(_dateNaissance!),
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
              Consumer<PatientProvider>(
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
