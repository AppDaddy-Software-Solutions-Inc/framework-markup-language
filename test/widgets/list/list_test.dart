import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/list/list_model.dart';
import 'package:fml/widgets/list/list_view.dart';

void main() {
  group('List Widget', () {

    String xmlList = '''<LIST>
      <ITEM>
        <TEXT value="0" />
      </ITEM>
      <ITEM>
        <TEXT value="1" />
      </ITEM>
      <ITEM>
        <TEXT value="2" />
      </ITEM>
      <ITEM>
        <TEXT value="3" />
      </ITEM>
      <ITEM>
        <TEXT value="4" />
      </ITEM>
      <ITEM>
        <TEXT value="5" />
      </ITEM>
      <ITEM>
        <TEXT value="6" />
      </ITEM>
      <ITEM>
        <TEXT value="7" />
      </ITEM>
      <ITEM>
        <TEXT value="8" />
      </ITEM>
      <ITEM>
        <TEXT value="9" />
      </ITEM>
      <ITEM>
        <TEXT value="10" />
      </ITEM>
      <ITEM>
        <TEXT value="11" />
      </ITEM>
      <ITEM>
        <TEXT value="12" />
      </ITEM>
      <ITEM>
        <TEXT value="13" />
      </ITEM>
      <ITEM>
        <TEXT value="14" />
      </ITEM>
      <ITEM>
        <TEXT value="15" />
      </ITEM>
      <ITEM>
        <TEXT value="16" />
      </ITEM>
      <ITEM>
        <TEXT value="17" />
      </ITEM>
      <ITEM>
        <TEXT value="18" />
      </ITEM>
      <ITEM>
        <TEXT value="19" />
      </ITEM>
      <ITEM>
        <TEXT value="20" />
      </ITEM>
      <ITEM>
        <TEXT value="21" />
      </ITEM>
      <ITEM>
        <TEXT value="22" />
      </ITEM>
      <ITEM>
        <TEXT value="23" />
      </ITEM>
      <ITEM>
        <TEXT value="24" />
      </ITEM>
      <ITEM>
        <TEXT value="25" />
      </ITEM>
      <ITEM>
        <TEXT value="26" />
      </ITEM>
      <ITEM>
        <TEXT value="27" />
      </ITEM>
      <ITEM>
        <TEXT value="28" />
      </ITEM>
      <ITEM>
        <TEXT value="29" />
      </ITEM>
      <ITEM>
        <TEXT value="30" />
      </ITEM>
      <ITEM>
        <TEXT value="31" />
      </ITEM>
      <ITEM>
        <TEXT value="32" />
      </ITEM>
      <ITEM>
        <TEXT value="33" />
      </ITEM>
      <ITEM>
        <TEXT value="34" />
      </ITEM>
      <ITEM>
        <TEXT value="35" />
      </ITEM>
      <ITEM>
        <TEXT value="36" />
      </ITEM>
      <ITEM>
        <TEXT value="37" />
      </ITEM>
      <ITEM>
        <TEXT value="38" />
      </ITEM>
      <ITEM>
        <TEXT value="39" />
      </ITEM>
      <ITEM>
        <TEXT value="40" />
      </ITEM>
      <ITEM>
        <TEXT value="41" />
      </ITEM>
      <ITEM>
        <TEXT value="42" />
      </ITEM>
      <ITEM>
        <TEXT value="43" />
      </ITEM>
      <ITEM>
        <TEXT value="44" />
      </ITEM>
      <ITEM>
        <TEXT value="45" />
      </ITEM>
      <ITEM>
        <TEXT value="46" />
      </ITEM>
      <ITEM>
        <TEXT value="47" />
      </ITEM>
      <ITEM>
        <TEXT value="48" />
      </ITEM>
      <ITEM>
        <TEXT value="49" />
      </ITEM>
    </LIST>''';



    // XmlElement xmlItem(int index) {
    //   String i = index.toString();
    //   String str = '''<ITEM><TEXT value="$i" /></ITEM>''';
    //   XmlDocument doc = XmlDocument.parse(str);
    //   return doc.rootElement;
    // }
    //
    // List<ITEM.Model> items = List<ITEM.Model>.generate(100, (index)
    //   => ITEM.Model? fromXml(null, xmlItem(index)));

    testWidgets('Generated ListView Widget', (tester) async
    {
      var model = ListModel.fromXml(null, XmlDocument.parse(xmlList).rootElement);
      var view3;
      if (model != null) view3 = ListLayoutView(model);

      Widget widget = MaterialApp(home: Scaffold(body: view3));
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();
      expect(find.text('0'), findsOneWidget);
      // Left Dragging: Offset(-500.0, 0.0), Right Dragging: Offset(+500.0, 0.0),
      // Up Dragging: Offset(0.0, +500.0), Down Dragging: Offset(0.0, -500.0)
      await tester.fling(find.byType(ListView), Offset(0, -400), 4000);
      await tester.pumpAndSettle();
      expect(find.text('0'), findsNothing);
      expect(find.text('49'), findsOneWidget);
    });
    
    testWidgets('Generated Collapsed ListView Widget', (tester) async
    {
      XmlDocument xml = XmlDocument.parse(xmlList);
      xml.rootElement.attributes.add(XmlAttribute(XmlName('collapsed'), 'true'));

      List<XmlElement> items = xml.findAllElements('ITEM', namespace: "*").toList();
      for (var element in items) {
        element.attributes.add(XmlAttribute(XmlName('title'), element.firstElementChild!.attributes.first.value));
      }
      dynamic view = ListModel.fromXml(null, xml.rootElement);
      if(view != null) view = ListLayoutView(view);

      Widget widget = MaterialApp(home: Scaffold(body: view));
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();
      expect(find.text('0'), findsNWidgets(2));
      expect(find.byType(MaterialGap), findsNothing);
      await tester.tap(find.text('1').first/*byIcon(Icons.expand_more)*/);
      await tester.pumpAndSettle();
      await tester.fling(find.byType(SingleChildScrollView), Offset(0, -400), 4000);
      await tester.pumpAndSettle();
      // expect(find.text('0'), findsNothing);
      expect(find.text('49'), findsNWidgets(2));
    });

  });
}