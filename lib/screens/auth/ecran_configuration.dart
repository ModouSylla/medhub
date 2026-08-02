// ============================================================
// ecran_configuration.dart – Configuration initiale (Stepper)
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/chaines.dart';
import '../../constants/couleurs.dart';
import '../../constants/dimensions.dart';
import '../../constants/routes.dart';
import '../../models/profil_medecin.dart';
import '../../models/definition_constante.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profil_provider.dart';
import '../../repositories/definition_constante_repository.dart';
import '../../utils/date_utils.dart';
import '../../utils/exceptions.dart';
import '../../utils/validateurs.dart';
import '../../widgets/commun/bouton_primaire.dart';

class EcranConfiguration extends StatefulWidget {
  const EcranConfiguration({super.key});

  @override
  State<EcranConfiguration> createState() => _EcranConfigurationState();
}

class _EcranConfigurationState extends State<EcranConfiguration> {
  int _etapeActive = 0;

  // Contrôleurs pour les champs de texte
  final _nomCtrl       = TextEditingController();
  final _prenomCtrl    = TextEditingController();
  final _specialiteCtrl= TextEditingController();
  final _ordreCtrl     = TextEditingController();
  final _pinCtrl       = TextEditingController();
  final _confirmCtrl   = TextEditingController();

  // Clés de formulaire pour chaque étape
  final _cle1 = GlobalKey<FormState>();
  final _cle2 = GlobalKey<FormState>();
  final _cle3 = GlobalKey<FormState>();

  TypeProfil _profilChoisi = TypeProfil.generaliste;
  bool       _pinVisible   = false;

  // Constantes personnalisées (profil personnalisé)
  final List<Map<String, String>> _constantesPerso = [];
  final _libellePCtrl = TextEditingController();
  final _unitePCtrl   = TextEditingController();
  String _typePValeur = 'numerique';

  @override
  void dispose() {
    _nomCtrl.dispose(); _prenomCtrl.dispose(); _specialiteCtrl.dispose();
    _ordreCtrl.dispose(); _pinCtrl.dispose(); _confirmCtrl.dispose();
    _libellePCtrl.dispose(); _unitePCtrl.dispose();
    super.dispose();
  }

  // ── Navigation entre étapes ───────────────────────────────

  void _etapeSuivante() {
    bool valide = false;
    if (_etapeActive == 0) valide = _cle1.currentState?.validate() ?? false;
    if (_etapeActive == 1) valide = true; // Profil toujours valide
    if (valide) setState(() => _etapeActive++);
  }

  void _etapePrecedente() {
    if (_etapeActive > 0) setState(() => _etapeActive--);
  }

  // ── Finalisation de la configuration ─────────────────────

  Future<void> _terminer() async {
    if (!(_cle3.currentState?.validate() ?? false)) return;

    final ProfilMedecin profil = ProfilMedecin(
      nomMedecin:     _nomCtrl.text.trim(),
      prenomMedecin:  _prenomCtrl.text.trim(),
      specialite:     _specialiteCtrl.text.trim(),
      profilMedical:  _profilChoisi,
      numeroOrdre:    _ordreCtrl.text.trim().isEmpty ? null : _ordreCtrl.text.trim(),
      codePinHash:    '', // Sera défini par AuthProvider
    );

    try {
      // Sauvegarder le profil avec le PIN hashé
      final bool succes = await context
          .read<AuthProvider>()
          .definirPin(_pinCtrl.text, profil);

      if (!succes) {
        if (mounted) {
          final String? messageErreur =
              context.read<AuthProvider>().messageErreur;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(messageErreur ?? "Impossible d'enregistrer le profil."),
            backgroundColor: Couleurs.urgence,
          ));
        }
        return;
      }

      // Sauvegarder les constantes personnalisées si nécessaire
      if (_profilChoisi == TypeProfil.personnalise) {
        final repo = DefinitionConstanteRepository();
        for (int i = 0; i < _constantesPerso.length; i++) {
          await repo.insererDefinition(DefinitionConstante(
            libelle:       _constantesPerso[i]['libelle']!,
            unite:         _constantesPerso[i]['unite'],
            typeValeur:    _constantesPerso[i]['type']!,
            profilMedical: 'personnalise',
            ordreAffichage: i + 1,
          ));
        }
      }

      // Marquer la configuration comme effectuée
      await context.read<ProfilProvider>().marquerConfigurationEffectuee();

