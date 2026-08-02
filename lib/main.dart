// ============================================================
// main.dart – Point d'entrée MediHub
// Auteurs : Aïssa Thioye, Modou Sylla – UGB L3 Info 2026
// ============================================================
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'app_routes.dart';
import 'constants/chaines.dart';
import 'constants/styles.dart';
import 'navigation.dart';
import 'providers/agenda_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/consultation_provider.dart';
import 'providers/patient_provider.dart';
import 'providers/profil_provider.dart';
import 'providers/suggestion_provider.dart';
import 'services/notification_service.dart';
import 'services/journal_erreurs_service.dart';

void main() {
  // runZonedGuarded encapsule tout le démarrage de l'app : toute erreur
  // non interceptée ailleurs (y compris avant que Flutter soit prêt)
  // est journalisée au lieu de faire planter silencieusement l'app
  // (cahier des charges §20.2).
  runZonedGuarded<void>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Capture les erreurs déclenchées pendant le build/layout/paint
    // (par exemple une exception de rendu). Sans ce gestionnaire,
    // Flutter se contente d'imprimer l'erreur dans la console et
    // l'écran reste bloqué/blanc sans qu'on sache pourquoi.
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      JournalErreursService.journaliser(
        'FlutterError',
        details.exception,
        details.stack,
      );
    };

    // Capture les erreurs asynchrones non gérées (en dehors du cycle
    // de build Flutter, par exemple une Future oubliée).
    PlatformDispatcher.instance.onError = (Object erreur, StackTrace pile) {
      JournalErreursService.journaliser('PlatformDispatcher', erreur, pile);
      return true; // Empêche la propagation (donc le crash) de l'erreur.
    };

    try {
      await initializeDateFormatting('fr_FR', null);
    } catch (e) {
      debugPrint('Erreur d\'initialisation des dates: $e');
    }

    final NotificationService serviceNotifications = NotificationService();
    String? payloadLancement;
    try {
      payloadLancement = await serviceNotifications.initialiser();
    } catch (e) {
      debugPrint('Erreur d\'initialisation des notifications: $e');
    }

    runApp(MediHubApp(serviceNotifications: serviceNotifications));

    // Si l'app a été lancée en tapant une notification alors qu'elle
    // était complètement fermée, on attend que la première frame (et
    // donc le Navigator) soit prête avant de naviguer.
    if (payloadLancement != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        NotificationService.naviguerDepuisPayload(payloadLancement);
      });
    }
  }, (Object erreur, StackTrace pile) {
    // Filet de sécurité final : toute erreur qui échapperait aux deux
    // gestionnaires ci-dessus est tout de même journalisée.
    JournalErreursService.journaliser('runZonedGuarded', erreur, pile);
  });
}

class MediHubApp extends StatelessWidget {
  final NotificationService serviceNotifications;

  const MediHubApp({super.key, required this.serviceNotifications});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfilProvider()),
        ChangeNotifierProvider(create: (_) => PatientProvider()),
        ChangeNotifierProvider(create: (_) => ConsultationProvider()),
        ChangeNotifierProvider(create: (_) => AgendaProvider()),
        ChangeNotifierProvider(create: (_) => SuggestionProvider()),
      ],
      child: MaterialApp(
        title: Chaines.nomApplication,
        debugShowCheckedModeBanner: false,
        theme: Styles.themeClair(),
        locale: const Locale('fr', 'FR'),
        supportedLocales: const [Locale('fr', 'FR')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        navigatorKey: navigatorKey,
        home: const EcranDemarrage(),
        onGenerateRoute: AppRoutes.generer,
      ),
    );
  }
}
