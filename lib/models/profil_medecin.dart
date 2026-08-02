// ============================================================
// profil_medecin.dart – Modèle ProfilMedecin + enum TypeProfil
// ============================================================

enum TypeProfil {
  generaliste,
  pediatrie,
  dentaire,
  personnalise,
}

extension TypeProfilExtension on TypeProfil {
  String obtenirLibelle() {
    switch (this) {
      case TypeProfil.generaliste:   return 'Médecine générale';
      case TypeProfil.pediatrie:     return 'Pédiatrie';
      case TypeProfil.dentaire:      return 'Dentaire';
      case TypeProfil.personnalise:  return 'Personnalisé';
    }
  }

  String versChaine() => name;
  static TypeProfil depuisChaine(String valeur) => TypeProfil.values.firstWhere(
    (e) => e.name == valeur.toLowerCase(),
    orElse: () => TypeProfil.generaliste,
  );
}

class ProfilMedecin {
  final int?       idProfil;
  final String     nomMedecin;
  final String     prenomMedecin;
  final String     specialite;
  final TypeProfil profilMedical;
  final String?    numeroOrdre;
  final String     codePinHash;
  final int        tentativesEchouees;
  final String?    dateVerrouillage;

  const ProfilMedecin({
    this.idProfil,
    required this.nomMedecin,
    required this.prenomMedecin,
    required this.specialite,
    required this.profilMedical,
    this.numeroOrdre,
    required this.codePinHash,
    this.tentativesEchouees = 0,
    this.dateVerrouillage,
  });

  factory ProfilMedecin.depuisMap(Map<String, dynamic> map) {
    return ProfilMedecin(
      idProfil:            map['id_profil']              as int?,
      nomMedecin:          map['nom_medecin']            as String,
      prenomMedecin:       map['prenom_medecin']         as String,
      specialite:          map['specialite']             as String,
      profilMedical: TypeProfilExtension.depuisChaine(
                         map['profil_medical'] as String),
      numeroOrdre:         map['numero_ordre']           as String?,
      codePinHash:         map['code_pin_hash']          as String,
      tentativesEchouees:  map['tentatives_echouees']    as int,
      dateVerrouillage:    map['date_verrouillage']      as String?,
    );
  }

  Map<String, dynamic> versMap() {
    final Map<String, dynamic> map = {
      'nom_medecin':          nomMedecin,
      'prenom_medecin':       prenomMedecin,
      'specialite':           specialite,
      'profil_medical':       profilMedical.versChaine(),
      'numero_ordre':         numeroOrdre,
      'code_pin_hash':        codePinHash,
      'tentatives_echouees':  tentativesEchouees,
      'date_verrouillage':    dateVerrouillage,
    };
    if (idProfil != null) map['id_profil'] = idProfil;
    return map;
  }

  String obtenirNomComplet() => 'Dr $prenomMedecin $nomMedecin';

  bool estVerrouillee() {
    if (tentativesEchouees < 5) return false;
    if (dateVerrouillage == null) return false;
    final DateTime verrou = DateTime.parse(dateVerrouillage!);
    final DateTime finVerrou = verrou.add(const Duration(minutes: 5));
    return DateTime.now().isBefore(finVerrou);
  }

  int minutesRestantesVerrouillage() {
    if (!estVerrouillee() || dateVerrouillage == null) return 0;
    final DateTime verrou = DateTime.parse(dateVerrouillage!);
    final DateTime finVerrou = verrou.add(const Duration(minutes: 5));
    return finVerrou.difference(DateTime.now()).inMinutes + 1;
  }

  ProfilMedecin copierAvec({
    int? idProfil,
    String? nomMedecin,
    String? prenomMedecin,
    String? specialite,
    TypeProfil? profilMedical,
    String? numeroOrdre,
    String? codePinHash,
    int? tentativesEchouees,
    String? dateVerrouillage,
  }) {
    return ProfilMedecin(
      idProfil:            idProfil            ?? this.idProfil,
      nomMedecin:          nomMedecin          ?? this.nomMedecin,
      prenomMedecin:       prenomMedecin       ?? this.prenomMedecin,
      specialite:          specialite          ?? this.specialite,
      profilMedical:       profilMedical       ?? this.profilMedical,
      numeroOrdre:         numeroOrdre         ?? this.numeroOrdre,
      codePinHash:         codePinHash         ?? this.codePinHash,
      tentativesEchouees:  tentativesEchouees  ?? this.tentativesEchouees,
      dateVerrouillage:    dateVerrouillage    ?? this.dateVerrouillage,
    );
  }

  @override
  String toString() => 'ProfilMedecin(${obtenirNomComplet()}, '
      '${profilMedical.obtenirLibelle()})';
}