      if (mounted) {
        Navigator.of(context).pushReplacementNamed(Routes.accueil);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e is RepositoryException
              ? e.message
              : 'Une erreur est survenue lors de la configuration.'),
          backgroundColor: Couleurs.urgence,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(Chaines.titreConfiguration)),
      body: Stepper(
        currentStep: _etapeActive,
        onStepCancel: _etapePrecedente,
        onStepContinue: _etapeActive < 2 ? _etapeSuivante : null,
        controlsBuilder: (context, details) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_etapeActive < 2)
                ElevatedButton(
                  onPressed: _etapeSuivante,
                  child: const Text(Chaines.boutonSuivant),
                ),
              if (_etapeActive == 2)
                BoutonPrimaire(
                  libelle: Chaines.boutonTerminer,
                  onPressed: _terminer,
                ),
              if (_etapeActive > 0)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _etapePrecedente,
                    child: const Text(Chaines.boutonPrecedent),
                  ),
                ),
            ],
          );
        },
        steps: [
          // ── Étape 1 : Informations du médecin ────────────
          Step(
            title: const Text('Vos informations'),
            isActive: _etapeActive >= 0,
            state: _etapeActive > 0
                ? StepState.complete
                : StepState.indexed,
            content: Form(
              key: _cle1,
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
                        labelText: 'N° d\'ordre (optionnel)'),
                  ),
                ],
              ),
            ),
          ),

          // ── Étape 2 : Profil médical ──────────────────────
          Step(
            title: const Text('Profil médical'),
            isActive: _etapeActive >= 1,
            state: _etapeActive > 1
                ? StepState.complete
                : StepState.indexed,
            content: Form(
              key: _cle2,
              child: Column(
                children: [
                  ...TypeProfil.values.map((profil) => RadioListTile<TypeProfil>(
                    title: Text(profil.obtenirLibelle()),
                    value: profil,
                    groupValue: _profilChoisi,
                    onChanged: (v) => setState(() => _profilChoisi = v!),
                    activeColor: Couleurs.primaire,
                  )),
                  // Champs personnalisés si profil = Personnalisé
                  if (_profilChoisi == TypeProfil.personnalise) ...[
                    const Divider(),
                    const Text('Définir vos constantes :'),
                    ..._constantesPerso.map((c) => ListTile(
                      title: Text(c['libelle']!),
                      subtitle: Text('${c['unite'] ?? ''} • ${c['type']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Couleurs.urgence),
                        onPressed: () => setState(
                            () => _constantesPerso.remove(c)),
                      ),
                    )),
                    Row(children: [
                      Expanded(
                        child: TextFormField(
                          controller: _libellePCtrl,
                          decoration: const InputDecoration(labelText: 'Libellé'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _unitePCtrl,
                          decoration: const InputDecoration(labelText: 'Unité'),
                        ),
                      ),
                    ]),
                    DropdownButton<String>(
                      value: _typePValeur,
                      items: const [
                        DropdownMenuItem(value: 'numerique', child: Text('Numérique')),
                        DropdownMenuItem(value: 'texte', child: Text('Texte libre')),
                      ],
                      onChanged: (v) => setState(() => _typePValeur = v!),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter ce champ'),
                      onPressed: () {
                        if (_libellePCtrl.text.trim().isNotEmpty) {
                          setState(() {
                            _constantesPerso.add({
                              'libelle': _libellePCtrl.text.trim(),
                              'unite':   _unitePCtrl.text.trim(),
                              'type':    _typePValeur,
                            });
                            _libellePCtrl.clear();
                            _unitePCtrl.clear();
                          });
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── Étape 3 : Code PIN ────────────────────────────
          Step(
            title: const Text('Code de sécurité'),
            isActive: _etapeActive >= 2,
            content: Form(
              key: _cle3,
              child: Column(
                children: [
                  TextFormField(
                    controller: _pinCtrl,
                    obscureText: !_pinVisible,
                    keyboardType: TextInputType.number,
                    maxLength: 8,
                    decoration: InputDecoration(
                      labelText: 'Code PIN (4-8 chiffres) *',
                      suffixIcon: IconButton(
                        icon: Icon(_pinVisible
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () =>
                            setState(() => _pinVisible = !_pinVisible),
                      ),
                    ),
                    validator: Validateurs.validerPin,
                  ),
                  const SizedBox(height: Dimensions.paddingMoyen),
                  TextFormField(
                    controller: _confirmCtrl,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 8,
                    decoration: const InputDecoration(
                        labelText: 'Confirmer le code PIN *'),
                    validator: (v) => Validateurs.validerConfirmationPin(
                        _pinCtrl.text, v),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
