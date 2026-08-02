// ============================================================
// ecran_liste_patients.dart – Liste et recherche des patients
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/chaines.dart';
import '../../constants/routes.dart';
import '../../providers/patient_provider.dart';
import '../../repositories/consultation_repository.dart';
import '../../widgets/commun/indicateur_chargement.dart';
import '../../widgets/commun/message_vide.dart';
import '../../widgets/patient/carte_patient.dart';

class EcranListePatients extends StatefulWidget {
  const EcranListePatients({super.key});

  @override
  State<EcranListePatients> createState() => _EcranListePatientsState();
}

class _EcranListePatientsState extends State<EcranListePatients> {
  final ConsultationRepository _repoConsult = ConsultationRepository();
  final TextEditingController _rechercheCtrl = TextEditingController();
  final Map<int, String?> _datesDerniereConsult = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _charger());
  }

  Future<void> _charger() async {
    await context.read<PatientProvider>().chargerPatients();
    await _chargerDatesConsultations();
  }

  Future<void> _chargerDatesConsultations() async {
    final patients = context.read<PatientProvider>().listePatients;
    for (final p in patients) {
      if (p.idPatient == null) continue;
      final derniere =
          await _repoConsult.obtenirDerniereConsultation(p.idPatient!);
      _datesDerniereConsult[p.idPatient!] = derniere?.dateConsultation;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _rechercheCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Chaines.titreMesPatients),
        actions: [
          IconButton(
            icon: const Icon(Icons.archive_outlined),
            tooltip: Chaines.titrePatientsArchives,
            onPressed: () => Navigator.pushNamed(
              context,
              Routes.patientsArchives,
            ).then((_) => _charger()),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _rechercheCtrl,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: Chaines.champRecherche,
              ),
              onChanged: (v) =>
                  context.read<PatientProvider>().rechercherPatients(v),
            ),
          ),
          Expanded(
            child: Consumer<PatientProvider>(
              builder: (context, provider, _) {
                if (provider.enChargement && provider.listePatients.isEmpty) {
                  return const IndicateurChargement();
                }
                if (provider.listePatients.isEmpty) {
                  return MessageVide(
                    icone: Icons.people_outline,
                    message: _rechercheCtrl.text.isEmpty
                        ? Chaines.aucunPatient
                        : Chaines.aucunResultat,
                    libelleAction: _rechercheCtrl.text.isEmpty
                        ? Chaines.boutonInscrirePatient
                        : null,
                    onAction: _rechercheCtrl.text.isEmpty
                        ? () => Navigator.pushNamed(
                              context,
                              Routes.inscriptionPatient,
                            ).then((_) => _charger())
                        : null,
                  );
                }
                return RefreshIndicator(
                  onRefresh: _charger,
                  child: ListView.builder(
                    itemCount: provider.listePatients.length,
                    itemBuilder: (context, index) {
                      final patient = provider.listePatients[index];
                      return CartePatient(
                        patient: patient,
                        dateDerniereConsultation:
                            patient.idPatient != null
                                ? _datesDerniereConsult[patient.idPatient!]
                                : null,
                        onTap: () => Navigator.pushNamed(
                          context,
                          Routes.carnetPatient,
                          arguments: patient.idPatient,
                        ).then((_) => _charger()),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(
          context,
          Routes.inscriptionPatient,
        ).then((_) => _charger()),
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
