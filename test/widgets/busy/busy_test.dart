import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fml/widgets/busy/busy_model.dart';
import 'package:fml/widgets/busy/busy_view.dart';

void main() {
  group('Busy Widget', () {

    testWidgets('Visible Busy Widget', (builder) async {
      BusyModel model = BusyModel(null, visible: true);
      BusyView view = BusyView(model);
      Widget widget = MaterialApp(home: view);
      await builder.pumpWidget(widget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

  });
}