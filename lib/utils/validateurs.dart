// ============================================================
// validateurs.dart – Fonctions de validation des formulaires
//
// Convention Flutter : retourne null si valide, String si erreur.
// Ces fonctions sont utilisées dans les TextFormField.validator.
// ============================================================

class Validateurs {
  // ──────────────────────────────────────────────────────────
  // PATIENT
  // ──────────────────────────────────────────────────────────

  /// Valide un nom ou prénom.
  static String? validerNom(String? valeur) {
    if (valeur == null || valeur.trim().isEmpty) {
      return 'Ce champ est obligatoire.';
    }
    if (valeur.trim().length < 2) {
      return 'Le nom doit contenir au moins 2 caractères.';
    }
    if (valeur.trim().length > 100) {
      return 'Le nom ne peut pas dépasser 100 caractères.';
    }
    // Autoriser lettres, espaces, tirets, apostrophes
    final RegExp regexNom = RegExp(r"^[a-zA-ZÀ-ÿ\s\-']+$");
    if (!regexNom.hasMatch(valeur.trim())) {
      return 'Le nom ne peut contenir que des lettres.';
    }
    return null; // null = valide
  }

  /// Valide un numéro de téléphone.
  static String? validerTelephone(String? valeur) {
    if (valeur == null || valeur.trim().isEmpty) {
      return 'Le téléphone est obligatoire.';
    }
    // Supprimer espaces et tirets pour compter les chiffres
    final String chiffres = valeur.replaceAll(RegExp(r'[\s\-+]'), '');
    if (chiffres.length < 7 || chiffres.length > 15) {
      return 'Le numéro doit contenir entre 7 et 15 chiffres.';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(chiffres)) {
      return 'Le numéro ne doit contenir que des chiffres.';
    }
    return null;
  }

  /// Valide une date de naissance (doit être dans le passé).
  static String? validerDateNaissance(DateTime? date) {
    if (date == null) return 'La date de naissance est obligatoire.';
    final DateTime maintenant = DateTime.now();
    if (date.isAfter(maintenant)) return 'La date doit être dans le passé.';
    // Date de naissance pas plus de 150 ans dans le passé
    if (date.isBefore(
        maintenant.subtract(const Duration(days: 150 * 365)))) {
      return 'Date de naissance invalide.';
    }
    return null;
  }

  // ──────────────────────────────────────────────────────────
  // CONSULTATION
  // ──────────────────────────────────────────────────────────

  /// Valide un champ de diagnostic.
  static String? validerDiagnostic(String? valeur) {
    if (valeur == null || valeur.trim().isEmpty) {
      return 'Le diagnostic est obligatoire.';
    }
    if (valeur.trim().length < 2) {
      return 'Le diagnostic est trop court.';
    }
    if (valeur.length > 2000) {
      return 'Maximum 2000 caractères.';
    }
    return null;
  }

  /// Valide un champ de traitement.
  static String? validerTraitement(String? valeur) {
    if (valeur == null || valeur.trim().isEmpty) {
      return 'Le traitement est obligatoire.';
    }
    return null;
  }

  /// Valide une constante numérique (optionnelle mais doit être un nombre).
  static String? validerConstanteNumerique(String? valeur) {
    if (valeur == null || valeur.trim().isEmpty) return null; // Optionnel
    final double? nombre = double.tryParse(valeur.replaceAll(',', '.'));
    if (nombre == null) return 'Entrez une valeur numérique.';
    if (nombre < 0) return 'La valeur ne peut pas être négative.';
    return null;
  }

  // ──────────────────────────────────────────────────────────
  // RENDEZ-VOUS
  // ──────────────────────────────────────────────────────────

  /// Valide que l'heure de fin est après l'heure de début.
  static String? validerHeuresRdv(String? debut, String? fin) {
    if (debut == null || fin == null) return 'Les horaires sont obligatoires.';
    final List<String> pd = debut.split(':');
    final List<String> pf = fin.split(':');
    if (pd.length < 2 || pf.length < 2) return 'Format invalide.';

    final int minutesDebut =
        int.parse(pd[0]) * 60 + int.parse(pd[1]);
    final int minutesFin =
        int.parse(pf[0]) * 60 + int.parse(pf[1]);

    if (minutesFin <= minutesDebut) {
      return 'L\'heure de fin doit être après l\'heure de début.';
    }
    return null;
  }

  // ──────────────────────────────────────────────────────────
  // CODE PIN
  // ──────────────────────────────────────────────────────────

  /// Valide un code PIN (4 à 8 chiffres).
  static String? validerPin(String? valeur) {
    if (valeur == null || valeur.isEmpty) {
      return 'Le code PIN est obligatoire.';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(valeur)) {
      return 'Le PIN ne peut contenir que des chiffres.';
    }
    if (valeur.length < 4) return 'Le PIN doit contenir au moins 4 chiffres.';
    if (valeur.length > 8) return 'Le PIN ne peut pas dépasser 8 chiffres.';
    return null;
  }

  /// Valide que la confirmation correspond au PIN.
  static String? validerConfirmationPin(String? pin, String? confirmation) {
    if (confirmation == null || confirmation.isEmpty) {
      return 'La confirmation est obligatoire.';
    }
    if (pin != confirmation) return 'Les codes PIN ne correspondent pas.';
    return null;
  }

  // ──────────────────────────────────────────────────────────
  // GÉNÉRIQUE
  // ──────────────────────────────────────────────────────────

  /// Valide qu'un champ obligatoire n'est pas vide.
  static String? validerChampObligatoire(String? valeur) {
    if (valeur == null || valeur.trim().isEmpty) {
      return 'Ce champ est obligatoire.';
    }
    return null;
  }

  /// Valide un champ texte avec une longueur maximale.
  static String? validerTexteAvecMax(String? valeur, int max) {
    if (valeur != null && valeur.length > max) {
      return 'Maximum $max caractères.';
    }
    return null;
  }
}
