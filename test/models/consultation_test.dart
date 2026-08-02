// ============================================================
// consultation_test.dart – Tests unitaires du modèle Consultation
// ============================================================
import 'package:flutter_test/flutter_test.dart';
import 'package:medihub/models/consultation.dart';

void main() {
  group('Modèle Consultation', () {
    final consultSample = Consultation(
      idConsultation: 10,
      idPatient: 1,
      dateConsultation: '2026-08-01',
      diagnostic: 'Paludisme simple',
      traitement: 'Artemether + Lumefantrine 3 jours',
      notes: 'Revoir dans 5 jours si fièvre persiste',
      examenEnAttente: true,
      rappelUrgent: false,
      dateCreation: '2026-08-01 12:00:00',
    );

    test('Sérialisation Map -> Consultation -> Map', () {
      final map = consultSample.versMap();
      expect(map['id_consultation'], 10);
      expect(map['id_patient'], 1);
      expect(map['diagnostic'], 'Paludisme simple');
      expect(map['examen_en_attente'], 1);
      expect(map['rappel_urgent'], 0);

      final consultReconstruite = Consultation.depuisMap(map);
      expect(consultReconstruite.idConsultation, 10);
      expect(consultReconstruite.diagnostic, 'Paludisme simple');
      expect(consultReconstruite.examenEnAttente, true);
      expect(consultReconstruite.rappelUrgent, false);
    });

    test('copierAvec modifie correctement les propriétés', () {
      final modifiee = consultSample.copierAvec(
        diagnostic: 'Paludisme grave',
        rappelUrgent: true,
      );
      expect(modifiee.diagnostic, 'Paludisme grave');
      expect(modifiee.rappelUrgent, true);
      expect(modifiee.examenEnAttente, true);
    });
  });
}
