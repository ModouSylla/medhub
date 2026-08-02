// ============================================================
// couleurs.dart – Palette de couleurs de MediHub
// Centralise toutes les couleurs : modifier ici change tout.
// ============================================================
import 'package:flutter/material.dart';

abstract class Couleurs {
  // ── Couleurs principales ──────────────────────────────────
  /// Bleu médical profond – AppBar, boutons principaux.
  static const Color primaire = Color(0xFF1A6B9A);
  /// Vert émeraude – FAB, indicateurs positifs.
  static const Color secondaire = Color(0xFF2DCCAA);
  /// Ambre – suggestions, avertissements.
  static const Color accent = Color(0xFFF5A623);
  /// Rouge – urgences, erreurs, allergies.
  static const Color urgence = Color(0xFFE53935);

  // ── Fonds ─────────────────────────────────────────────────
  static const Color fond = Color(0xFFF4F6F8);      // Fond des écrans
  static const Color surface = Color(0xFFFFFFFF);   // Fond des cartes

  // ── Texte ─────────────────────────────────────────────────
  static const Color textePrimaire    = Color(0xFF1C2B3A);
  static const Color texteSecondaire  = Color(0xFF607D8B);
  static const Color texteSurFond     = Color(0xFFFFFFFF);

  // ── Bordures ──────────────────────────────────────────────
  static const Color separateur = Color(0xFFE0E7EF);

  // ── Statuts rendez-vous ───────────────────────────────────
  static const Color statutPlanifie  = Color(0xFFBBDEFB);
  static const Color statutConfirme  = Color(0xFFC8E6C9);
  static const Color statutEffectue  = Color(0xFFEEEEEE);
  static const Color statutAnnule    = Color(0xFFFFCDD2);
  static const Color statutAbsent    = Color(0xFFFFE0B2);
  static const Color blocagePlage    = Color(0xFF90A4AE);

  // ── Suggestions ───────────────────────────────────────────
  static const Color suggestionInfo          = Color(0xFFE3F2FD);
  static const Color suggestionAvertissement = Color(0xFFFFF8E1);
  static const Color suggestionUrgence       = Color(0xFFFFEBEE);
}
