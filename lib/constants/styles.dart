// ============================================================
// styles.dart – Thème Flutter et styles de texte de MediHub
// Police : Nunito (Google Fonts). Material 3 activé.
// ============================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'couleurs.dart';
import 'dimensions.dart';

abstract class Styles {
  /// Retourne le ThemeData clair complet de l'application.
  static ThemeData themeClair() {
    final ColorScheme schema = ColorScheme.fromSeed(
      seedColor: Couleurs.primaire,
      brightness: Brightness.light,
      primary: Couleurs.primaire,
      secondary: Couleurs.secondaire,
      error: Couleurs.urgence,
      surface: Couleurs.surface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: schema,
      scaffoldBackgroundColor: Couleurs.fond,

      appBarTheme: AppBarTheme(
        backgroundColor: Couleurs.primaire,
        foregroundColor: Couleurs.texteSurFond,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: Dimensions.texteTitreH2,
          fontWeight: FontWeight.w700,
          color: Couleurs.texteSurFond,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Couleurs.primaire,
          foregroundColor: Couleurs.texteSurFond,
          minimumSize: const Size(double.infinity, Dimensions.hauteurBouton),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.rayonBouton),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: Dimensions.texteCorps,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Couleurs.primaire,
          minimumSize: const Size(double.infinity, Dimensions.hauteurBouton),
          side: const BorderSide(color: Couleurs.primaire),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.rayonBouton),
          ),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Couleurs.secondaire,
        foregroundColor: Couleurs.texteSurFond,
        elevation: Dimensions.elevationFab,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Couleurs.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingMoyen,
          vertical: Dimensions.paddingMoyen,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.rayonChamp),
          borderSide: const BorderSide(color: Couleurs.separateur),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.rayonChamp),
          borderSide: const BorderSide(color: Couleurs.separateur),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.rayonChamp),
          borderSide: const BorderSide(color: Couleurs.primaire, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.rayonChamp),
          borderSide: const BorderSide(color: Couleurs.urgence),
        ),
        labelStyle: GoogleFonts.nunito(
          color: Couleurs.texteSecondaire,
          fontSize: Dimensions.texteSecondaire,
        ),
        errorStyle: GoogleFonts.nunito(
          color: Couleurs.urgence,
          fontSize: Dimensions.texteSecondaire,
        ),
      ),

      cardTheme: CardThemeData(
        color: Couleurs.surface,
        elevation: Dimensions.elevationCarte,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.rayonCarte),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingMoyen,
          vertical: Dimensions.paddingPetit,
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Couleurs.surface,
        selectedItemColor: Couleurs.primaire,
        unselectedItemColor: Couleurs.texteSecondaire,
        type: BottomNavigationBarType.fixed,
      ),

      dividerTheme: const DividerThemeData(
        color: Couleurs.separateur,
        thickness: 1,
        space: 1,
      ),

      textTheme: GoogleFonts.nunitoTextTheme(),
    );
  }
}
