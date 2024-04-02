// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/transforms/transform_interface.dart';
import 'package:fml/datasources/transforms/transform_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/helpers/helpers.dart';

class Format extends TransformModel implements ITransform {
  final String? filter;

  Format(WidgetModel parent, {String? id, this.filter}) : super(parent, id);

  static Format? fromXml(WidgetModel parent, XmlElement xml) {
    Format model = Format(
      parent,
      id: Xml.get(node: xml, tag: 'id'),
      filter: Xml.get(node: xml, tag: 'filter'),
    );
    model.deserialize(xml);
    return model;
  }

  @override
  void deserialize(XmlElement xml) {
    // Deserialize
    super.deserialize(xml);
  }

  _format(Data? data) {}

  @override
  apply(Data? data) async {
    if (enabled == false) return;
    _format(data);
  }
}
