// ============================================================
// format_utils.dart – Fonctions utilitaires de formatage des données
// ============================================================

import 'package:diacritic/diacritic.dart';

abstract class FormatUtils {
  /// Formate le nom et prénom d'un patient : "NOM Prénom".
  static String formaterNomComplet(String nom, String prenom) {
    final String nomMaj = nom.trim().toUpperCase();
    final String prenomCap = capitaliserMots(prenom.trim());
    return '$nomMaj $prenomCap';
  }

  /// Formate un numéro de téléphone avec des espaces (ex : "+221 77 123 45 67" ou "77 123 45 67").
  static String formaterTelephone(String telephone) {
    final String propre = telephone.replaceAll(RegExp(r'\s+'), '');
    if (propre.length == 9) {
      // Format 771234567 -> 77 123 45 67
      return '${propre.substring(0, 2)} ${propre.substring(2, 5)} ${propre.substring(5, 7)} ${propre.substring(7, 9)}';
    }
    if (propre.length == 13 && propre.startsWith('+')) {
      // Format +221771234567 -> +221 77 123 45 67
      return '${propre.substring(0, 4)} ${propre.substring(4, 6)} ${propre.substring(6, 9)} ${propre.substring(9, 11)} ${propre.substring(11, 13)}';
    }
    return telephone;
  }

  /// Formate une valeur de constante médicale avec son unité (ex: "120 mmHg" ou "37 °C").
  static String formaterConstante(String? valeur, String? unite) {
    if (valeur == null || valeur.trim().isEmpty) return '-';
    if (unite == null || unite.trim().isEmpty) return valeur.trim();
    return '${valeur.trim()} ${unite.trim()}';
  }

  /// Capitalise la première lettre de chaque mot.
  static String capitaliserMots(String texte) {
    if (texte.isEmpty) return texte;
    return texte.split(' ').map((mot) {
      if (mot.isEmpty) return mot;
      return mot[0].toUpperCase() + mot.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Supprime les accents et met en minuscules pour faciliter les recherches SQL/locales.
  static String normaliserPourRecherche(String texte) {
    return removeDiacritics(texte.trim().toLowerCase());
  }

  /// Extrait les initiales d'un nom et prénom.
  static String obtenirInitiales(String nom, String prenom) {
    final String p = prenom.trim().isNotEmpty ? prenom.trim()[0].toUpperCase() : '';
    final String n = nom.trim().isNotEmpty ? nom.trim()[0].toUpperCase() : '';
    return '$p$n';
  }
}
