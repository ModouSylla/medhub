// ============================================================
// validateurs_test.dart – Tests unitaires des validateurs de formulaires
// ============================================================
import 'package:flutter_test/flutter_test.dart';
import 'package:medihub/utils/validateurs.dart';

void main() {
  group('Validateurs de formulaires', () {
    test('Validation du Nom/Prénom', () {
      expect(Validateurs.validerNom('Diop'), null);
      expect(Validateurs.validerNom('Jean-Luc'), null);
      expect(Validateurs.validerNom(''), 'Ce champ est obligatoire.');
      expect(Validateurs.validerNom('A'), 'Le nom doit contenir au moins 2 caractères.');
      expect(Validateurs.validerNom('User123'), 'Le nom ne peut contenir que des lettres.');
    });

    test('Validation du Téléphone', () {
      expect(Validateurs.validerTelephone('771234567'), null);
      expect(Validateurs.validerTelephone('+221 77 123 45 67'), null);
      expect(Validateurs.validerTelephone(''), 'Le téléphone est obligatoire.');
      expect(Validateurs.validerTelephone('123'), 'Le numéro doit contenir entre 7 et 15 chiffres.');
      expect(Validateurs.validerTelephone('77ABC1234'), 'Le numéro ne doit contenir que des chiffres.');
    });

    test('Validation du Diagnostic & Traitement', () {
      expect(Validateurs.validerDiagnostic('Fièvre typhoïde'), null);
      expect(Validateurs.validerDiagnostic(''), 'Le diagnostic est obligatoire.');
      expect(Validateurs.validerDiagnostic('A'), 'Le diagnostic est trop court.');

      expect(Validateurs.validerTraitement('Paracétamol 1g x 3/jour'), null);
      expect(Validateurs.validerTraitement(''), 'Le traitement est obligatoire.');
    });

    test('Validation du Code PIN', () {
      expect(Validateurs.validerPin('1234'), null);
      expect(Validateurs.validerPin('12345678'), null);
      expect(Validateurs.validerPin(''), 'Le code PIN est obligatoire.');
      expect(Validateurs.validerPin('123'), 'Le PIN doit contenir au moins 4 chiffres.');
      expect(Validateurs.validerPin('123456789'), 'Le PIN ne peut pas dépasser 8 chiffres.');
      expect(Validateurs.validerPin('12a4'), 'Le PIN ne peut contenir que des chiffres.');
    });

    test('Validation de la confirmation PIN', () {
      expect(Validateurs.validerConfirmationPin('1234', '1234'), null);
      expect(Validateurs.validerConfirmationPin('1234', '5678'), 'Les codes PIN ne correspondent pas.');
      expect(Validateurs.validerConfirmationPin('1234', ''), 'La confirmation est obligatoire.');
    });

    test('Validation des heures de RDV', () {
      expect(Validateurs.validerHeuresRdv('09:00', '09:30'), null);
      expect(
        Validateurs.validerHeuresRdv('10:00', '09:30'),
        'L\'heure de fin doit être après l\'heure de début.',
      );
      expect(
        Validateurs.validerHeuresRdv('10:00', '10:00'),
        'L\'heure de fin doit être après l\'heure de début.',
      );
    });

    test('Validation des constantes numériques', () {
      expect(Validateurs.validerConstanteNumerique('37.5'), null);
      expect(Validateurs.validerConstanteNumerique('120,5'), null);
      expect(Validateurs.validerConstanteNumerique(''), null); // Optionnel
      expect(Validateurs.validerConstanteNumerique('abc'), 'Entrez une valeur numérique.');
      expect(Validateurs.validerConstanteNumerique('-5'), 'La valeur ne peut pas être négative.');
    });
  });
}
