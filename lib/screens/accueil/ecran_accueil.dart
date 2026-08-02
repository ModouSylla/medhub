// ============================================================
// ecran_accueil.dart – Tableau de bord principal de MediHub
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/couleurs.dart';
import '../../constants/chaines.dart';
import '../../constants/dimensions.dart';
import '../../constants/routes.dart';
import '../../providers/agenda_provider.dart';
import '../../providers/patient_provider.dart';
import '../../repositories/consultation_repository.dart';
import '../../services/notification_service.dart';
import '../../utils/date_utils.dart';
import '../../widgets/agenda/carte_rendez_vous.dart';

class EcranAccueil extends StatefulWidget {
  const EcranAccueil({super.key});

  @override
  State<EcranAccueil> createState() => _EcranAccueilState();
}

class _EcranAccueilState extends State<EcranAccueil> {
  @override
  void initState() {
    super.initState();
    // Charger les données au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AgendaProvider>().chargerRdvJour(DateTime.now());
      context.read<PatientProvider>().chargerPatients();
      _reprogrammerRappelExamen();
    });
  }

  /// Reprogramme le rappel quotidien (8h) "examen(s) en attente" avec
  /// le compte à jour (cahier des charges §19.2, BF-06.2). Fait à
  /// chaque ouverture de l'accueil pour rester exact même si l'app a
  /// été fermée pendant plusieurs jours.
  Future<void> _reprogrammerRappelExamen() async {
    try {
      final ids = await ConsultationRepository().obtenirIdsExamenEnAttente();
      await NotificationService().planifierRappelExamen(ids.length);
    } catch (_) {
      // Un échec de programmation ne doit jamais bloquer l'accueil.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Chaines.nomApplication),
        actions: [
          // Bouton notifications
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () =>
                Navigator.pushNamed(context, Routes.notifications),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            context.read<AgendaProvider>().chargerRdvJour(DateTime.now()),
        child: ListView(
          padding: const EdgeInsets.all(Dimensions.paddingMoyen),
          children: const [
            _SectionAujourdhui(),
            SizedBox(height: Dimensions.paddingMoyen),
            _SectionAccesRapides(),
          ],
        ),
      ),
      bottomNavigationBar: const _BarreNavigationBas(),
    );
  }
}

/// Section "Rendez-vous du jour".
class _SectionAujourdhui extends StatelessWidget {
  const _SectionAujourdhui();

  @override
  Widget build(BuildContext context) {
    return Consumer<AgendaProvider>(
      builder: (context, agenda, _) {
        final rdvJour = agenda.rdvJour;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingMoyen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Aujourd\'hui',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      AppDateUtils.formaterDateCourte(AppDateUtils.aujourdhui()),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${rdvJour.length} rendez-vous',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Divider(),
                if (agenda.enChargement)
                  const Center(child: CircularProgressIndicator())
                else if (rdvJour.isEmpty)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Aucun rendez-vous aujourd\'hui.',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: Couleurs.texteSecondaire),
                    ),
                  )
                else
                  // Afficher les 3 premiers RDV du jour
                  ...rdvJour.take(3).map(
                        (rdv) => CarteRendezVous(
                          rdv: rdv,
                          onTap: () => Navigator.pushNamed(
                            context,
                            Routes.agenda,
                          ),
                        ),
                      ),
                if (rdvJour.length > 3)
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, Routes.agenda),
                    child: const Text('Voir l\'agenda complet →'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Section des accès rapides (boutons principaux).
class _SectionAccesRapides extends StatelessWidget {
  const _SectionAccesRapides();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Accès rapides',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        _TuileAccesRapide(
          icone: Icons.person_add_outlined,
          libelle: 'Nouveau patient',
          onTap: () =>
              Navigator.pushNamed(context, Routes.inscriptionPatient),
        ),
        _TuileAccesRapide(
          icone: Icons.search,
          libelle: 'Rechercher un patient',
          onTap: () =>
              Navigator.pushNamed(context, Routes.listePatients),
        ),
        _TuileAccesRapide(
          icone: Icons.calendar_month_outlined,
          libelle: 'Agenda',
          onTap: () => Navigator.pushNamed(context, Routes.agenda),
        ),
      ],
    );
  }
}

/// Tuile d'accès rapide.
class _TuileAccesRapide extends StatelessWidget {
  final IconData     icone;
  final String       libelle;
  final VoidCallback onTap;

  const _TuileAccesRapide({
    required this.icone,
    required this.libelle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icone, color: Couleurs.primaire),
        title: Text(libelle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

/// Barre de navigation inférieure.
class _BarreNavigationBas extends StatelessWidget {
  const _BarreNavigationBas();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (index) {
        switch (index) {
          case 1:
            Navigator.pushNamed(context, Routes.listePatients);
            break;
          case 2:
            Navigator.pushNamed(context, Routes.agenda);
            break;
          case 3:
            Navigator.pushNamed(context, Routes.parametres);
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined), label: 'Accueil'),
        BottomNavigationBarItem(
            icon: Icon(Icons.people_outline), label: 'Patients'),
        BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined), label: 'Agenda'),
        BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined), label: 'Paramètres'),
      ],
    );
  }
}
