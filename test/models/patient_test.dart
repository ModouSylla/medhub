// ============================================================
// patient_test.dart – Tests unitaires du modèle Patient
// ============================================================
import 'package:flutter_test/flutter_test.dart';
import 'package:medihub/models/patient.dart';

void main() {
  group('Modèle Patient', () {
    final patientSample = Patient(
      idPatient: 1,
      nom: 'DIOP',
      prenom: 'Moussa',
      dateNaissance: '1990-05-15',
      sexe: 'M',
      telephone: '771234567',
      adresse: 'Dakar, Sénégal',
      groupeSanguin: 'O+',
      allergies: 'Pénicilline',
      antecedentsPersonnels: 'Hypertension',
      antecedentsFamiliaux: 'Diabète',
      estArchive: false,
      dateCreation: '2026-01-01 10:00:00',
    );

    test('Conversion Map -> Patient -> Map (Sérialisation)', () {
      final map = patientSample.versMap();
      expect(map['id_patient'], 1);
      expect(map['nom'], 'DIOP');
      expect(map['prenom'], 'Moussa');
      expect(map['est_archive'], 0);

      final patientReconstruit = Patient.depuisMap(map);
      expect(patientReconstruit.idPatient, 1);
      expect(patientReconstruit.nom, 'DIOP');
      expect(patientReconstruit.prenom, 'Moussa');
      expect(patientReconstruit.estArchive, false);
    });

    test('Nom complet et initiales', () {
      expect(patientSample.obtenirNomComplet(), 'Moussa DIOP');
      expect(patientSample.obtenirInitiales(), 'MD');
    });

    test('Vérification des allergies', () {
      expect(patientSample.aDesAllergies(), true);

      final patientSansAllergie = patientSample.copierAvec(allergies: '');
      expect(patientSansAllergie.aDesAllergies(), false);
    });

    test('copierAvec modifie correctement les champs', () {
      final copie = patientSample.copierAvec(nom: 'SALL', estArchive: true);
      expect(copie.nom, 'SALL');
      expect(copie.prenom, 'Moussa');
      expect(copie.estArchive, true);
    });
  });
}
