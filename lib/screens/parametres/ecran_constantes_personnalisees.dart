// ============================================================
// ecran_constantes_personnalisees.dart – (Re)configuration des
// constantes du profil médical "Personnalisé" depuis les
// Paramètres.
//
// Corrige le point : les constantes personnalisées n'étaient
// définissables que pendant le Stepper de configuration initiale.
// Si un médecin re-choisit "Personnalisé" plus tard (Paramètres →
// Mon profil), il n'avait aucun moyen de les redéfinir. Cet écran
// réutilise DefinitionConstanteRepository.supprimerDefinitionsPersonnalisees()
// (jamais appelée jusqu'ici) avant de réinsérer les nouvelles
// définitions avec insererDefinition().
// ============================================================
import 'package:flutter/material.dart';
import '../../constants/chaines.dart';
import '../../constants/couleurs.dart';
import '../../constants/dimensions.dart';
import '../../models/definition_constante.dart';
import '../../repositories/definition_constante_repository.dart';
import '../../utils/exceptions.dart';
import '../../widgets/commun/bouton_primaire.dart';
import '../../widgets/commun/dialogue_confirmation.dart';
import '../../widgets/commun/indicateur_chargement.dart';
import '../../widgets/commun/message_vide.dart';

class EcranConstantesPersonnalisees extends StatefulWidget {
  const EcranConstantesPersonnalisees({super.key});

  @override
  State<EcranConstantesPersonnalisees> createState() =>
      _EcranConstantesPersonnaliseesState();
}

class _EcranConstantesPersonnaliseesState
    extends State<EcranConstantesPersonnalisees> {
  final DefinitionConstanteRepository _repo = DefinitionConstanteRepository();

  final List<Map<String, String>> _constantes = [];
  final _libelleCtrl = TextEditingController();
  final _uniteCtrl = TextEditingController();
  String _typeValeur = 'numerique';

  bool _enChargement = true;
  bool _enEnregistrement = false;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  @override
  void dispose() {
    _libelleCtrl.dispose();
    _uniteCtrl.dispose();
    super.dispose();
  }

  Future<void> _charger() async {
    setState(() => _enChargement = true);
    try {
      final List<DefinitionConstante> existantes =
          await _repo.obtenirDefinitionsParProfil('personnalise');
      _constantes
        ..clear()
        ..addAll(existantes.map((d) => {
              'libelle': d.libelle,
              'unite': d.unite ?? '',
              'type': d.typeValeur,
            }));
    } catch (e) {
      _erreur = e is RepositoryException
          ? e.message
          : 'Impossible de charger les constantes personnalisées.';
    } finally {
      if (mounted) setState(() => _enChargement = false);
    }
  }

  void _ajouterConstante() {
    if (_libelleCtrl.text.trim().isEmpty) return;
    setState(() {
      _constantes.add({
        'libelle': _libelleCtrl.text.trim(),
        'unite': _uniteCtrl.text.trim(),
        'type': _typeValeur,
      });
      _libelleCtrl.clear();
      _uniteCtrl.clear();
    });
  }

  void _supprimerConstante(int index) {
    setState(() => _constantes.removeAt(index));
  }

  Future<void> _enregistrer() async {
    if (_constantes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ajoutez au moins une constante avant d\'enregistrer.'),
        ),
      );
      return;
    }

    final bool confirme = await afficherDialogueConfirmation(
      context,
      titre: Chaines.titreConstantesPersonnalisees,
      message: Chaines.confirmationRemplacementConstantes,
      libelleConfirmer: Chaines.boutonConfirmer,
    );
    if (!confirme || !mounted) return;

    setState(() => _enEnregistrement = true);
    try {
      // Toute re-configuration remplace intégralement l'ancien jeu de
      // définitions personnalisées (§ cahier des charges : "avant la
      // re-configuration du profil personnalisé").
      await _repo.supprimerDefinitionsPersonnalisees();

      for (int i = 0; i < _constantes.length; i++) {
        final c = _constantes[i];
        await _repo.insererDefinition(DefinitionConstante(
          libelle: c['libelle']!,
          unite: c['unite']!.isEmpty ? null : c['unite'],
          typeValeur: c['type']!,
          profilMedical: 'personnalise',
          ordreAffichage: i + 1,
        ));
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(Chaines.succesConstantesReconfigurees)),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e is RepositoryException ? e.message : Chaines.erreurGenerique,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _enEnregistrement = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(Chaines.titreConstantesPersonnalisees)),
      body: _enChargement
          ? const IndicateurChargement()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(Dimensions.paddingMoyen),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Chaines.messageConstantesPersonnalisees,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Couleurs.texteSecondaire,
                        ),
                  ),
                  const SizedBox(height: Dimensions.paddingGrand),
                  if (_erreur != null)
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: Dimensions.paddingMoyen,
                      ),
                      child: Text(
                        _erreur!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  if (_constantes.isEmpty)
                    const MessageVide(
                      icone: Icons.monitor_heart_outlined,
                      message: Chaines.aucuneConstantePersonnalisee,
                    )
                  else
                    ..._constantes.asMap().entries.map(
                          (entry) => Card(
                            child: ListTile(
                              title: Text(entry.value['libelle']!),
                              subtitle: Text(
                                '${entry.value['unite']!.isEmpty ? 'Sans unité' : entry.value['unite']} '
                                '• ${entry.value['type'] == 'numerique' ? 'Numérique' : 'Texte libre'}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Couleurs.urgence,
                                ),
                                onPressed: () =>
                                    _supprimerConstante(entry.key),
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(height: Dimensions.paddingMoyen),
                  const Divider(),
                  const SizedBox(height: Dimensions.paddingMoyen),
                  Text(
                    'Ajouter une constante',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: Dimensions.paddingMoyen),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _libelleCtrl,
                          decoration:
                              const InputDecoration(labelText: 'Libellé'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _uniteCtrl,
                          decoration:
                              const InputDecoration(labelText: 'Unité'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.paddingMoyen),
                  DropdownButtonFormField<String>(
                    value: _typeValeur,
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: const [
                      DropdownMenuItem(
                        value: 'numerique',
                        child: Text('Numérique'),
                      ),
                      DropdownMenuItem(
                        value: 'texte',
                        child: Text('Texte libre'),
                      ),
                    ],
                    onChanged: (v) => setState(() => _typeValeur = v!),
                  ),
                  const SizedBox(height: Dimensions.paddingMoyen),
                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter ce champ'),
                    onPressed: _ajouterConstante,
                  ),
                  const SizedBox(height: Dimensions.paddingGrand),
                  BoutonPrimaire(
                    libelle: Chaines.boutonEnregistrer,
                    enChargement: _enEnregistrement,
                    onPressed: _enregistrer,
                  ),
                ],
              ),
            ),
    );
  }
}
