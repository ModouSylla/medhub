// ============================================================
// champ_texte_medihub.dart – Champ de texte réutilisable MediHub
// ============================================================

import 'package:flutter/material.dart';
import '../../constants/dimensions.dart';

class ChampTexteMediHub extends StatelessWidget {
  final TextEditingController? controller;
  final String labelText;
  final String? hintText;
  final IconData? icone;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool obscureText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;

  const ChampTexteMediHub({
    super.key,
    this.controller,
    required this.labelText,
    this.hintText,
    this.icone,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
    this.obscureText = false,
    this.suffixIcon,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingMoyen),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        maxLines: maxLines,
        obscureText: obscureText,
        onChanged: onChanged,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: icone != null ? Icon(icone) : null,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
