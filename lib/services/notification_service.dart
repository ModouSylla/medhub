// ============================================================
// notification_service.dart – Service de notifications locales
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../navigation.dart';
import '../constants/routes.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static int _prochainId = 1000;

  /// Identifiant fixe (et réservé) du rappel quotidien "examens en
  /// attente" (cf. [planifierRappelExamen]). Un id fixe permet de
  /// l'annuler/le reprogrammer sans accumuler de doublons.
  static const int idRappelExamenQuotidien = 500;

  /// Heure à laquelle le rappel quotidien "examens en attente" est
  /// envoyé (cahier des charges §19.2, BF-06.2).
  static const int _heureRappelExamen = 8;

  /// Initialise le plugin de notifications.
  ///
  /// Retourne le payload de la notification ayant servi à lancer l'app
  /// (cold start), ou null si l'app n'a pas été ouverte depuis une
  /// notification. Le [main.dart] utilise cette valeur pour naviguer
  /// vers l'écran pertinent une fois la première frame affichée.
  Future<String?> initialiser() async {
    try {
      tz_data.initializeTimeZones();

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _plugin.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTappee,
      );

      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      final NotificationAppLaunchDetails? details =
          await _plugin.getNotificationAppLaunchDetails();
      if (details?.didNotificationLaunchApp ?? false) {
        return details?.notificationResponse?.payload;
      }
      return null;
    } catch (e) {
      // Éviter le crash si l'initialisation échoue sur certains appareils/émulateurs
      return null;
    }
  }

  Future<int> planifierRappelRdv(
    DateTime heureNotif,
    String titre,
    String message,
    String? payload,
  ) async {
    if (heureNotif.isBefore(DateTime.now())) return -1;

    final int idNotif = _prochainId++;
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'medihub_rdv',
      'Rappels rendez-vous',
      channelDescription: 'Notifications de rappel pour les rendez-vous',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    await _plugin.zonedSchedule(
      idNotif,
      titre,
      message,
      tz.TZDateTime.from(heureNotif, tz.local),
      NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );

    return idNotif;
  }

  Future<void> envoyerNotificationUrgence(
    String titre,
    String message, {
    String? payload,
  }) async {
    final int idNotif = _prochainId++;

    await _plugin.show(
      idNotif,
      titre,
      message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medihub_urgence',
          'Alertes urgentes',
          importance: Importance.max,
        ),
      ),
      payload: payload,
    );
  }

  /// Planifie (ou reprogramme) le rappel quotidien "examen(s) en
  /// attente" (cahier des charges §19.2, BF-06.2).
  ///
  /// Envoyée chaque jour à 8h tant qu'il existe au moins un examen en
  /// attente. Doit être ré-appelée à chaque fois que le nombre
  /// d'examens en attente est susceptible d'avoir changé (démarrage de
  /// l'app, nouvelle consultation, ouverture de l'écran Notifications)
  /// afin que le message reflète toujours le compte à jour. Si
  /// [nombreExamens] vaut 0, le rappel précédemment programmé est
  /// simplement annulé.
  Future<void> planifierRappelExamen(int nombreExamens) async {
    // On repart toujours d'un état propre : évite les doublons si le
    // nombre d'examens en attente a changé depuis la dernière
    // programmation.
    await _plugin.cancel(idRappelExamenQuotidien);
    if (nombreExamens <= 0) return;

    final String message = nombreExamens == 1
        ? 'Un résultat d\'examen est en attente.'
        : '$nombreExamens résultats d\'examen sont en attente.';

    final DateTime maintenant = DateTime.now();
    DateTime prochaineOccurrence = DateTime(
      maintenant.year,
      maintenant.month,
      maintenant.day,
      _heureRappelExamen,
    );
    if (!prochaineOccurrence.isAfter(maintenant)) {
      prochaineOccurrence = prochaineOccurrence.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'medihub_examens',
      'Rappels examens en attente',
      channelDescription:
          'Rappel quotidien tant que des examens sont en attente',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    await _plugin.zonedSchedule(
      idRappelExamenQuotidien,
      'Examen(s) en attente',
      message,
      tz.TZDateTime.from(prochaineOccurrence, tz.local),
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      // Répète chaque jour à la même heure (8h) tant que la
      // notification n'a pas été ré-annulée/reprogrammée.
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'examens:0',
    );
  }

  Future<void> annulerNotification(int idNotification) async {
    await _plugin.cancel(idNotification);
  }

  Future<void> annulerToutesNotifications() async {
    await _plugin.cancelAll();
  }

  /// Route l'utilisateur vers l'écran pertinent selon le contenu de la
  /// notification tapée (cahier des charges §19 – notifications).
  ///
  /// Format du payload attendu :
  ///   - "rdv:<idRendezVous>"     → rappel de rendez-vous → ouvre l'agenda
  ///   - "examen:<idPatient>"    → examen en attente     → ouvre le carnet
  ///   - "examens:0"              → rappel quotidien groupé
  ///                                (§19.2/BF-06.2) → ouvre l'écran
  ///                                Notifications
  ///   - "urgence:<idPatient>"   → rappel urgent          → ouvre le carnet
  static void _onNotificationTappee(NotificationResponse response) {
    naviguerDepuisPayload(response.payload);
  }

  /// Exposée statiquement pour être réutilisable aussi bien depuis le
  /// callback de tap (app déjà lancée) que depuis
  /// `getNotificationAppLaunchDetails()` (app lancée depuis une
  /// notification alors qu'elle était fermée, cf. main.dart).
  static void naviguerDepuisPayload(String? payload) {
    if (payload == null || payload.isEmpty) return;
    final NavigatorState? navigateur = navigatorKey.currentState;
    if (navigateur == null) return;

    final List<String> parties = payload.split(':');
    if (parties.length < 2) return;
    final String type = parties[0];
    final int? id = int.tryParse(parties[1]);
    if (id == null) return;

    switch (type) {
      case 'rdv':
        // Le rappel concerne un rendez-vous précis : on ouvre l'agenda,
        // vue la plus pertinente pour retrouver ce RDV du jour.
        navigateur.pushNamed(Routes.agenda);
        break;
      case 'examen':
      case 'urgence':
        // Le rappel concerne un patient précis : on ouvre son carnet.
        navigateur.pushNamed(Routes.carnetPatient, arguments: id);
        break;
      case 'examens':
        // Rappel groupé (pas de patient précis) : on ouvre l'écran
        // Notifications qui liste tous les examens en attente.
        navigateur.pushNamed(Routes.notifications);
        break;
      default:
        break;
    }
  }
}
