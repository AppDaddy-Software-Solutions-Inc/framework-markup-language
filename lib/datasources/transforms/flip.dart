// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/transforms/transform_interface.dart';
import 'package:fml/datasources/transforms/image_transform_model.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/observable/observables/string.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/helpers/helpers.dart';

class Flip extends ImageTransformModel implements ITransform {
  /// axis
  StringObservable? _axis;
  set axis(dynamic v) {
    if (_axis != null) {
      _axis!.set(v);
    } else if (v != null) {
      _axis = StringObservable(Binding.toKey(id, 'axis'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String get axis => _axis?.get() ?? "horizontal";

  Flip(WidgetModel parent, {String? id}) : super(parent, id);

  static Flip? fromXml(WidgetModel parent, XmlElement xml) {
    Flip model = Flip(parent, id: Xml.get(node: xml, tag: 'id'));
    model.deserialize(xml);
    return model;
  }

  @override
  void deserialize(XmlElement xml) {
    // Deserialize
    super.deserialize(xml);

    // Properties
    axis = Xml.get(node: xml, tag: 'axis');
  }

  @override
  apply(Data? data) async {
    if (enabled == false) return;
    if (data != null) await flipImage(data, axis);
  }
}
