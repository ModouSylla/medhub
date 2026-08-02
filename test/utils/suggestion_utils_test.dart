// ============================================================
// suggestion_utils_test.dart – Tests unitaires de SuggestionUtils
// ============================================================
import 'package:flutter_test/flutter_test.dart';
import 'package:medihub/models/consultation.dart';
import 'package:medihub/models/patient.dart';
import 'package:medihub/models/suggestion.dart';
import 'package:medihub/utils/suggestion_utils.dart';

Patient _patientTest() => const Patient(
      idPatient: 1,
      nom: 'Diop',
      prenom: 'Moussa',
      dateNaissance: '1990-01-01',
      sexe: 'M',
      telephone: '771234567',
      dateCreation: '2026-01-01 08:00:00',
    );

String _ilYA(int joursDepuis) =>
    DateTime.now().subtract(Duration(days: joursDepuis)).toIso8601String().substring(0, 10);

void main() {
  group('SuggestionUtils – renouvellement de traitement', () {
    test('Suggère un renouvellement quand la fin de traitement approche', () {
      // Traitement de 7 jours commencé il y a 5 jours -> échéance dans 2 jours.
      final consultation = Consultation(
        idPatient: 1,
        dateConsultation: _ilYA(5),
        diagnostic: 'Infection urinaire',
        traitement: 'Amoxicilline 1g x2/jour pendant 7 jours',
        dateCreation: '2026-01-01 08:00:00',
      );

      final suggestions = SuggestionUtils.genererSuggestions(
        _patientTest(),
        consultation,
      );

      expect(
        suggestions.any((s) => s.type == TypeSuggestion.renouvellementTraitement),
        isTrue,
      );
    });

    test('Suggère un renouvellement juste après l\'expiration', () {
      // Traitement de 3 jours commencé il y a 5 jours -> expiré depuis 2 jours.
      final consultation = Consultation(
        idPatient: 1,
        dateConsultation: _ilYA(5),
        diagnostic: 'Paludisme simple',
        traitement: 'Artemether + Lumefantrine 3 jours',
        dateCreation: '2026-01-01 08:00:00',
      );

      final suggestions = SuggestionUtils.genererSuggestions(
        _patientTest(),
        consultation,
      );

      expect(
        suggestions.any((s) => s.type == TypeSuggestion.renouvellementTraitement),
        isTrue,
      );
    });

    test('N\'ajoute rien si le traitement est encore loin de sa fin', () {
      // Traitement de 30 jours commencé hier -> échéance dans ~29 jours.
      final consultation = Consultation(
        idPatient: 1,
        dateConsultation: _ilYA(1),
        diagnostic: 'Hypertension',
        traitement: 'Amlodipine 5mg/jour pendant 30 jours',
        dateCreation: '2026-01-01 08:00:00',
      );

      final suggestions = SuggestionUtils.genererSuggestions(
        _patientTest(),
        consultation,
      );

      expect(
        suggestions.any((s) => s.type == TypeSuggestion.renouvellementTraitement),
        isFalse,
      );
    });

    test('N\'ajoute rien si aucune durée n\'est détectée dans le texte', () {
      final consultation = Consultation(
        idPatient: 1,
        dateConsultation: _ilYA(5),
        diagnostic: 'Céphalées',
        traitement: 'Paracétamol 1g au besoin',
        dateCreation: '2026-01-01 08:00:00',
      );

      final suggestions = SuggestionUtils.genererSuggestions(
        _patientTest(),
        consultation,
      );

      expect(
        suggestions.any((s) => s.type == TypeSuggestion.renouvellementTraitement),
        isFalse,
      );
    });

    test('N\'ajoute plus rien longtemps après l\'expiration (>15 jours)', () {
      // Traitement de 3 jours commencé il y a 40 jours -> expiré depuis 37 jours.
      final consultation = Consultation(
        idPatient: 1,
        dateConsultation: _ilYA(40),
        diagnostic: 'Angine',
        traitement: 'Amoxicilline pendant 3 jours',
        dateCreation: '2026-01-01 08:00:00',
      );

      final suggestions = SuggestionUtils.genererSuggestions(
        _patientTest(),
        consultation,
      );

      expect(
        suggestions.any((s) => s.type == TypeSuggestion.renouvellementTraitement),
        isFalse,
      );
    });

    test('Comprend les durées exprimées en semaines et en mois', () {
      final consultationSemaines = Consultation(
        idPatient: 1,
        dateConsultation: _ilYA(13),
        diagnostic: 'Anémie',
        traitement: 'Fer + acide folique pendant 2 semaines',
        dateCreation: '2026-01-01 08:00:00',
      );
      // 2 semaines = 14 jours, commencé il y a 13 jours -> échéance demain.
      expect(
        SuggestionUtils.genererSuggestions(_patientTest(), consultationSemaines)
            .any((s) => s.type == TypeSuggestion.renouvellementTraitement),
        isTrue,
      );

      final consultationMois = Consultation(
        idPatient: 1,
        dateConsultation: _ilYA(29),
        diagnostic: 'Diabète',
        traitement: 'Metformine pendant 1 mois',
        dateCreation: '2026-01-01 08:00:00',
      );
      // 1 mois = 30 jours, commencé il y a 29 jours -> échéance demain.
      expect(
        SuggestionUtils.genererSuggestions(_patientTest(), consultationMois)
            .any((s) => s.type == TypeSuggestion.renouvellementTraitement),
        isTrue,
      );
    });
  });
}
