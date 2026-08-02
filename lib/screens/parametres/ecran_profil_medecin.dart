// ============================================================
// ecran_profil_medecin.dart – Édition du profil médecin
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/chaines.dart';
import '../../constants/dimensions.dart';
import '../../constants/routes.dart';
import '../../models/profil_medecin.dart';
import '../../providers/profil_provider.dart';
import '../../repositories/definition_constante_repository.dart';
import '../../utils/validateurs.dart';
import '../../widgets/commun/bouton_primaire.dart';
import '../../widgets/commun/dialogue_confirmation.dart';

class EcranProfilMedecin extends StatefulWidget {
  const EcranProfilMedecin({super.key});

  @override
  State<EcranProfilMedecin> createState() => _EcranProfilMedecinState();
}

class _EcranProfilMedecinState extends State<EcranProfilMedecin> {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  final _prenomCtrl = TextEditingController();
  final _specialiteCtrl = TextEditingController();
  final _ordreCtrl = TextEditingController();

  TypeProfil _profilMedical = TypeProfil.generaliste;
  ProfilMedecin? _profilInitial;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _charger());
  }

  Future<void> _charger() async {
    await context.read<ProfilProvider>().chargerProfil();
    final profil = context.read<ProfilProvider>().profil;
    if (profil == null) return;

    _profilInitial = profil;
    _nomCtrl.text = profil.nomMedecin;
    _prenomCtrl.text = profil.prenomMedecin;
    _specialiteCtrl.text = profil.specialite;
    _ordreCtrl.text = profil.numeroOrdre ?? '';
    _profilMedical = profil.profilMedical;
    setState(() {});
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _specialiteCtrl.dispose();
    _ordreCtrl.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_profilInitial == null) return;

    final bool changePersonnalise =
        _profilMedical == TypeProfil.personnalise &&
            _profilInitial!.profilMedical != TypeProfil.personnalise;

    final profil = _profilInitial!.copierAvec(
      nomMedecin: _nomCtrl.text.trim(),
      prenomMedecin: _prenomCtrl.text.trim(),
      specialite: _specialiteCtrl.text.trim(),
      numeroOrdre: _ordreCtrl.text.trim().isEmpty
          ? null
          : _ordreCtrl.text.trim(),
      profilMedical: _profilMedical,
    );

    final ok =
        await context.read<ProfilProvider>().sauvegarderProfil(profil);
    if (!mounted) return;
    if (!ok) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil mis à jour.')),
    );

    // Le médecin vient de (re)choisir le profil "Personnalisé" : on lui
    // propose de définir/redéfinir ses constantes tout de suite, comme
    // il l'aurait fait pendant la configuration initiale.
    if (changePersonnalise) {
      final repo = DefinitionConstanteRepository();
      final existantes =
          await repo.obtenirDefinitionsParProfil('personnalise');
      if (!mounted) return;
      if (existantes.isEmpty) {
        final bool configurer = await afficherDialogueConfirmation(
          context,
          titre: Chaines.titreConstantesPersonnalisees,
          message: Chaines.confirmationReconfigurationConstantes,
          libelleConfirmer: Chaines.boutonConfigurerConstantes,
          libelleAnnuler: 'Plus tard',
        );
        if (configurer && mounted) {
          await Navigator.pushNamed(
            context,
            Routes.constantesPersonnalisees,
          );
        }
      }
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_profilInitial == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mon profil')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mon profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.paddingMoyen),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomCtrl,
                decoration: const InputDecoration(labelText: 'Nom *'),
                validator: Validateurs.validerNom,
              ),
              const SizedBox(height: Dimensions.paddingMoyen),
              TextFormField(
                controller: _prenomCtrl,
                decoration: const InputDecoration(labelText: 'Prénom *'),
                validator: Validateurs.validerNom,
              ),
              const SizedBox(height: Dimensions.paddingMoyen),
              TextFormField(
                controller: _specialiteCtrl,
                decoration: const InputDecoration(labelText: 'Spécialité *'),
                validator: Validateurs.validerChampObligatoire,
              ),
              const SizedBox(height: Dimensions.paddingMoyen),
              TextFormField(
                controller: _ordreCtrl,
                decoration: const InputDecoration(
                  labelText: 'N° d\'ordre (optionnel)',
                ),
              ),
              const SizedBox(height: Dimensions.paddingMoyen),
              DropdownButtonFormField<TypeProfil>(
                value: _profilMedical,
                decoration: const InputDecoration(labelText: 'Profil médical'),
                items: TypeProfil.values
                    .map(
                      (p) => DropdownMenuItem(
                        value: p,
                        child: Text(p.obtenirLibelle()),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _profilMedical = v!),
              ),
              if (_profilMedical == TypeProfil.personnalise) ...[
                const SizedBox(height: Dimensions.paddingMoyen),
                OutlinedButton.icon(
                  icon: const Icon(Icons.tune),
                  label: const Text(Chaines.titreConstantesPersonnalisees),
                  onPressed: () => Navigator.pushNamed(
                    context,
                    Routes.constantesPersonnalisees,
                  ),
                ),
              ],
              const SizedBox(height: Dimensions.paddingGrand),
              BoutonPrimaire(
                libelle: 'Enregistrer',
                onPressed: _enregistrer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
