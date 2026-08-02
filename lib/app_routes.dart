// ============================================================
// app_routes.dart – Génération des routes nommées MediHub
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/routes.dart';
import 'models/patient.dart';
import 'models/rendez_vous.dart';
import 'providers/profil_provider.dart';
import 'screens/accueil/ecran_accueil.dart';
import 'screens/agenda/ecran_agenda.dart';
import 'screens/agenda/ecran_formulaire_rdv.dart';
import 'screens/auth/ecran_configuration.dart';
import 'screens/auth/ecran_pin.dart';
import 'screens/consultations/ecran_detail_consultation.dart';
import 'screens/consultations/ecran_formulaire_consultation.dart';
import 'screens/notifications/ecran_notifications.dart';
import 'screens/parametres/ecran_a_propos.dart';
import 'screens/parametres/ecran_constantes_personnalisees.dart';
import 'screens/parametres/ecran_parametres.dart';
import 'screens/parametres/ecran_profil_medecin.dart';
import 'screens/parametres/ecran_sauvegarde.dart';
import 'screens/patients/ecran_carnet_patient.dart';
import 'screens/patients/ecran_inscription_patient.dart';
import 'screens/patients/ecran_liste_patients.dart';
import 'screens/patients/ecran_modification_patient.dart';
import 'screens/patients/ecran_patients_archives.dart';

class AppRoutes {
  static Route<dynamic>? generer(RouteSettings settings) {
    switch (settings.name) {
      case Routes.pin:
        return _page(const EcranPin(), settings);
      case Routes.configuration:
        return _page(const EcranConfiguration(), settings);
      case Routes.accueil:
        return _page(const EcranAccueil(), settings);
      case Routes.listePatients:
        return _page(const EcranListePatients(), settings);
      case Routes.patientsArchives:
        return _page(const EcranPatientsArchives(), settings);
      case Routes.inscriptionPatient:
        return _page(const EcranInscriptionPatient(), settings);
      case Routes.modificationPatient:
        final Patient patient = settings.arguments as Patient;
        return _page(EcranModificationPatient(patient: patient), settings);
      case Routes.carnetPatient:
        final int idPatient = settings.arguments as int;
        return _page(EcranCarnetPatient(idPatient: idPatient), settings);
      case Routes.formulaireConsultation:
        final int idPatient = settings.arguments as int;
        return _page(
          EcranFormulaireConsultation(idPatient: idPatient),
          settings,
        );
      case Routes.detailConsultation:
        final Map<String, int> args =
            settings.arguments as Map<String, int>;
        return _page(
          EcranDetailConsultation(
            idConsultation: args['idConsultation']!,
            idPatient: args['idPatient']!,
          ),
          settings,
        );
      case Routes.agenda:
        return _page(const EcranAgenda(), settings);
      case Routes.formulaireRdv:
        final Map<String, dynamic>? args =
            settings.arguments as Map<String, dynamic>?;
        return _page(
          EcranFormulaireRdv(
            rdvExistant: args?['rdv'] as RendezVous?,
            idPatient: args?['idPatient'] as int?,
            dateInitiale: args?['date'] as DateTime?,
          ),
          settings,
        );
      case Routes.notifications:
        return _page(const EcranNotifications(), settings);
      case Routes.parametres:
        return _page(const EcranParametres(), settings);
      case Routes.profilMedecin:
        return _page(const EcranProfilMedecin(), settings);
      case Routes.constantesPersonnalisees:
        return _page(const EcranConstantesPersonnalisees(), settings);
      case Routes.sauvegarde:
        return _page(const EcranSauvegarde(), settings);
      case Routes.aPropos:
        return _page(const EcranAPropos(), settings);
      default:
        return _page(const EcranDemarrage(), settings);
    }
  }

  static MaterialPageRoute<dynamic> _page(
    Widget child,
    RouteSettings settings,
  ) {
    return MaterialPageRoute(builder: (_) => child, settings: settings);
  }
}

/// Écran de démarrage : redirige vers configuration ou PIN.
class EcranDemarrage extends StatefulWidget {
  const EcranDemarrage({super.key});

  @override
  State<EcranDemarrage> createState() => _EcranDemarrageState();
}

class _EcranDemarrageState extends State<EcranDemarrage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _rediriger());
  }

  Future<void> _rediriger() async {
    final bool premiere =
        await context.read<ProfilProvider>().estPremiereLancement();
    if (!mounted) return;
    final String route = premiere ? Routes.configuration : Routes.pin;
    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
