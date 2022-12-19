import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fml/system.dart';
import 'package:integration_test/integration_test.dart';

import 'package:fml/main.dart' as MAIN;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('[E2E TEST]', ()
  {
    test('Compile Completed', () async => print('Commencing Application Testing'));
    testWidgets('Application Startup Profile', (tester) async {
      await binding.traceAction(
            () async {
          await tester.pump(MAIN.main());
          await tester.pumpAndSettle();
          print('Running on ${System().domain}');
          expect(System().domain, 'http://test.appdaddy.co');
        },
        reportKey: 'initialize',
      );
    });
    testWidgets('Navigate to Integration Tests from Main Menu (MAIN.xml)', (tester) async {
      await binding.traceAction(
        () async {
          await tester.pumpAndSettle();
          await tester.scrollUntilVisible(find.widgetWithText(Center, 'integration-test'), 100);
          expect(find.widgetWithText(Center, 'integration-test'), findsOneWidget);
        },
        reportKey: 'navigate to integration tests',
      );
    });
  });
}