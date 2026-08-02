// ============================================================
// format_utils_test.dart – Tests unitaires de FormatUtils
// ============================================================
import 'package:flutter_test/flutter_test.dart';
import 'package:medihub/utils/format_utils.dart';

void main() {
  group('FormatUtils', () {
    test('formaterNomComplet', () {
      expect(FormatUtils.formaterNomComplet('diop', 'moussa'), 'DIOP Moussa');
      expect(FormatUtils.formaterNomComplet('sow', 'amadou tidiane'), 'SOW Amadou Tidiane');
    });

    test('formaterTelephone', () {
      expect(FormatUtils.formaterTelephone('771234567'), '77 123 45 67');
      expect(FormatUtils.formaterTelephone('+221771234567'), '+221 77 123 45 67');
    });

    test('formaterConstante', () {
      expect(FormatUtils.formaterConstante('120', 'mmHg'), '120 mmHg');
      expect(FormatUtils.formaterConstante('37', '°C'), '37 °C');
      expect(FormatUtils.formaterConstante('', '°C'), '-');
      expect(FormatUtils.formaterConstante(null, null), '-');
    });

    test('normaliserPourRecherche', () {
      expect(FormatUtils.normaliserPourRecherche('Éléphant'), 'elephant');
      expect(FormatUtils.normaliserPourRecherche('Aïssa THIOYE'), 'aissa thioye');
    });

    test('obtenirInitiales', () {
      expect(FormatUtils.obtenirInitiales('DIOP', 'Moussa'), 'MD');
      expect(FormatUtils.obtenirInitiales('SALL', 'Aïssa'), 'AS');
    });
  });
}
