// ============================================================
// constante_consultation.dart – Modèle ConstanteConsultation
//
// Stocke la valeur d'une mesure relevée lors d'une consultation.
// Table pivot entre Consultation et DefinitionConstante.
// ============================================================
import 'definition_constante.dart';

class ConstanteConsultation {
  final int?   idConstante;
  final int    idConsultation;   // FK → consultations
  final int    idDefinition;    // FK → definitions_constantes
  final String valeur;           // Valeur stockée en texte (ex : "120.5")

  // Champ transient : définition chargée en mémoire (non stockée en BDD)
  DefinitionConstante? definition;

  ConstanteConsultation({
    this.idConstante,
    required this.idConsultation,
    required this.idDefinition,
    required this.valeur,
    this.definition,
  });

  factory ConstanteConsultation.depuisMap(Map<String, dynamic> map) {
    return ConstanteConsultation(
      idConstante:    map['id_constante']     as int?,
      idConsultation: map['id_consultation']  as int,
      idDefinition:   map['id_definition']    as int,
      valeur:         map['valeur']           as String,
    );
  }

  Map<String, dynamic> versMap() {
    final Map<String, dynamic> map = {
      'id_consultation': idConsultation,
      'id_definition':   idDefinition,
      'valeur':          valeur,
    };
    if (idConstante != null) map['id_constante'] = idConstante;
    return map;
  }

  @override
  String toString() =>
      'ConstanteConsultation(def=$idDefinition, val=$valeur)';
}
