// ============================================================
// ecran_a_propos.dart – Écran "À propos" de MediHub
// Affiche la version de l'application, l'équipe de développement
// et les informations institutionnelles (UGB – L3 Informatique).
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/chaines.dart';
import '../../constants/couleurs.dart';

/// Représente un membre de l'équipe ayant développé MediHub.
class _Developpeur {
  final String nom;
  final String email;

  const _Developpeur({required this.nom, required this.email});
}

class EcranAPropos extends StatelessWidget {
  const EcranAPropos({super.key});

  static const List<_Developpeur> _equipe = [
    _Developpeur(nom: 'Aïssa Thioye', email: 'thioye.aissa@ugb.edu.sn'),
    _Developpeur(nom: 'Modou Sylla', email: 'sylla.modou1@ugb.edu.sn'),
  ];

  Future<void> _copierEmail(BuildContext context, String email) async {
    await Clipboard.setData(ClipboardData(text: email));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Adresse copiée : $email')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Couleurs.fond,
      appBar: AppBar(title: const Text(Chaines.sectionAPropos)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Logo et nom de l'application ─────────────────────
          Center(
            child: Column(
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: Couleurs.primaire,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.medical_services_rounded,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  Chaines.nomApplication,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Couleurs.textePrimaire,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(color: Couleurs.texteSecondaire),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Description du projet ────────────────────────────
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Couleurs.separateur),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Carnet médical numérique permettant au médecin de '
                'centraliser l\'inscription des patients, leur suivi '
                'médical (diagnostics, traitements) et la gestion de '
                'ses rendez-vous, entièrement hors connexion.',
                style: TextStyle(height: 1.4),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Équipe de développement ──────────────────────────
          Text(
            'Développé par',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Couleurs.texteSecondaire,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Couleurs.separateur),
            ),
            child: Column(
              children: [
                for (int i = 0; i < _equipe.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Couleurs.primaire.withOpacity(0.12),
                      child: Text(
                        _equipe[i].nom.trim()[0],
                        style: const TextStyle(
                          color: Couleurs.primaire,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(_equipe[i].nom),
                    subtitle: Text(_equipe[i].email),
                    trailing: const Icon(Icons.copy_outlined, size: 18),
                    onTap: () => _copierEmail(context, _equipe[i].email),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Informations institutionnelles ───────────────────
          Text(
            'Établissement',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Couleurs.texteSecondaire,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Couleurs.separateur),
            ),
            child: const Column(
              children: [
                ListTile(
                  leading: Icon(Icons.school_outlined),
                  title: Text('Université Gaston Berger (UGB)'),
                  subtitle: Text('Section Informatique – L3 Informatique'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.menu_book_outlined),
                  title: Text('Module'),
                  subtitle: Text('Développement d\'Applications Mobile'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Center(
            child: Text(
              '© 2026 MediHub – Tous droits réservés',
              style: TextStyle(
                fontSize: 12,
                color: Couleurs.texteSecondaire,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
