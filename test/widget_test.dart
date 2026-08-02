import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'package:medihub/app_routes.dart';
import 'package:medihub/providers/profil_provider.dart';

void main() {
  testWidgets('Écran de démarrage affiche un indicateur de chargement',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ProfilProvider(),
        child: const MaterialApp(home: EcranDemarrage()),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
