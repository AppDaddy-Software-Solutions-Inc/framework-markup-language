import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fml/widgets/text/text_model.dart';
import 'package:fml/widgets/text/text_view.dart';

void main() {
  group('Text Widget', () {

    testWidgets('FML Text Widget View/Model', (tester) async {
      TextModel model = TextModel(null, 'id', value: 'Hello');
      TextView view = TextView(model);
      Widget widget = MaterialApp(home: SizedBox(child: view));
      await tester.pumpWidget(widget, Duration(seconds: 20));
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Hello', findRichText: true), findsOneWidget);
      view.model.dispose();
    });

  });
}