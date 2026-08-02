// ============================================================
// date_utils.dart – Fonctions utilitaires de formatage des dates
// ============================================================
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppDateUtils {
  static final DateFormat _formatLong   = DateFormat('dd MMMM yyyy', 'fr_FR');
  static final DateFormat _formatCourt  = DateFormat('dd/MM/yyyy', 'fr_FR');
  static final DateFormat _formatIso    = DateFormat('yyyy-MM-dd');
  static final DateFormat _formatHeure  = DateFormat('HH\'h\'mm');
  static final DateFormat _formatBdd    = DateFormat('yyyy-MM-dd HH:mm:ss');

  static String formaterDateLongue(String dateIso) {
    try {
      return _formatLong.format(DateTime.parse(dateIso));
    } catch (_) {
      return dateIso;
    }
  }

  static String formaterDateCourte(String dateIso) {
    try {
      return _formatCourt.format(DateTime.parse(dateIso));
    } catch (_) {
      return dateIso;
    }
  }

  static String formaterHeure(String hhmm) {
    final List<String> parties = hhmm.split(':');
    if (parties.length < 2) return hhmm;
    return '${parties[0]}h${parties[1]}';
  }

  static String dateVersIso(DateTime dt) => _formatIso.format(dt);

  static String dateVersHorodatage(DateTime dt) => _formatBdd.format(dt);

  static String maintenant() => _formatBdd.format(DateTime.now());

  static String aujourdhui() => _formatIso.format(DateTime.now());

  static String debutDeSemaine(DateTime date) {
    final int joursDepuisLundi = date.weekday - 1;
    final DateTime lundi = date.subtract(Duration(days: joursDepuisLundi));
    return dateVersIso(lundi);
  }

  static String finDeSemaine(DateTime date) {
    final int joursJusquaDimanche = 7 - date.weekday;
    final DateTime dimanche = date.add(Duration(days: joursJusquaDimanche));
    return dateVersIso(dimanche);
  }

  static String decrireDelai(int nombreJours) {
    if (nombreJours == 0) return "Aujourd'hui";
    if (nombreJours == 1) return 'Il y a 1 jour';
    if (nombreJours < 30) return 'Il y a $nombreJours jours';
    if (nombreJours < 365) {
      final int mois = (nombreJours / 30).round();
      return 'Il y a $mois mois';
    }
    final int ans = (nombreJours / 365).round();
    return 'Il y a $ans an(s)';
  }

  /// Convertit un TimeOfDay Flutter en chaîne "HH:MM".
  static String timeOfDayVersChaine(TimeOfDay heure) {
    final String h = heure.hour.toString().padLeft(2, '0');
    final String m = heure.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Convertit une chaîne "HH:MM" en TimeOfDay Flutter.
  static TimeOfDay chaineVersTimeOfDay(String hhmm) {
    final List<String> parties = hhmm.split(':');
    return TimeOfDay(
      hour:   int.parse(parties[0]),
      minute: int.parse(parties[1]),
    );
  }
}
