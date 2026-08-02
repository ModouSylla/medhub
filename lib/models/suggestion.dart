// ============================================================
// suggestion.dart – Modèle Suggestion + enum TypeSuggestion
//
// Représente une suggestion intelligente affichée dans le carnet
// d'un patient. Calculée dynamiquement, NON persistée en BDD.
// ============================================================
import 'package:flutter/material.dart';
import '../constants/couleurs.dart';

/// Types de suggestions intelligentes.
enum TypeSuggestion {
  controleAPrevoir,         // Dernière consultation > 6 mois
  renouvellementTraitement, // Traitement proche de l'expiration
  patientNonRevu,           // Dernière consultation > 12 mois
  examenEnAttente,          // Flag examen_en_attente = true
  rappelUrgent,             // Flag rappel_urgent = true
}

/// Classe Suggestion – objet léger créé à la volée.
class Suggestion {
  final TypeSuggestion type;
  final String message;    // Message affiché à l'utilisateur

  const Suggestion({
    required this.type,
    required this.message,
  });

  /// Retourne l'icône Material associée au type de suggestion.
  IconData obtenirIcone() {
    switch (type) {
      case TypeSuggestion.controleAPrevoir:
        return Icons.schedule;
      case TypeSuggestion.renouvellementTraitement:
        return Icons.medication_outlined;
      case TypeSuggestion.patientNonRevu:
        return Icons.person_off_outlined;
      case TypeSuggestion.examenEnAttente:
        return Icons.biotech_outlined;
      case TypeSuggestion.rappelUrgent:
        return Icons.warning_amber_rounded;
    }
  }

  /// Retourne la couleur de fond du bandeau.
  Color obtenirCouleurFond() {
    switch (type) {
      case TypeSuggestion.rappelUrgent:
        return Couleurs.suggestionUrgence;
      case TypeSuggestion.controleAPrevoir:
      case TypeSuggestion.renouvellementTraitement:
      case TypeSuggestion.examenEnAttente:
        return Couleurs.suggestionAvertissement;
      case TypeSuggestion.patientNonRevu:
        return Couleurs.suggestionInfo;
    }
  }

  /// Retourne la couleur de l'icône.
  Color obtenirCouleurIcone() {
    switch (type) {
      case TypeSuggestion.rappelUrgent:
        return Couleurs.urgence;
      case TypeSuggestion.controleAPrevoir:
      case TypeSuggestion.renouvellementTraitement:
      case TypeSuggestion.examenEnAttente:
        return Couleurs.accent;
      case TypeSuggestion.patientNonRevu:
        return Couleurs.primaire;
    }
  }

  @override
  String toString() => 'Suggestion(${type.name}: $message)';
}
