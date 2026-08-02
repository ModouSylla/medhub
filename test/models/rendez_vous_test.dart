// ============================================================
// rendez_vous_test.dart – Tests unitaires du modèle RendezVous
// ============================================================
import 'package:flutter_test/flutter_test.dart';
import 'package:medihub/models/rendez_vous.dart';

void main() {
  group('Modèle RendezVous & StatutRendezVous', () {
    test('Conversion Enum StatutRendezVous depuis et vers Chaine', () {
      expect(StatutRendezVous.confirme.versChaine(), 'CONFIRME');
      expect(
        StatutRendezVousExtension.depuisChaine('CONFIRME'),
        StatutRendezVous.confirme,
      );
      expect(
        StatutRendezVousExtension.depuisChaine('ANNULE'),
        StatutRendezVous.annule,
      );
      expect(
        StatutRendezVousExtension.depuisChaine('INCONNU'),
        StatutRendezVous.planifie,
      );
    });

    test('Libellé en français du statut', () {
      expect(StatutRendezVous.planifie.obtenirLibelle(), 'Planifié');
      expect(StatutRendezVous.confirme.obtenirLibelle(), 'Confirmé');
      expect(StatutRendezVous.effectue.obtenirLibelle(), 'Effectué');
      expect(StatutRendezVous.annule.obtenirLibelle(), 'Annulé');
      expect(StatutRendezVous.absent.obtenirLibelle(), 'Absent');
    });

    test('Sérialisation Map -> RendezVous -> Map', () {
      final rdv = RendezVous(
        idRendezVous: 5,
        idPatient: 2,
        dateHeure: '2026-08-01',
        heureDebut: '10:00',
        heureFin: '10:30',
        motif: 'Consultation générale',
        statut: StatutRendezVous.confirme,
        estBlocage: false,
        dateCreation: '2026-08-01 09:00:00',
      );

      final map = rdv.versMap();
      expect(map['id_rendez_vous'], 5);
      expect(map['statut'], 'CONFIRME');
      expect(map['est_blocage'], 0);

      final rdvDecod = RendezVous.depuisMap(map);
      expect(rdvDecod.idRendezVous, 5);
      expect(rdvDecod.statut, StatutRendezVous.confirme);
      expect(rdvDecod.estBlocage, false);
    });
  });
}
