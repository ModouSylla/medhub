// ============================================================
// ecran_detail_consultation.dart – Détail d'une consultation
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/chaines.dart';
import '../../constants/couleurs.dart';
import '../../constants/dimensions.dart';
import '../../models/consultation.dart';
import '../../models/constante_consultation.dart';
import '../../providers/consultation_provider.dart';
import '../../providers/profil_provider.dart';
import '../../repositories/consultation_repository.dart';
import '../../models/profil_medecin.dart';
import '../../utils/date_utils.dart';
import '../../widgets/commun/dialogue_confirmation.dart';
import '../../widgets/constantes/liste_constantes.dart';

class EcranDetailConsultation extends StatefulWidget {
  final int idConsultation;
  final int idPatient;

  const EcranDetailConsultation({
    super.key,
    required this.idConsultation,
    required this.idPatient,
  });

  @override
  State<EcranDetailConsultation> createState() =>
      _EcranDetailConsultationState();
}

class _EcranDetailConsultationState extends State<EcranDetailConsultation> {
  Consultation? _consultation;
  List<ConstanteConsultation> _constantes = [];
  bool _enChargement = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _charger());
  }

  Future<void> _charger() async {
    final repo = ConsultationRepository();
    _consultation =
        await repo.obtenirConsultationParId(widget.idConsultation);

    if (_consultation != null && mounted) {
      await context.read<ProfilProvider>().chargerProfil();
      final profil = context.read<ProfilProvider>().profil;
      if (profil != null) {
        await context.read<ConsultationProvider>().chargerDefinitions(
              profil.profilMedical.versChaine(),
            );
      }
      _constantes = await context
          .read<ConsultationProvider>()
          .obtenirConstantes(widget.idConsultation);
    }

    if (mounted) setState(() => _enChargement = false);
  }

  Future<void> _marquerExamenRecu() async {
    final c = _consultation;
    if (c == null || c.idConsultation == null) return;

    final bool confirme = await afficherDialogueConfirmation(
      context,
      titre: Chaines.boutonMarquerExamenRecu,
      message: Chaines.confirmationExamenRecu,
      libelleConfirmer: Chaines.boutonConfirmer,
    );
    if (!confirme || !mounted) return;

    final bool ok = await context
        .read<ConsultationProvider>()
        .marquerExamenRecu(c.idConsultation!, c.idPatient);
    if (!mounted) return;

    if (ok) {
      setState(() {
        _consultation = c.copierAvec(examenEnAttente: false);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(Chaines.succesExamenRecu)),
      );
    } else {
      final String? erreur =
          context.read<ConsultationProvider>().messageErreur;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erreur ?? Chaines.erreurGenerique)),
      );
      context.read<ConsultationProvider>().effacerErreur();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_enChargement) {
      return Scaffold(
        appBar: AppBar(title: const Text('Consultation')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_consultation == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Consultation')),
        body: const Center(child: Text('Consultation introuvable.')),
      );
    }

    final c = _consultation!;

    return Scaffold(
      appBar: AppBar(title: const Text('Détail consultation')),
      body: ListView(
        padding: const EdgeInsets.all(Dimensions.paddingMoyen),
        children: [
          _SectionTitre(
            titre: 'Date',
            contenu: AppDateUtils.formaterDateLongue(c.dateConsultation),
          ),
          if (_constantes.isNotEmpty) ...[
            const SizedBox(height: Dimensions.paddingMoyen),
            ListeConstantes(constantes: _constantes),
          ],
          const SizedBox(height: Dimensions.paddingMoyen),
          _SectionTitre(titre: 'Diagnostic', contenu: c.diagnostic),
          const SizedBox(height: Dimensions.paddingMoyen),
          _SectionTitre(titre: 'Traitement', contenu: c.traitement),
          if (c.notes != null && c.notes!.isNotEmpty) ...[
            const SizedBox(height: Dimensions.paddingMoyen),
            _SectionTitre(titre: 'Notes', contenu: c.notes!),
          ],
          if (c.examenEnAttente || c.rappelUrgent) ...[
            const SizedBox(height: Dimensions.paddingMoyen),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (c.examenEnAttente)
                  ActionChip(
                    avatar: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Examen en attente'),
                    backgroundColor: Couleurs.suggestionAvertissement,
                    tooltip: Chaines.boutonMarquerExamenRecu,
                    onPressed: _marquerExamenRecu,
                  ),
                if (c.rappelUrgent)
                  Chip(
                    label: const Text('Rappel urgent'),
                    backgroundColor: Couleurs.suggestionUrgence,
                  ),
              ],
            ),
            if (c.examenEnAttente)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Appuyez sur le badge pour marquer l\'examen comme reçu.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Couleurs.texteSecondaire,
                      ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _SectionTitre extends StatelessWidget {
  final String titre;
  final String contenu;

  const _SectionTitre({required this.titre, required this.contenu});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titre,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: Couleurs.texteSecondaire,
              ),
        ),
        const SizedBox(height: 4),
        Text(contenu, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
