// ============================================================
// suggestion_utils.dart – Logique des suggestions intelligentes
//
// Analyse le dossier d'un patient et génère les suggestions.
// Fonction pure (pas d'état), appelée par le SuggestionProvider.
// ============================================================
import '../models/patient.dart';
import '../models/consultation.dart';
import '../models/suggestion.dart';

class SuggestionUtils {
  // Seuils configurables pour les suggestions (en jours)
  static const int _seuilControle         = 180; // 6 mois
  static const int _seuilPatientNonRevu   = 365; // 12 mois

  // Fenêtre d'alerte pour le renouvellement de traitement :
  // on prévient dès que la fin de traitement est à moins de 3 jours,
  // et on continue à le signaler jusqu'à 15 jours après son expiration
  // (au-delà, on considère que ce n'est plus pertinent d'alerter).
  static const int _seuilAnticipationRenouvellement = 3;
  static const int _seuilPostExpirationRenouvellement = 15;

  // Détecte une durée de traitement exprimée en toutes lettres dans le
  // texte libre du champ "traitement" (ex : "pendant 7 jours",
  // "3 semaines", "1 mois").
  static final RegExp _regexDureeTraitement = RegExp(
    r'(\d+)\s*(jour|jours|semaine|semaines|mois)',
    caseSensitive: false,
  );

  /// Extrait la durée du traitement (en jours) depuis le texte libre,
  /// ou null si aucune durée n'a pu être détectée.
  static int? _extraireDureeTraitementEnJours(String traitement) {
    final Iterable<RegExpMatch> correspondances =
        _regexDureeTraitement.allMatches(traitement);
    if (correspondances.isEmpty) return null;

    // On retient la dernière occurrence : dans un texte du type
    // "Paracétamol 1g x3/jour pendant 7 jours", c'est la durée globale
    // du traitement qui nous intéresse, pas la posologie quotidienne.
    final RegExpMatch derniere = correspondances.last;
    final int quantite = int.tryParse(derniere.group(1) ?? '') ?? 0;
    final String unite = derniere.group(2)!.toLowerCase();

    if (unite.startsWith('semaine')) return quantite * 7;
    if (unite.startsWith('mois')) return quantite * 30;
    return quantite; // "jour" / "jours"
  }

  /// Analyse le dossier patient et retourne la liste des suggestions.
  ///
  /// [patient]               : le patient analysé.
  /// [derniereConsultation]  : sa consultation la plus récente (ou null).
  static List<Suggestion> genererSuggestions(
    Patient patient,
    Consultation? derniereConsultation,
  ) {
    final List<Suggestion> suggestions = [];

    // ── Rappel urgent ─────────────────────────────────────
    // Si le flag rappelUrgent est actif sur la dernière consultation
    if (derniereConsultation != null && derniereConsultation.rappelUrgent) {
      suggestions.add(const Suggestion(
        type: TypeSuggestion.rappelUrgent,
        message: 'Ce patient doit être rappelé en urgence.',
      ));
    }

    // ── Examen en attente ─────────────────────────────────
    if (derniereConsultation != null && derniereConsultation.examenEnAttente) {
      suggestions.add(const Suggestion(
        type: TypeSuggestion.examenEnAttente,
        message: 'Un résultat d\'examen est en attente pour ce patient.',
      ));
    }

    // ── Renouvellement de traitement ──────────────────────
    // On tente d'extraire une durée depuis le texte du traitement pour
    // estimer sa date de fin, et on alerte si elle approche ou vient
    // de passer.
    if (derniereConsultation != null) {
      final int? dureeJours =
          _extraireDureeTraitementEnJours(derniereConsultation.traitement);

      if (dureeJours != null && dureeJours > 0) {
        final DateTime dateFinTraitement = DateTime.parse(
          derniereConsultation.dateConsultation,
        ).add(Duration(days: dureeJours));
        final int joursRestants =
            dateFinTraitement.difference(DateTime.now()).inDays;

        final bool bientotExpire =
            joursRestants <= _seuilAnticipationRenouvellement;
        final bool pasTropAncien =
            joursRestants >= -_seuilPostExpirationRenouvellement;

        if (bientotExpire && pasTropAncien) {
          final String message = joursRestants > 0
              ? 'Le traitement en cours arrive à échéance dans '
                  '$joursRestants jour(s) — pensez à un renouvellement.'
              : 'Le traitement en cours est arrivé à échéance il y a '
                  '${joursRestants.abs()} jour(s) — un renouvellement '
                  'pourrait être nécessaire.';
          suggestions.add(Suggestion(
            type: TypeSuggestion.renouvellementTraitement,
            message: message,
          ));
        }
      }
    }

    // ── Contrôle à prévoir / patient non revu ─────────────
    if (derniereConsultation != null) {
      final int joursDepuis =
          derniereConsultation.calculerJoursDepuis();

      if (joursDepuis >= _seuilPatientNonRevu) {
        // Plus d'un an sans consultation : alerte plus forte
        suggestions.add(Suggestion(
          type: TypeSuggestion.patientNonRevu,
          message: 'Ce patient n\'a pas été revu depuis plus d\'un an '
              '(${(joursDepuis / 30).round()} mois).',
        ));
      } else if (joursDepuis >= _seuilControle) {
        // 6 mois sans consultation : suggérer un contrôle
        suggestions.add(Suggestion(
          type: TypeSuggestion.controleAPrevoir,
          message: 'Un contrôle est à prévoir — dernière visite il y a '
              '${(joursDepuis / 30).round()} mois.',
        ));
      }
    }

    return suggestions;
  }
}
