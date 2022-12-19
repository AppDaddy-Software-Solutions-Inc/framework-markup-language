import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fml/widgets/text/text_model.dart';
import 'package:fml/widgets/text/text_view.dart';

void main() {
  group('Text Widget', () {

    testWidgets('Visible Text Widget', (builder) async {
      TextModel model = TextModel(null, 'id', value: 'Hello');
      TextView view = TextView(model);
      Widget widget = MaterialApp(home: view);
      await builder.pumpWidget(widget);
      expect(find.text('Hello'), findsOneWidget);
    });

  });
}