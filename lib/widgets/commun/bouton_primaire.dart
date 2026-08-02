// ============================================================
// bouton_primaire.dart – Widget bouton principal réutilisable
// ============================================================
import 'package:flutter/material.dart';
import '../../constants/dimensions.dart';

/// Bouton principal de MediHub – pleine largeur par défaut.
class BoutonPrimaire extends StatelessWidget {
  final String   libelle;
  final VoidCallback? onPressed;  // null = désactivé
  final bool     enChargement;   // Affiche un spinner si true
  final IconData? icone;

  const BoutonPrimaire({
    super.key,
    required this.libelle,
    this.onPressed,
    this.enChargement = false,
    this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: Dimensions.hauteurBouton,
      child: ElevatedButton(
        onPressed: enChargement ? null : onPressed,
        child: enChargement
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icone != null) ...[
                    Icon(icone, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      libelle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
