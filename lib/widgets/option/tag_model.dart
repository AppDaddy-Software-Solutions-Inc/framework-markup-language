// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/widgets/widget/model.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

enum TagType {contains, startswith, endwith, equal, keyword}

class TagModel extends Model {

  // option type
  String? _type;
  TagType get type => toEnum(_type, TagType.values) ?? TagType.contains;

  bool? _ignoreCase;
  bool get ignoreCase => _ignoreCase ?? true;

  // tag value
  StringObservable? _value;
  set value(dynamic v) {
    if (_value != null) {
      _value!.set(v);
    } else if (v != null) {
      _value = StringObservable(null, v, scope: scope);
    }
  }
  String? get value => _value?.get();

  // case sensitive?
  BooleanObservable? _caseSensitive;
  set caseSensitive(dynamic v) {
    if (_caseSensitive != null) {
      _caseSensitive!.set(v);
    } else if (v != null) {
      _caseSensitive = BooleanObservable(Binding.toKey(id, 'casesensitive'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  bool get caseSensitive => _caseSensitive?.get() ?? false;

  TagModel(Model super.parent, super.id, {String? value, String? type}) {
    if (value != null) this.value = value;
    if (type != null) _type = type;
  }

  static TagModel? fromXml(Model parent, XmlElement xml) {

    TagModel model = TagModel(parent, Xml.get(node: xml, tag: 'id'));

    model.deserialize(xml);

    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {

    // Properties
    _type = Xml.get(node: xml, tag: 'type');
    value = Xml.get(node: xml, tag: 'value');
    _ignoreCase = toBool(Xml.get(node: xml, tag: 'ignorecase'));
  }
}
