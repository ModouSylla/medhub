// ============================================================
// consultation.dart – Modèle Consultation
//
// Représente une visite médicale enregistrée pour un patient.
// Liée à Patient via idPatient (clé étrangère SQLite).
// ============================================================

class Consultation {
  final int?   idConsultation;
  final int    idPatient;           // Clé étrangère → patients.id_patient
  final String dateConsultation;   // Format : "YYYY-MM-DD"
  final String diagnostic;          // Texte obligatoire
  final String traitement;          // Texte obligatoire
  final String? notes;              // Notes libres (optionnel)
  final bool   examenEnAttente;     // true si résultat à recevoir
  final bool   rappelUrgent;        // true si patient à rappeler d'urgence
  final String dateCreation;       // Horodatage d'enregistrement

  const Consultation({
    this.idConsultation,
    required this.idPatient,
    required this.dateConsultation,
    required this.diagnostic,
    required this.traitement,
    this.notes,
    this.examenEnAttente = false,
    this.rappelUrgent    = false,
    required this.dateCreation,
  });

  // ── Désérialisation depuis SQLite ────────────────────────

  factory Consultation.depuisMap(Map<String, dynamic> map) {
    return Consultation(
      idConsultation:    map['id_consultation']   as int?,
      idPatient:         map['id_patient']         as int,
      dateConsultation:  map['date_consultation']  as String,
      diagnostic:        map['diagnostic']         as String,
      traitement:        map['traitement']         as String,
      notes:             map['notes']              as String?,
      examenEnAttente:  (map['examen_en_attente']  as int) == 1,
      rappelUrgent:     (map['rappel_urgent']      as int) == 1,
      dateCreation:      map['date_creation']      as String,
    );
  }

  // ── Sérialisation vers SQLite ─────────────────────────────

  Map<String, dynamic> versMap() {
    final Map<String, dynamic> map = {
      'id_patient':         idPatient,
      'date_consultation':  dateConsultation,
      'diagnostic':         diagnostic,
      'traitement':         traitement,
      'notes':              notes,
      'examen_en_attente':  examenEnAttente ? 1 : 0,
      'rappel_urgent':      rappelUrgent    ? 1 : 0,
      'date_creation':      dateCreation,
    };
    if (idConsultation != null) map['id_consultation'] = idConsultation;
    return map;
  }

  // ── Méthodes métier ───────────────────────────────────────

  /// Retourne le nombre de jours depuis la date de consultation.
  int calculerJoursDepuis() {
    final DateTime dateC = DateTime.parse(dateConsultation);
    final DateTime now   = DateTime.now();
    return now.difference(dateC).inDays;
  }

  /// Retourne un résumé court du diagnostic (50 caractères max).
  String obtenirResumeDiagnostic() {
    if (diagnostic.length <= 50) return diagnostic;
    return '${diagnostic.substring(0, 47)}…';
  }

  // ── Pattern copyWith ──────────────────────────────────────

  Consultation copierAvec({
    int? idConsultation,
    int? idPatient,
    String? dateConsultation,
    String? diagnostic,
    String? traitement,
    String? notes,
    bool? examenEnAttente,
    bool? rappelUrgent,
    String? dateCreation,
  }) {
    return Consultation(
      idConsultation:   idConsultation   ?? this.idConsultation,
      idPatient:        idPatient        ?? this.idPatient,
      dateConsultation: dateConsultation ?? this.dateConsultation,
      diagnostic:       diagnostic       ?? this.diagnostic,
      traitement:       traitement       ?? this.traitement,
      notes:            notes            ?? this.notes,
      examenEnAttente:  examenEnAttente  ?? this.examenEnAttente,
      rappelUrgent:     rappelUrgent     ?? this.rappelUrgent,
      dateCreation:     dateCreation     ?? this.dateCreation,
    );
  }

  @override
  String toString() =>
      'Consultation(id=$idConsultation, patient=$idPatient, '
      'date=$dateConsultation)';

  @override
  bool operator ==(Object other) =>
      other is Consultation && other.idConsultation == idConsultation;

  @override
  int get hashCode => idConsultation.hashCode;
}
