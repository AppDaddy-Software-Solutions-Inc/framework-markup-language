// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

class TagModel extends WidgetModel {
  // value
  StringObservable? _value;
  set value(dynamic v) {
    if (_value != null) {
      _value!.set(v);
    } else if (v != null) {
      _value = StringObservable(null, v, scope: scope);
    }
  }

  String? get value => _value?.get();

  TagModel(WidgetModel super.parent, super.id, {String? value}) {
    if (value != null) this.value = value;
  }

  static TagModel? fromXml(WidgetModel parent, XmlElement? xml) {
    TagModel? model = TagModel(parent, Xml.get(node: xml, tag: 'id'));
    model.deserialize(xml);
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement? xml) {
    if (xml == null) return;

    //super.deserialize(xml);

    // Properties
    value = Xml.get(node: xml, tag: 'value');
  }
}
