// ============================================================
// chaines.dart – Tous les textes affichés dans MediHub
// Facilite la maintenance et une future traduction.
// ============================================================
abstract class Chaines {
  static const String nomApplication    = 'MediHub';
  static const String sloganApplication = 'Carnet médical numérique';

  // ── PIN ───────────────────────────────────────────────────
  static const String titreSaisirPin = 'Saisir votre code PIN';
  static const String erreurPinIncorrect = 'Code PIN incorrect.';
  static const String erreurTentativesRestantes = 'tentative(s) restante(s)';
  static const String erreurVerrouillage = 'Application verrouillée. Réessayez dans';
  static const String minutes = 'minute(s)';

  // ── Configuration ─────────────────────────────────────────
  static const String titreConfiguration = 'Configuration initiale';
  static const String boutonSuivant  = 'Suivant';
  static const String boutonPrecedent = 'Précédent';
  static const String boutonTerminer  = 'Terminer la configuration';

  // ── Patients ──────────────────────────────────────────────
  static const String titreNouveauPatient  = 'Nouveau patient';
  static const String titreMesPatients     = 'Mes patients';
  static const String champNom             = 'Nom *';
  static const String champPrenom          = 'Prénom *';
  static const String champDateNaissance   = 'Date de naissance *';
  static const String champSexe            = 'Sexe *';
  static const String champTelephone       = 'Téléphone *';
  static const String champAdresse         = 'Adresse (optionnel)';
  static const String champGroupeSanguin   = 'Groupe sanguin (optionnel)';
  static const String champAllergies       = 'Allergies connues (optionnel)';
  static const String champAntecedentsPerso   = 'Antécédents personnels (optionnel)';
  static const String champAntecedentsFamil   = 'Antécédents familiaux (optionnel)';
  static const String champRecherche       = 'Rechercher (nom, prénom, téléphone…)';
  static const String aucunPatient         = 'Aucun patient enregistré.\nAppuyez sur + pour commencer.';
  static const String aucunResultat        = 'Aucun résultat pour cette recherche.';
  static const String titrePatientsArchives = 'Patients archivés';
  static const String aucunPatientArchive  = 'Aucun patient archivé.';
  static const String confirmationDesarchivage =
      'Ce patient sera de nouveau visible dans la liste principale. Confirmer ?';
  static const String succesPatientDesarchive = 'Patient désarchivé avec succès.';

  // ── Consultations ─────────────────────────────────────────
  static const String titreCarnet              = 'Carnet médical';
  static const String titreNouvelleConsult     = 'Nouvelle consultation';
  static const String champDiagnostic          = 'Diagnostic *';
  static const String champTraitement          = 'Traitement prescrit *';
  static const String champNotes               = 'Notes (optionnel)';
  static const String champExamenEnAttente     = 'Résultat d\'examen en attente';
  static const String champRappelUrgent        = 'Rappeler ce patient en urgence';
  static const String aucuneConsultation       = 'Aucune consultation enregistrée.\nAjoutez la première consultation.';
  static const String boutonMarquerExamenRecu  = 'Marquer l\'examen comme reçu';
  static const String confirmationExamenRecu   =
      'Confirmer que le résultat de cet examen a bien été reçu ? '
      'Le rappel quotidien ne sera plus déclenché pour cette consultation.';
  static const String succesExamenRecu         = 'Examen marqué comme reçu.';

  // ── Menu rapide fiche patient (⋮) ─────────────────────────
  static const String menuActiverRappelUrgent   = 'Activer le rappel urgent';
  static const String menuDesactiverRappelUrgent = 'Désactiver le rappel urgent';
  static const String succesRappelUrgentActive   = 'Rappel urgent activé.';
  static const String succesRappelUrgentDesactive = 'Rappel urgent désactivé.';

  // ── Agenda ────────────────────────────────────────────────
  static const String titreAgenda     = 'Agenda';
  static const String titreNouveauRdv = 'Nouveau rendez-vous';
  static const String titreModifierRdv = 'Modifier le rendez-vous';
  static const String champDateRdv    = 'Date *';
  static const String champHeureDebut = 'Heure de début *';
  static const String champHeureFin   = 'Heure de fin *';
  static const String champMotif      = 'Motif (optionnel)';
  static const String alerteConflit   = 'Conflit horaire détecté avec un autre rendez-vous.';
  static const String boutonAnnulerRdv = 'Annuler le rendez-vous';

  // ── Succès ────────────────────────────────────────────────
  static const String succesPatient      = 'Patient enregistré avec succès.';
  static const String succesConsultation = 'Consultation enregistrée.';
  static const String succesRdvCree      = 'Rendez-vous créé.';
  static const String succesRdvModifie   = 'Rendez-vous modifié.';
  static const String succesRdvAnnule    = 'Rendez-vous annulé.';
  static const String succesExport       = 'Données exportées avec succès.';
  static const String succesRestauration = 'Données restaurées avec succès.';

  // ── Erreurs ───────────────────────────────────────────────
  static const String erreurGenerique = 'Une erreur est survenue. Réessayez.';
  static const String erreurBdd       = 'Erreur de base de données.';

  // ── Boutons communs ───────────────────────────────────────
  static const String boutonEnregistrer = 'Enregistrer';
  static const String boutonAnnuler     = 'Annuler';
  static const String boutonConfirmer   = 'Confirmer';
  static const String boutonModifier    = 'Modifier';
  static const String boutonArchiver    = 'Archiver le dossier';
  static const String boutonDesarchiver = 'Désarchiver le dossier';
  static const String boutonRetour      = 'Retour';
  static const String boutonNouvelleConsult = 'Nouvelle consultation';
  static const String boutonInscrirePatient = 'Inscrire un patient';
  static const String boutonExporter    = 'Exporter les données';
  static const String boutonRestaurer   = 'Restaurer depuis une sauvegarde';
  static const String boutonModifierPin = 'Modifier le code PIN';

  // ── Confirmations ─────────────────────────────────────────
  static const String confirmationArchivage =
      'Ce dossier sera archivé. Les données sont conservées '
      'mais le patient ne figurera plus dans la liste principale.';
  static const String confirmationAnnulationRdv =
      'Confirmer l\'annulation de ce rendez-vous ?';
  static const String confirmationRestauration =
      'Cette opération remplacera toutes les données actuelles. '
      'Confirmer la restauration ?';

  // ── Paramètres ────────────────────────────────────────────
  static const String titreParametres = 'Paramètres';
  static const String sectionMonProfil = 'Mon profil';
  static const String sectionSecurite  = 'Sécurité';
  static const String sectionDonnees   = 'Mes données';
  static const String sectionAPropos   = 'À propos';

  // ── Constantes personnalisées ──────────────────────────────
  static const String titreConstantesPersonnalisees =
      'Constantes personnalisées';
  static const String messageConstantesPersonnalisees =
      'Définissez ici les constantes médicales que vous souhaitez suivre '
      'pour le profil "Personnalisé".';
  static const String confirmationReconfigurationConstantes =
      'Le profil médical est désormais "Personnalisé" mais aucune '
      'constante personnalisée n\'existe encore. Voulez-vous les définir '
      'maintenant ?';
  static const String boutonConfigurerConstantes = 'Définir mes constantes';
  static const String confirmationRemplacementConstantes =
      'Enregistrer remplacera toutes les constantes personnalisées '
      'existantes et les consultations passées conserveront leurs valeurs '
      'déjà saisies. Confirmer ?';
  static const String succesConstantesReconfigurees =
      'Constantes personnalisées enregistrées.';
  static const String aucuneConstantePersonnalisee =
      'Aucune constante définie pour le moment.';
}
