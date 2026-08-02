// ============================================================
// bandeau_suggestions.dart – Bandeau des suggestions intelligentes
// ============================================================
import 'package:flutter/material.dart';
import '../../constants/dimensions.dart';
import '../../models/suggestion.dart';

/// Affiche un bandeau de suggestions en haut du carnet patient.
/// N'apparaît que si la liste de suggestions est non vide.
class BandeauSuggestions extends StatelessWidget {
  final List<Suggestion> suggestions;

  const BandeauSuggestions({super.key, required this.suggestions});

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingMoyen,
        vertical: Dimensions.paddingPetit,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suggestions',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          // Afficher chaque suggestion dans son bandeau coloré
          ...suggestions.map((s) => _TuileSuggestion(suggestion: s)),
        ],
      ),
    );
  }
}

/// Tuile individuelle pour une suggestion.
class _TuileSuggestion extends StatelessWidget {
  final Suggestion suggestion;
  const _TuileSuggestion({required this.suggestion});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(Dimensions.paddingMoyen),
      decoration: BoxDecoration(
        color: suggestion.obtenirCouleurFond(),
        borderRadius: BorderRadius.circular(Dimensions.rayonCarte),
      ),
      child: Row(
        children: [
          Icon(
            suggestion.obtenirIcone(),
            color: suggestion.obtenirCouleurIcone(),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              suggestion.message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
