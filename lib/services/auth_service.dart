// ============================================================
// auth_service.dart – Service d'authentification PIN
//
// Gère le hachage SHA-256 du code PIN et sa vérification.
// Le PIN en clair n'est JAMAIS stocké sur l'appareil.
// ============================================================
import 'dart:convert';
import 'package:crypto/crypto.dart';

class AuthService {
  /// Retourne le hash SHA-256 hexadécimal d'un code PIN.
  ///
  /// Exemple : hasherPin("1234") → "03ac674219..."
  /// Ce hash est stocké en base à la place du PIN.
  String hasherPin(String pin) {
    // Encoder le PIN en bytes UTF-8
    final List<int> bytes = utf8.encode(pin);
    // Calculer le digest SHA-256
    final Digest digest = sha256.convert(bytes);
    // Retourner la représentation hexadécimale
    return digest.toString();
  }

  /// Vérifie si un PIN saisi correspond au hash stocké.
  ///
  /// [pinSaisi]   : code PIN en clair tapé par le médecin.
  /// [hashStocke] : hash SHA-256 stocké en base de données.
  /// Retourne true si le PIN est correct.
  bool verifierPin(String pinSaisi, String hashStocke) {
    // Hacher le PIN saisi et comparer au hash stocké
    return hasherPin(pinSaisi) == hashStocke;
  }
}
