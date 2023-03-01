import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fml/system.dart';
import 'package:integration_test/integration_test.dart';

import 'package:fml/main.dart' as MAIN;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('[E2E INTEGRATION TEST]', ()
  {
    test('Compile Completed', () async => print('[PRINT] Commencing Application Testing'));
    testWidgets('Application Startup Profile', (tester) async {
    MAIN.main();
    await tester.pumpAndSettle();
    print('[PRINT] Pumping');
    await tester.pump(Duration(seconds: 20));
    print('[PRINT] Running on ${System().domain}');
    expect(System().domain, 'https://test.appdaddy.co');
    });
    testWidgets('Navigate to Integration Tests from Main Menu (MAIN.xml)', (tester) async {
      await tester.pumpAndSettle();
      print('[PRINT] Scrolling to Menu Button');
      await tester.scrollUntilVisible(find.widgetWithIcon(Column, Icons.developer_mode), 100);
      expect(find.widgetWithIcon(Column, Icons.developer_mode), findsOneWidget);
      print('[PRINT] Tapping Menu Button');
      final Finder menuButton = find.byIcon(Icons.developer_mode);
      await tester.tap(menuButton);
    });
  });
}