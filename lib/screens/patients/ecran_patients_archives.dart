// ============================================================
// ecran_patients_archives.dart – Liste et désarchivage des
// patients archivés.
//
// Corrige le point "porte sans retour" : obtenirTousLesPatients()
// et rechercherPatients() n'affichent jamais les dossiers archivés,
// donc cet écran est le seul moyen d'y accéder et de les restaurer
// via PatientRepository.desarchiverPatient().
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/chaines.dart';
import '../../constants/couleurs.dart';
import '../../constants/dimensions.dart';
import '../../models/patient.dart';
import '../../providers/patient_provider.dart';
import '../../widgets/commun/dialogue_confirmation.dart';
import '../../widgets/commun/indicateur_chargement.dart';
import '../../widgets/commun/message_vide.dart';

class EcranPatientsArchives extends StatefulWidget {
  const EcranPatientsArchives({super.key});

  @override
  State<EcranPatientsArchives> createState() => _EcranPatientsArchivesState();
}

class _EcranPatientsArchivesState extends State<EcranPatientsArchives> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientProvider>().chargerPatientsArchives();
    });
  }

  Future<void> _desarchiver(Patient patient) async {
    final bool confirme = await afficherDialogueConfirmation(
      context,
      titre: Chaines.boutonDesarchiver,
      message: Chaines.confirmationDesarchivage,
      libelleConfirmer: Chaines.boutonConfirmer,
    );
    if (!confirme || !mounted) return;

    final bool ok = await context
        .read<PatientProvider>()
        .desarchiverPatient(patient.idPatient!);
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(Chaines.succesPatientDesarchive)),
      );
    } else {
      final String? erreur = context.read<PatientProvider>().messageErreur;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erreur ?? Chaines.erreurGenerique)),
      );
      context.read<PatientProvider>().effacerErreur();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(Chaines.titrePatientsArchives)),
      body: Consumer<PatientProvider>(
        builder: (context, provider, _) {
          if (provider.enChargementArchives &&
              provider.listePatientsArchives.isEmpty) {
            return const IndicateurChargement();
          }
          if (provider.listePatientsArchives.isEmpty) {
            return const MessageVide(
              icone: Icons.archive_outlined,
              message: Chaines.aucunPatientArchive,
            );
          }
          return RefreshIndicator(
            onRefresh: () => provider.chargerPatientsArchives(),
            child: ListView.builder(
              itemCount: provider.listePatientsArchives.length,
              itemBuilder: (context, index) {
                final patient = provider.listePatientsArchives[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingMoyen,
                    vertical: Dimensions.paddingPetit / 2,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingMoyen,
                      vertical: Dimensions.paddingPetit,
                    ),
                    leading: CircleAvatar(
                      radius: 22,
                      backgroundColor: Couleurs.texteSecondaire,
                      child: Text(
                        patient.obtenirInitiales(),
                        style: const TextStyle(
                          color: Couleurs.texteSurFond,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(patient.obtenirNomComplet()),
                    subtitle: Text(
                      '${patient.calculerAge()} ans • ${patient.sexe}',
                    ),
                    trailing: OutlinedButton.icon(
                      icon: const Icon(Icons.unarchive_outlined, size: 18),
                      label: const Text(Chaines.boutonDesarchiver),
                      onPressed: () => _desarchiver(patient),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
