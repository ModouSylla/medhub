// ============================================================
// definition_constante.dart – Modèle DefinitionConstante
//
// Définit le type de mesure médicale selon le profil médical.
// Exemples : "Tension systolique (mmHg)", "Poids (kg)", etc.
// ============================================================

class DefinitionConstante {
  final int?   idDefinition;
  final String libelle;          // Nom affiché (ex : "Poids")
  final String? unite;           // Unité de mesure (ex : "kg"), null si texte
  final String typeValeur;       // 'numerique' ou 'texte'
  final String profilMedical;    // 'generaliste','pediatrie','dentaire','personnalise'
  final int    ordreAffichage;   // Ordre du champ dans le formulaire

  const DefinitionConstante({
    this.idDefinition,
    required this.libelle,
    this.unite,
    required this.typeValeur,
    required this.profilMedical,
    this.ordreAffichage = 0,
  });

  factory DefinitionConstante.depuisMap(Map<String, dynamic> map) {
    return DefinitionConstante(
      idDefinition:    map['id_definition']    as int?,
      libelle:         map['libelle']           as String,
      unite:           map['unite']             as String?,
      typeValeur:      map['type_valeur']       as String,
      profilMedical:   map['profil_medical']    as String,
      ordreAffichage:  map['ordre_affichage']   as int,
    );
  }

  Map<String, dynamic> versMap() {
    final Map<String, dynamic> map = {
      'libelle':          libelle,
      'unite':            unite,
      'type_valeur':      typeValeur,
      'profil_medical':   profilMedical,
      'ordre_affichage':  ordreAffichage,
    };
    if (idDefinition != null) map['id_definition'] = idDefinition;
    return map;
  }

  /// Retourne true si ce champ attend une valeur numérique.
  bool estNumerique() => typeValeur == 'numerique';

  /// Retourne le libellé avec l'unité si disponible (ex : "Poids (kg)").
  String obtenirLibelleComplet() {
    if (unite != null && unite!.isNotEmpty) return '$libelle ($unite)';
    return libelle;
  }

  @override
  String toString() => 'DefinitionConstante($libelle, $profilMedical)';
}
