// ============================================================
// ecran_notifications.dart – Alertes et rappels
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/couleurs.dart';
import '../../constants/routes.dart';
import '../../models/consultation.dart';
import '../../models/patient.dart';
import '../../providers/agenda_provider.dart';
import '../../repositories/consultation_repository.dart';
import '../../repositories/patient_repository.dart';
import '../../services/notification_service.dart';
import '../../utils/date_utils.dart';
import '../../widgets/commun/message_vide.dart';

class EcranNotifications extends StatefulWidget {
  const EcranNotifications({super.key});

  @override
  State<EcranNotifications> createState() => _EcranNotificationsState();
}

class _EcranNotificationsState extends State<EcranNotifications> {
  final PatientRepository _repoPatient = PatientRepository();
  final ConsultationRepository _repoConsult = ConsultationRepository();

  List<_AlerteNotification> _alertes = [];
  bool _enChargement = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _charger());
  }

  Future<void> _charger() async {
    setState(() => _enChargement = true);
    final List<_AlerteNotification> alertes = [];

    await context.read<AgendaProvider>().chargerRdvJour(DateTime.now());
    for (final rdv in context.read<AgendaProvider>().rdvJour) {
      if (!rdv.estBlocage) {
        alertes.add(_AlerteNotification(
          icone: Icons.calendar_today,
          couleur: Couleurs.primaire,
          titre: 'Rendez-vous aujourd\'hui',
          message: '${rdv.nomPatient ?? 'Patient'} à '
              '${AppDateUtils.formaterHeure(rdv.heureDebut)}',
          idPatient: rdv.idPatient,
        ));
      }
    }

    final idsExamen = await _repoConsult.obtenirIdsExamenEnAttente();
    // Reprogramme le rappel quotidien (8h) avec le compte à jour
    // (cahier des charges §19.2, BF-06.2).
    await NotificationService().planifierRappelExamen(idsExamen.length);
    for (final id in idsExamen) {
      final Patient? patient = await _repoPatient.obtenirPatientParId(id);
      if (patient == null) continue;
      alertes.add(_AlerteNotification(
        icone: Icons.biotech_outlined,
        couleur: Couleurs.accent,
        titre: 'Examen en attente',
        message: patient.obtenirNomComplet(),
        idPatient: id,
      ));
    }

    final patients = await _repoPatient.obtenirTousLesPatients();
    for (final patient in patients) {
      if (patient.idPatient == null) continue;
      final Consultation? derniere = await _repoConsult
          .obtenirDerniereConsultation(patient.idPatient!);
      if (derniere != null && derniere.rappelUrgent) {
        alertes.add(_AlerteNotification(
          icone: Icons.priority_high,
          couleur: Couleurs.urgence,
          titre: 'Rappel urgent',
          message: patient.obtenirNomComplet(),
          idPatient: patient.idPatient,
        ));
      }
    }

    if (mounted) {
      setState(() {
        _alertes = alertes;
        _enChargement = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: _enChargement
          ? const Center(child: CircularProgressIndicator())
          : _alertes.isEmpty
              ? const MessageVide(
                  icone: Icons.notifications_none,
                  message: 'Aucune alerte pour le moment.',
                )
              : RefreshIndicator(
                  onRefresh: _charger,
                  child: ListView.builder(
                    itemCount: _alertes.length,
                    itemBuilder: (context, index) {
                      final alerte = _alertes[index];
                      return Card(
                        child: ListTile(
                          leading: Icon(alerte.icone, color: alerte.couleur),
                          title: Text(alerte.titre),
                          subtitle: Text(alerte.message),
                          onTap: alerte.idPatient != null
                              ? () => Navigator.pushNamed(
                                    context,
                                    Routes.carnetPatient,
                                    arguments: alerte.idPatient,
                                  )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class _AlerteNotification {
  final IconData icone;
  final Color couleur;
  final String titre;
  final String message;
  final int? idPatient;

  _AlerteNotification({
    required this.icone,
    required this.couleur,
    required this.titre,
    required this.message,
    this.idPatient,
  });
}
