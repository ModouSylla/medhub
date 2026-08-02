// ============================================================
// ecran_pin.dart – Écran de saisie du code PIN
//
// Premier écran affiché à chaque lancement de l'application.
// Implémente le clavier numérique personnalisé et la logique
// de verrouillage après 5 tentatives incorrectes.
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/couleurs.dart';
import '../../constants/chaines.dart';
import '../../constants/dimensions.dart';
import '../../constants/routes.dart';
import '../../providers/auth_provider.dart';

class EcranPin extends StatefulWidget {
  const EcranPin({super.key});

  @override
  State<EcranPin> createState() => _EcranPinState();
}

class _EcranPinState extends State<EcranPin> {
  /// PIN saisi par le médecin (accumulation des chiffres).
  String _pinSaisi = '';

  /// Longueur requise du PIN.
  static const int _longueurPin = 4;

  @override
  void initState() {
    super.initState();
    // Vérifier l'état de verrouillage au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().verifierEtatVerrouillage();
    });
  }

  // ──────────────────────────────────────────────────────────
  // LOGIQUE DE SAISIE
  // ──────────────────────────────────────────────────────────

  /// Ajoute un chiffre au PIN en cours de saisie.
  void _ajouterChiffre(String chiffre) {
    if (_pinSaisi.length >= _longueurPin) return;
    setState(() {
      _pinSaisi += chiffre;
    });
    // Soumettre automatiquement quand 4 chiffres sont saisis
    if (_pinSaisi.length == _longueurPin) {
      _verifierPin();
    }
  }

  /// Efface le dernier chiffre saisi.
  void _effacerDernier() {
    if (_pinSaisi.isEmpty) return;
    setState(() {
      _pinSaisi = _pinSaisi.substring(0, _pinSaisi.length - 1);
    });
  }

  /// Soumet le PIN pour vérification.
  Future<void> _verifierPin() async {
    final bool succes =
        await context.read<AuthProvider>().verifierPin(_pinSaisi);

    if (succes && mounted) {
      // PIN correct : naviguer vers l'accueil
      Navigator.of(context).pushReplacementNamed(Routes.accueil);
    } else {
      // PIN incorrect : réinitialiser la saisie
      setState(() => _pinSaisi = '');
    }
  }

  // ──────────────────────────────────────────────────────────
  // INTERFACE
  // ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Couleurs.fond,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return Padding(
              padding: const EdgeInsets.all(Dimensions.paddingGrand),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Logo et titre ──────────────────────
                  const Icon(
                    Icons.local_hospital_rounded,
                    size: 64,
                    color: Couleurs.primaire,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    Chaines.nomApplication,
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(
                      color: Couleurs.primaire,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Chaines.titreSaisirPin,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: Couleurs.texteSecondaire),
                  ),
                  const SizedBox(height: 48),

                  // ── Indicateurs PIN (cercles) ──────────
                  _IndicateurPin(longueur: _pinSaisi.length),
                  const SizedBox(height: 24),

                  // ── Message d'état ────────────────────
                  if (auth.estVerrouille)
                    _MessageVerrouillage(minutes: auth.minutesVerrouillage)
                  else if (auth.messageErreur != null)
                    Text(
                      auth.messageErreur!,
                      style: const TextStyle(color: Couleurs.urgence),
                      textAlign: TextAlign.center,
                    ),

                  const SizedBox(height: 32),

                  // ── Clavier numérique ─────────────────
                  if (!auth.estVerrouille)
                    _ClavierNumerique(
                      onChiffrePresse: _ajouterChiffre,
                      onEffacer: _effacerDernier,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Widgets internes ─────────────────────────────────────────

/// Affiche 4 cercles représentant les chiffres saisis (pleins/vides).
class _IndicateurPin extends StatelessWidget {
  final int longueur;
  const _IndicateurPin({required this.longueur});

  static const int _totalPoints = 4;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_totalPoints, (index) {
        final bool rempli = index < longueur;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: rempli ? Couleurs.primaire : Colors.transparent,
            border: Border.all(color: Couleurs.primaire, width: 2),
          ),
        );
      }),
    );
  }
}

/// Message affiché pendant le verrouillage temporaire.
class _MessageVerrouillage extends StatelessWidget {
  final int minutes;
  const _MessageVerrouillage({required this.minutes});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingMoyen),
      decoration: BoxDecoration(
        color: Couleurs.suggestionUrgence,
        borderRadius: BorderRadius.circular(Dimensions.rayonCarte),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_outline, color: Couleurs.urgence),
          const SizedBox(width: 8),
          Text(
            '${Chaines.erreurVerrouillage} $minutes ${Chaines.minutes}',
            style: const TextStyle(color: Couleurs.urgence),
          ),
        ],
      ),
    );
  }
}

/// Clavier numérique personnalisé 3×4.
class _ClavierNumerique extends StatelessWidget {
  final Function(String) onChiffrePresse;
  final VoidCallback     onEffacer;

  const _ClavierNumerique({
    required this.onChiffrePresse,
    required this.onEffacer,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      childAspectRatio: 1.5,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        // Touches 1 à 9
        for (int i = 1; i <= 9; i++)
          _ToucbeChiffre(
            chiffre: '$i',
            onPresse: () => onChiffrePresse('$i'),
          ),
        // Ligne bas : vide | 0 | effacer
        const SizedBox(),
        _ToucbeChiffre(chiffre: '0', onPresse: () => onChiffrePresse('0')),
        _ToucheEffacer(onPresse: onEffacer),
      ],
    );
  }
}

/// Touche numérique du clavier PIN.
class _ToucbeChiffre extends StatelessWidget {
  final String       chiffre;
  final VoidCallback onPresse;

  const _ToucbeChiffre({required this.chiffre, required this.onPresse});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPresse,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(16),
        backgroundColor: Couleurs.surface,
        foregroundColor: Couleurs.textePrimaire,
        elevation: 1,
      ),
      child: Text(
        chiffre,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Touche d'effacement du clavier PIN.
class _ToucheEffacer extends StatelessWidget {
  final VoidCallback onPresse;
  const _ToucheEffacer({required this.onPresse});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPresse,
      icon: const Icon(Icons.backspace_outlined),
      color: Couleurs.texteSecondaire,
      iconSize: 28,
    );
  }
}
