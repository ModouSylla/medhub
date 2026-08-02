// ============================================================
// ecran_parametres.dart – Paramètres de l'application
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/chaines.dart';
import '../../constants/routes.dart';
import '../../models/profil_medecin.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profil_provider.dart';

class EcranParametres extends StatefulWidget {
  const EcranParametres({super.key});

  @override
  State<EcranParametres> createState() => _EcranParametresState();
}

class _EcranParametresState extends State<EcranParametres> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfilProvider>().chargerProfil();
    });
  }

  Future<void> _changerPin() async {
    final ancienCtrl = TextEditingController();
    final nouveauCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(Chaines.boutonModifierPin),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ancienCtrl,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Ancien PIN'),
            ),
            TextField(
              controller: nouveauCtrl,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Nouveau PIN'),
            ),
            TextField(
              controller: confirmCtrl,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Confirmer'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(Chaines.boutonAnnuler),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(Chaines.boutonConfirmer),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;
    if (nouveauCtrl.text != confirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Les PIN ne correspondent pas.')),
      );
      return;
    }

    final succes = await context.read<AuthProvider>().changerPin(
          ancienCtrl.text,
          nouveauCtrl.text,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          succes ? 'PIN modifié avec succès.' : 'Échec de la modification.',
        ),
      ),
    );
  }

  void _deconnecter() {
    context.read<AuthProvider>().seDeconnecter();
    Navigator.of(context).pushNamedAndRemoveUntil(
      Routes.pin,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profil = context.watch<ProfilProvider>().profil;

    return Scaffold(
      appBar: AppBar(title: const Text(Chaines.titreParametres)),
      body: ListView(
        children: [
          if (profil != null)
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(profil.obtenirNomComplet()),
              subtitle: Text('${profil.specialite} • '
                  '${profil.profilMedical.obtenirLibelle()}'),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text(Chaines.sectionMonProfil),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, Routes.profilMedecin),
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text(Chaines.sectionSecurite),
            subtitle: const Text(Chaines.boutonModifierPin),
            onTap: _changerPin,
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Verrouiller l\'application'),
            onTap: _deconnecter,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.save_outlined),
            title: const Text(Chaines.sectionDonnees),
            subtitle: const Text('Export / restauration'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, Routes.sauvegarde),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text(Chaines.sectionAPropos),
            subtitle: const Text('MediHub v1.0.0 – UGB L3 Info 2026'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, Routes.aPropos),
          ),
        ],
      ),
    );
  }
}
