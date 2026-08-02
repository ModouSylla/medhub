// ============================================================
// carte_medihub.dart – Carte réutilisable MediHub
// ============================================================

import 'package:flutter/material.dart';
import '../../constants/dimensions.dart';

class CarteMediHub extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? couleurFond;
  final BorderSide? bordure;

  const CarteMediHub({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(Dimensions.paddingMoyen),
    this.couleurFond,
    this.bordure,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardChild = Padding(
      padding: padding,
      child: child,
    );

    if (onTap != null) {
      cardChild = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimensions.rayonCarte),
        child: cardChild,
      );
    }

    return Card(
      color: couleurFond,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.rayonCarte),
        side: bordure ?? BorderSide.none,
      ),
      child: cardChild,
    );
  }
}
