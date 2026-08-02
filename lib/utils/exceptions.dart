// ============================================================
// exceptions.dart – Exceptions métier de MediHub
//
// RepositoryException est levée par la couche Repositories quand
// une opération SQLite échoue. Elle transporte un message déjà
// lisible par l'utilisateur (à afficher tel quel dans l'UI),
// tandis que l'erreur technique d'origine est conservée dans
// [causeTechnique] pour le journal d'erreurs / le débogage.
// ============================================================
class RepositoryException implements Exception {
  final String message;
  final Object? causeTechnique;

  const RepositoryException(this.message, {this.causeTechnique});

  @override
  String toString() => message;
}
