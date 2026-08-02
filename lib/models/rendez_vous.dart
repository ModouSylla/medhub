// ============================================================
// rendez_vous.dart – Modèle RendezVous + enum StatutRendezVous
//
// Représente un créneau dans l'agenda du médecin.
// Peut être un RDV patient ou un blocage de plage (estBlocage=true).
// ============================================================
import 'package:flutter/material.dart';
import '../constants/couleurs.dart';

/// Énumération des statuts possibles d'un rendez-vous.
/// Le cycle de vie est : PLANIFIE → CONFIRME → EFFECTUE | ANNULE | ABSENT
enum StatutRendezVous {
  planifie,   // Créneau réservé, pas encore confirmé
  confirme,   // Patient confirmé
  effectue,   // Consultation réalisée
  annule,     // Annulé par le médecin ou le patient
  absent,     // Patient ne s'est pas présenté
}

/// Extensions sur l'enum pour l'affichage et la couleur.
extension StatutRendezVousExtension on StatutRendezVous {
  /// Retourne le libellé français du statut.
  String obtenirLibelle() {
    switch (this) {
      case StatutRendezVous.planifie:  return 'Planifié';
      case StatutRendezVous.confirme:  return 'Confirmé';
      case StatutRendezVous.effectue:  return 'Effectué';
      case StatutRendezVous.annule:    return 'Annulé';
      case StatutRendezVous.absent:    return 'Absent';
    }
  }

  /// Retourne la couleur de fond associée au statut.
  Color obtenirCouleur() {
    switch (this) {
      case StatutRendezVous.planifie:  return Couleurs.statutPlanifie;
      case StatutRendezVous.confirme:  return Couleurs.statutConfirme;
      case StatutRendezVous.effectue:  return Couleurs.statutEffectue;
      case StatutRendezVous.annule:    return Couleurs.statutAnnule;
      case StatutRendezVous.absent:    return Couleurs.statutAbsent;
    }
  }

  /// Convertit l'enum en chaîne pour SQLite.
  String versChaine() => name.toUpperCase(); // ex : 'PLANIFIE'

  /// Construit un StatutRendezVous depuis une chaîne SQLite.
  static StatutRendezVous depuisChaine(String valeur) {
    switch (valeur.toUpperCase()) {
      case 'CONFIRME':  return StatutRendezVous.confirme;
      case 'EFFECTUE':  return StatutRendezVous.effectue;
      case 'ANNULE':    return StatutRendezVous.annule;
      case 'ABSENT':    return StatutRendezVous.absent;
      default:          return StatutRendezVous.planifie;
    }
  }
}

// ============================================================
// Classe RendezVous
// ============================================================

class RendezVous {
  final int?              idRendezVous;
  final int?              idPatient;       // null si blocage de plage
  final String            dateHeure;       // Format : "YYYY-MM-DD"
  final String            heureDebut;     // Format : "HH:MM"
  final String            heureFin;       // Format : "HH:MM"
  final String?           motif;           // Raison de la consultation
  final StatutRendezVous  statut;
  final bool              estBlocage;      // true = blocage de plage
  final int?              idNotification;  // ID notif planifiée (pour annulation)
  final String            dateCreation;

  // Champ transient : nom du patient chargé en mémoire (affichage)
  String? nomPatient;

  RendezVous({
    this.idRendezVous,
    this.idPatient,
    required this.dateHeure,
    required this.heureDebut,
    required this.heureFin,
    this.motif,
    this.statut = StatutRendezVous.planifie,
    this.estBlocage = false,
    this.idNotification,
    required this.dateCreation,
    this.nomPatient,
  });

  factory RendezVous.depuisMap(Map<String, dynamic> map) {
    return RendezVous(
      idRendezVous:    map['id_rendez_vous']   as int?,
      idPatient:       map['id_patient']        as int?,
      dateHeure:       map['date_heure']        as String,
      heureDebut:      map['heure_debut']       as String,
      heureFin:        map['heure_fin']         as String,
      motif:           map['motif']             as String?,
      statut: StatutRendezVousExtension.depuisChaine(
                  map['statut'] as String? ?? 'PLANIFIE'),
      estBlocage:      (map['est_blocage']      as int) == 1,
      idNotification:  map['id_notification']   as int?,
      dateCreation:    map['date_creation']     as String,
    );
  }

  Map<String, dynamic> versMap() {
    final Map<String, dynamic> map = {
      'id_patient':       idPatient,
      'date_heure':       dateHeure,
      'heure_debut':      heureDebut,
      'heure_fin':        heureFin,
      'motif':            motif,
      'statut':           statut.versChaine(),
      'est_blocage':      estBlocage ? 1 : 0,
      'id_notification':  idNotification,
      'date_creation':    dateCreation,
    };
    if (idRendezVous != null) map['id_rendez_vous'] = idRendezVous;
    return map;
  }

  RendezVous copierAvec({
    int? idRendezVous,
    int? idPatient,
    String? dateHeure,
    String? heureDebut,
    String? heureFin,
    String? motif,
    StatutRendezVous? statut,
    bool? estBlocage,
    int? idNotification,
    String? dateCreation,
    String? nomPatient,
  }) {
    return RendezVous(
      idRendezVous:   idRendezVous   ?? this.idRendezVous,
      idPatient:      idPatient      ?? this.idPatient,
      dateHeure:      dateHeure      ?? this.dateHeure,
      heureDebut:     heureDebut     ?? this.heureDebut,
      heureFin:       heureFin       ?? this.heureFin,
      motif:          motif          ?? this.motif,
      statut:         statut         ?? this.statut,
      estBlocage:     estBlocage     ?? this.estBlocage,
      idNotification: idNotification ?? this.idNotification,
      dateCreation:   dateCreation   ?? this.dateCreation,
      nomPatient:     nomPatient     ?? this.nomPatient,
    );
  }

  @override
  String toString() =>
      'RendezVous(id=$idRendezVous, $dateHeure $heureDebut-$heureFin, '
      'statut=${statut.obtenirLibelle()})';
}
