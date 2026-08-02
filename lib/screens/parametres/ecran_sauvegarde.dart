// ============================================================
// ecran_sauvegarde.dart – Export et restauration de la BDD
// ============================================================
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path_lib;
import 'package:path_provider/path_provider.dart';
import '../../constants/chaines.dart';
import '../../constants/dimensions.dart';
import '../../services/sauvegarde_service.dart';
import '../../widgets/commun/bouton_primaire.dart';
import '../../widgets/commun/dialogue_confirmation.dart';

class EcranSauvegarde extends StatefulWidget {
  const EcranSauvegarde({super.key});

  @override
  State<EcranSauvegarde> createState() => _EcranSauvegardeState();
}

class _EcranSauvegardeState extends State<EcranSauvegarde> {
  final SauvegardeService _service = SauvegardeService();
  List<FileSystemEntity> _sauvegardes = [];
  bool _enChargement = false;

  @override
  void initState() {
    super.initState();
    _listerSauvegardes();
  }

  Future<void> _listerSauvegardes() async {
    final Directory docs = await getApplicationDocumentsDirectory();
    final Directory dossier =
        Directory(path_lib.join(docs.path, 'MediHub'));
    if (await dossier.exists()) {
      _sauvegardes = dossier
          .listSync()
          .where((f) => f.path.endsWith('.db'))
          .toList()
        ..sort(
          (a, b) => b.path.compareTo(a.path),
        );
    }
    if (mounted) setState(() {});
  }

  Future<void> _exporter() async {
    setState(() => _enChargement = true);
    final chemin = await _service.exporterBaseDeDonnees();
    setState(() => _enChargement = false);
    if (!mounted) return;

    if (chemin != null) {
      await _listerSauvegardes();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${Chaines.succesExport}\n$chemin')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(Chaines.erreurGenerique)),
      );
    }
  }

  Future<void> _restaurer(String chemin) async {
    final bool confirme = await afficherDialogueConfirmation(
      context,
      titre: 'Restaurer',
      message: Chaines.confirmationRestauration,
      libelleConfirmer: Chaines.boutonRestaurer,
    );
    if (!confirme) return;

    setState(() => _enChargement = true);
    final ok = await _service.restaurerDepuisFichier(chemin);
    setState(() => _enChargement = false);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? Chaines.succesRestauration : Chaines.erreurGenerique,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sauvegarde')),
      body: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingMoyen),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BoutonPrimaire(
              libelle: Chaines.boutonExporter,
              icone: Icons.upload_file,
              enChargement: _enChargement,
              onPressed: _exporter,
            ),
            const SizedBox(height: Dimensions.paddingGrand),
            Text(
              'Sauvegardes disponibles',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _sauvegardes.isEmpty
                  ? const Center(
                      child: Text('Aucune sauvegarde trouvée.'),
                    )
                  : ListView.builder(
                      itemCount: _sauvegardes.length,
                      itemBuilder: (context, index) {
                        final fichier = _sauvegardes[index];
                        final nom = path_lib.basename(fichier.path);
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.storage),
                            title: Text(nom),
                            subtitle: Text(fichier.path),
                            trailing: IconButton(
                              icon: const Icon(Icons.restore),
                              onPressed: _enChargement
                                  ? null
                                  : () => _restaurer(fichier.path),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
