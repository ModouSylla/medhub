// ============================================================
// base_de_donnees.dart – Singleton DatabaseHelper
//
// Point d'accès unique à la base de données SQLite de MediHub.
// Gère : ouverture, création des tables, migrations, fermeture.
//
// Pattern Singleton : une seule instance dans toute l'application.
// ============================================================
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class BaseDeDonnees {
  // ── Singleton ────────────────────────────────────────────

  /// Instance unique de BaseDeDonnees (Singleton).
  static final BaseDeDonnees _instance = BaseDeDonnees._interne();

  /// Instance privée de la base SQLite.
  Database? _base;

  /// Constructeur privé – empêche l'instanciation externe.
  BaseDeDonnees._interne();

  /// Factory constructor : retourne toujours la même instance.
  factory BaseDeDonnees() => _instance;

  // ── Constantes de configuration ───────────────────────────

  /// Nom du fichier de base de données sur l'appareil.
  static const String _nomFichier = 'medihub.db';

  /// Version du schéma – incrémenter lors d'une migration.
  static const int _versionSchema = 1;

  // ──────────────────────────────────────────────────────────
  // MÉTHODE PRINCIPALE : obtenirBase()
  // ──────────────────────────────────────────────────────────

  /// Retourne l'instance Database ouverte.
  /// Ouvre et initialise la base si elle n'est pas encore ouverte.
  /// Toujours utiliser cette méthode pour accéder à la base.
  Future<Database> obtenirBase() async {
    // Si la base est déjà ouverte, la retourner directement
    if (_base != null) return _base!;
    // Sinon, l'ouvrir (première utilisation)
    _base = await _ouvrirBase();
    return _base!;
  }

  // ──────────────────────────────────────────────────────────
  // OUVERTURE DE LA BASE
  // ──────────────────────────────────────────────────────────

  /// Ouvre la base SQLite et configure le chemin du fichier.
  Future<Database> _ouvrirBase() async {
    // Récupérer le dossier de stockage de l'application
    final String dossierBase = await getDatabasesPath();
    // Construire le chemin complet du fichier .db
    final String cheminComplet = join(dossierBase, _nomFichier);

    return openDatabase(
      cheminComplet,
      version: _versionSchema,
      // Appelée lors de la première ouverture (création)
      onCreate: _creerTables,
      // Appelée lors d'une montée de version (migration)
      onUpgrade: _migrerBase,
      // Activer les clés étrangères à chaque ouverture
      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys = ON;');
      },
    );
  }

  // ──────────────────────────────────────────────────────────
  // CRÉATION DES TABLES (onCreate)
  // ──────────────────────────────────────────────────────────

  /// Crée toutes les tables et insère les données initiales.
  /// Appelée automatiquement lors de la première ouverture.
  Future<void> _creerTables(Database db, int version) async {
    // Activer les clés étrangères
    await db.execute('PRAGMA foreign_keys = ON;');

    // ── Table : patients ──────────────────────────────────
    await db.execute('''
      CREATE TABLE IF NOT EXISTS patients (
        id_patient              INTEGER PRIMARY KEY AUTOINCREMENT,
        nom                     TEXT    NOT NULL,
        prenom                  TEXT    NOT NULL,
        date_naissance          TEXT    NOT NULL,
        sexe                    TEXT    NOT NULL
                                    CHECK (sexe IN ('M','F','Autre')),
        telephone               TEXT    NOT NULL,
        adresse                 TEXT,
        groupe_sanguin          TEXT
                                    CHECK (groupe_sanguin IN
                                    ('A+','A-','B+','B-','AB+','AB-','O+','O-')),
        allergies               TEXT,
        antecedents_personnels  TEXT,
        antecedents_familiaux   TEXT,
        est_archive             INTEGER NOT NULL DEFAULT 0
                                    CHECK (est_archive IN (0,1)),
        date_creation           TEXT    NOT NULL
      )
    ''');

    // ── Table : consultations ────────────────────────────
    await db.execute('''
      CREATE TABLE IF NOT EXISTS consultations (
        id_consultation     INTEGER PRIMARY KEY AUTOINCREMENT,
        id_patient          INTEGER NOT NULL,
        date_consultation   TEXT    NOT NULL,
        diagnostic          TEXT    NOT NULL,
        traitement          TEXT    NOT NULL,
        notes               TEXT,
        examen_en_attente   INTEGER NOT NULL DEFAULT 0
                                CHECK (examen_en_attente IN (0,1)),
        rappel_urgent       INTEGER NOT NULL DEFAULT 0
                                CHECK (rappel_urgent IN (0,1)),
        date_creation       TEXT    NOT NULL,
        FOREIGN KEY (id_patient)
            REFERENCES patients (id_patient)
            ON DELETE CASCADE ON UPDATE CASCADE
      )
    ''');

    // ── Table : definitions_constantes ────────────────────
    await db.execute('''
      CREATE TABLE IF NOT EXISTS definitions_constantes (
        id_definition       INTEGER PRIMARY KEY AUTOINCREMENT,
        libelle             TEXT    NOT NULL,
        unite               TEXT,
        type_valeur         TEXT    NOT NULL
                                CHECK (type_valeur IN ('numerique','texte')),
        profil_medical      TEXT    NOT NULL
                                CHECK (profil_medical IN
                                ('generaliste','pediatrie','dentaire','personnalise')),
        ordre_affichage     INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // ── Table : constantes_consultation ───────────────────
    await db.execute('''
      CREATE TABLE IF NOT EXISTS constantes_consultation (
        id_constante        INTEGER PRIMARY KEY AUTOINCREMENT,
        id_consultation     INTEGER NOT NULL,
        id_definition       INTEGER NOT NULL,
        valeur              TEXT    NOT NULL,
        FOREIGN KEY (id_consultation)
            REFERENCES consultations (id_consultation)
            ON DELETE CASCADE,
        FOREIGN KEY (id_definition)
            REFERENCES definitions_constantes (id_definition)
            ON DELETE RESTRICT
      )
    ''');

    // ── Table : rendez_vous ────────────────────────────────
    await db.execute('''
      CREATE TABLE IF NOT EXISTS rendez_vous (
        id_rendez_vous      INTEGER PRIMARY KEY AUTOINCREMENT,
        id_patient          INTEGER,
        date_heure          TEXT    NOT NULL,
        heure_debut         TEXT    NOT NULL,
        heure_fin           TEXT    NOT NULL,
        motif               TEXT,
        statut              TEXT    NOT NULL DEFAULT 'PLANIFIE'
                                CHECK (statut IN
                                ('PLANIFIE','CONFIRME','EFFECTUE','ANNULE','ABSENT')),
        est_blocage         INTEGER NOT NULL DEFAULT 0
                                CHECK (est_blocage IN (0,1)),
        id_notification     INTEGER,
        date_creation       TEXT    NOT NULL,
        FOREIGN KEY (id_patient)
            REFERENCES patients (id_patient)
            ON DELETE SET NULL
      )
    ''');

    // ── Table : profil_medecin ────────────────────────────
    await db.execute('''
      CREATE TABLE IF NOT EXISTS profil_medecin (
        id_profil               INTEGER PRIMARY KEY AUTOINCREMENT,
        nom_medecin             TEXT    NOT NULL,
        prenom_medecin          TEXT    NOT NULL,
        specialite              TEXT    NOT NULL,
        profil_medical          TEXT    NOT NULL
                                    CHECK (profil_medical IN
                                    ('generaliste','pediatrie','dentaire','personnalise')),
        numero_ordre            TEXT,
        code_pin_hash           TEXT    NOT NULL,
        tentatives_echouees     INTEGER NOT NULL DEFAULT 0,
        date_verrouillage       TEXT
      )
    ''');

    // ── Index pour les performances ─────────────────────
    await db.execute('CREATE INDEX IF NOT EXISTS idx_patients_nom ON patients (nom, prenom)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_patients_tel ON patients (telephone)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_consult_patient ON consultations (id_patient, date_consultation DESC)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_def_profil ON definitions_constantes (profil_medical, ordre_affichage)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_rdv_date ON rendez_vous (date_heure, heure_debut)');

    // ── Données initiales : constantes par profil ────────
    await _insererDonneesInitiales(db);
  }

  // ──────────────────────────────────────────────────────────
  // DONNÉES INITIALES
  // ──────────────────────────────────────────────────────────

  /// Insère les définitions de constantes pré-configurées.
  Future<void> _insererDonneesInitiales(Database db) async {
    // Profil Généraliste
    final List<Map<String, dynamic>> generaliste = [
      {'libelle': 'Tension systolique',  'unite': 'mmHg', 'type_valeur': 'numerique', 'profil_medical': 'generaliste', 'ordre_affichage': 1},
      {'libelle': 'Tension diastolique', 'unite': 'mmHg', 'type_valeur': 'numerique', 'profil_medical': 'generaliste', 'ordre_affichage': 2},
      {'libelle': 'Poids',               'unite': 'kg',   'type_valeur': 'numerique', 'profil_medical': 'generaliste', 'ordre_affichage': 3},
      {'libelle': 'Taille',              'unite': 'cm',   'type_valeur': 'numerique', 'profil_medical': 'generaliste', 'ordre_affichage': 4},
      {'libelle': 'Température',         'unite': '°C',   'type_valeur': 'numerique', 'profil_medical': 'generaliste', 'ordre_affichage': 5},
      {'libelle': 'Fréquence cardiaque', 'unite': 'bpm',  'type_valeur': 'numerique', 'profil_medical': 'generaliste', 'ordre_affichage': 6},
      {'libelle': 'Saturation SpO2',     'unite': '%',    'type_valeur': 'numerique', 'profil_medical': 'generaliste', 'ordre_affichage': 7},
    ];

    // Profil Pédiatrie
    final List<Map<String, dynamic>> pediatrie = [
      {'libelle': 'Poids',                   'unite': 'kg',          'type_valeur': 'numerique', 'profil_medical': 'pediatrie', 'ordre_affichage': 1},
      {'libelle': 'Taille',                  'unite': 'cm',          'type_valeur': 'numerique', 'profil_medical': 'pediatrie', 'ordre_affichage': 2},
      {'libelle': 'Périmètre crânien',       'unite': 'cm',          'type_valeur': 'numerique', 'profil_medical': 'pediatrie', 'ordre_affichage': 3},
      {'libelle': 'Température',             'unite': '°C',          'type_valeur': 'numerique', 'profil_medical': 'pediatrie', 'ordre_affichage': 4},
      {'libelle': 'Fréquence cardiaque',     'unite': 'bpm',         'type_valeur': 'numerique', 'profil_medical': 'pediatrie', 'ordre_affichage': 5},
      {'libelle': 'Fréquence respiratoire',  'unite': 'cycles/min',  'type_valeur': 'numerique', 'profil_medical': 'pediatrie', 'ordre_affichage': 6},
      {'libelle': 'Percentile poids',        'unite': null,          'type_valeur': 'texte',     'profil_medical': 'pediatrie', 'ordre_affichage': 7},
      {'libelle': 'Percentile taille',       'unite': null,          'type_valeur': 'texte',     'profil_medical': 'pediatrie', 'ordre_affichage': 8},
    ];

    // Profil Dentaire
    final List<Map<String, dynamic>> dentaire = [
      {'libelle': 'Schéma dentaire',         'unite': null, 'type_valeur': 'texte',     'profil_medical': 'dentaire', 'ordre_affichage': 1},
      {'libelle': 'Hygiène bucco-dentaire',  'unite': '/5', 'type_valeur': 'numerique', 'profil_medical': 'dentaire', 'ordre_affichage': 2},
      {'libelle': 'Traitement réalisé',      'unite': null, 'type_valeur': 'texte',     'profil_medical': 'dentaire', 'ordre_affichage': 3},
      {'libelle': 'Prochaine séance prévue', 'unite': null, 'type_valeur': 'texte',     'profil_medical': 'dentaire', 'ordre_affichage': 4},
    ];

    // Insérer toutes les définitions en batch
    final Batch lot = db.batch();
    for (final def in [...generaliste, ...pediatrie, ...dentaire]) {
      lot.insert('definitions_constantes', def);
    }
    await lot.commit(noResult: true);
  }

  // ──────────────────────────────────────────────────────────
  // MIGRATION (onUpgrade)
  // ──────────────────────────────────────────────────────────

  /// Applique les migrations entre versions du schéma.
  /// Appelée automatiquement par sqflite si la version change.
  Future<void> _migrerBase(
    Database db,
    int ancienneVersion,
    int nouvelleVersion,
  ) async {
    // Exemple de migration v1 → v2 (à implémenter lors d'une évolution)
    if (ancienneVersion < 2) {
      // await db.execute('ALTER TABLE consultations ADD COLUMN duree_minutes INTEGER');
    }
  }

  // ──────────────────────────────────────────────────────────
  // FERMETURE
  // ──────────────────────────────────────────────────────────

  /// Ferme proprement la connexion à la base de données.
  Future<void> fermerBase() async {
    if (_base != null) {
      await _base!.close();
      _base = null; // Permettre une réouverture si nécessaire
    }
  }
}
