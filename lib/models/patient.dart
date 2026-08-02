// ============================================================
// patient.dart – Modèle Patient
//
// Représentation Dart de l'entité Patient stockée en SQLite.
// Contient toutes les informations d'identification médicale.
// ============================================================

class Patient {
  final int?   idPatient;
  final String nom;
  final String prenom;
  final String dateNaissance;   // Format ISO : "YYYY-MM-DD"
  final String sexe;             // 'M', 'F', 'Autre'
  final String telephone;
  final String? adresse;
  final String? groupeSanguin;
  final String? allergies;
  final String? antecedentsPersonnels;
  final String? antecedentsFamiliaux;
  final bool   estArchive;        // false = actif, true = archivé
  final String dateCreation;     // Format ISO : "YYYY-MM-DD HH:MM:SS"

  const Patient({
    this.idPatient,
    required this.nom,
    required this.prenom,
    required this.dateNaissance,
    required this.sexe,
    required this.telephone,
    this.adresse,
    this.groupeSanguin,
    this.allergies,
    this.antecedentsPersonnels,
    this.antecedentsFamiliaux,
    this.estArchive = false,
    required this.dateCreation,
  });

  // ── Désérialisation depuis SQLite ────────────────────────

  /// Construit un Patient depuis une ligne SQLite (Map).
  factory Patient.depuisMap(Map<String, dynamic> map) {
    return Patient(
      idPatient:             map['id_patient']              as int?,
      nom:                   map['nom']                     as String,
      prenom:                map['prenom']                  as String,
      dateNaissance:         map['date_naissance']          as String,
      sexe:                  map['sexe']                    as String,
      telephone:             map['telephone']               as String,
      adresse:               map['adresse']                 as String?,
      groupeSanguin:         map['groupe_sanguin']          as String?,
      allergies:             map['allergies']               as String?,
      antecedentsPersonnels: map['antecedents_personnels']  as String?,
      antecedentsFamiliaux:  map['antecedents_familiaux']   as String?,
      // SQLite stocke les booléens en INTEGER (0 ou 1)
      estArchive:            (map['est_archive'] as int) == 1,
      dateCreation:          map['date_creation']           as String,
    );
  }

  // ── Sérialisation vers SQLite ─────────────────────────────

  /// Convertit le Patient en Map pour db.insert() / db.update().
  Map<String, dynamic> versMap() {
    final Map<String, dynamic> map = {
      'nom':                    nom,
      'prenom':                 prenom,
      'date_naissance':         dateNaissance,
      'sexe':                   sexe,
      'telephone':              telephone,
      'adresse':                adresse,
      'groupe_sanguin':         groupeSanguin,
      'allergies':              allergies,
      'antecedents_personnels': antecedentsPersonnels,
      'antecedents_familiaux':  antecedentsFamiliaux,
      'est_archive':            estArchive ? 1 : 0, // bool → int
      'date_creation':          dateCreation,
    };
    // Inclure l'id uniquement pour les mises à jour
    if (idPatient != null) map['id_patient'] = idPatient;
    return map;
  }

  // ── Méthodes métier ───────────────────────────────────────

  /// Calcule l'âge actuel en années depuis dateNaissance.
  int calculerAge() {
    final DateTime naissance = DateTime.parse(dateNaissance);
    final DateTime now       = DateTime.now();
    int age = now.year - naissance.year;
    // Correction si l'anniversaire n'est pas encore passé cette année
    if (now.month < naissance.month ||
        (now.month == naissance.month && now.day < naissance.day)) {
      age--;
    }
    return age;
  }

  /// Retourne le nom complet : "Prénom NOM".
  String obtenirNomComplet() => '$prenom $nom';

  /// Retourne les initiales pour l'avatar (ex : "AD").
  String obtenirInitiales() {
    final String p = prenom.isNotEmpty ? prenom[0].toUpperCase() : '';
    final String n = nom.isNotEmpty    ? nom[0].toUpperCase()    : '';
    return '$p$n';
  }

  /// Retourne true si des allergies sont renseignées.
  bool aDesAllergies() => allergies != null && allergies!.trim().isNotEmpty;

  // ── Pattern copyWith ──────────────────────────────────────

  /// Crée une copie du patient avec certains champs modifiés.
  Patient copierAvec({
    int? idPatient,
    String? nom,
    String? prenom,
    String? dateNaissance,
    String? sexe,
    String? telephone,
    String? adresse,
    String? groupeSanguin,
    String? allergies,
    String? antecedentsPersonnels,
    String? antecedentsFamiliaux,
    bool? estArchive,
    String? dateCreation,
  }) {
    return Patient(
      idPatient:             idPatient             ?? this.idPatient,
      nom:                   nom                   ?? this.nom,
      prenom:                prenom                ?? this.prenom,
      dateNaissance:         dateNaissance         ?? this.dateNaissance,
      sexe:                  sexe                  ?? this.sexe,
      telephone:             telephone             ?? this.telephone,
      adresse:               adresse               ?? this.adresse,
      groupeSanguin:         groupeSanguin         ?? this.groupeSanguin,
      allergies:             allergies             ?? this.allergies,
      antecedentsPersonnels: antecedentsPersonnels ?? this.antecedentsPersonnels,
      antecedentsFamiliaux:  antecedentsFamiliaux  ?? this.antecedentsFamiliaux,
      estArchive:            estArchive            ?? this.estArchive,
      dateCreation:          dateCreation          ?? this.dateCreation,
    );
  }

  @override
  String toString() =>
      'Patient(id=$idPatient, $prenom $nom, age=${calculerAge()})';

  @override
  bool operator ==(Object other) =>
      other is Patient && other.idPatient == idPatient;

  @override
  int get hashCode => idPatient.hashCode;
}
