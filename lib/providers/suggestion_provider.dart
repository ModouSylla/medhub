// ============================================================
// suggestion_provider.dart – Gestion d'état : suggestions
// ============================================================
import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../models/consultation.dart';
import '../models/suggestion.dart';
import '../utils/suggestion_utils.dart';

class SuggestionProvider extends ChangeNotifier {
  List<Suggestion> _suggestions = [];

  List<Suggestion> get suggestions => _suggestions;
  bool             get aSuggestions => _suggestions.isNotEmpty;

  /// Analyse un dossier patient et génère les suggestions intelligentes.
  void analyserDossier(Patient patient, Consultation? derniereConsultation) {
    _suggestions = SuggestionUtils.genererSuggestions(
      patient,
      derniereConsultation,
    );
    notifyListeners();
  }

  /// Efface toutes les suggestions.
  void effacerSuggestions() {
    _suggestions = [];
    notifyListeners();
  }
}
