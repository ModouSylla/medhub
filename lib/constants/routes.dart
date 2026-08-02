// ============================================================
// routes.dart – Noms des routes nommées de MediHub
// Centralise les chemins pour éviter toute faute de frappe.
// ============================================================

abstract class Routes {
  static const String pin                    = '/pin';
  static const String configuration          = '/configuration';
  static const String accueil                = '/accueil';
  static const String listePatients          = '/patients';
  static const String patientsArchives       = '/patients/archives';
  static const String inscriptionPatient     = '/patients/inscription';
  static const String carnetPatient          = '/patients/carnet';
  static const String modificationPatient    = '/patients/modification';
  static const String detailConsultation     = '/consultations/detail';
  static const String formulaireConsultation = '/consultations/nouveau';
  static const String agenda                 = '/agenda';
  static const String formulaireRdv          = '/agenda/rdv';
  static const String notifications          = '/notifications';
  static const String parametres             = '/parametres';
  static const String profilMedecin          = '/parametres/profil';
  static const String constantesPersonnalisees = '/parametres/constantes-personnalisees';
  static const String sauvegarde             = '/parametres/sauvegarde';
  static const String aPropos                = '/parametres/apropos';
}
