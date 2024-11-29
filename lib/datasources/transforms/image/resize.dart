// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/transforms/transform_interface.dart';
import 'package:fml/datasources/transforms/image/image_transform_model.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/observable/observables/integer.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/helpers/helpers.dart';

class Resize extends ImageTransformModel implements ITransform {

  /// width
  IntegerObservable? _width;
  set width(dynamic v) {
    if (_width != null) {
      _width!.set(v);
    } else if (v != null) {
      _width = IntegerObservable(Binding.toKey(id, 'width'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  int get width => _width?.get() ?? 0;

  /// height
  IntegerObservable? _height;
  set height(dynamic v) {
    if (_height != null) {
      _height!.set(v);
    } else if (v != null) {
      _height = IntegerObservable(Binding.toKey(id, 'height'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  int get height => _height?.get() ?? 0;

  Resize(Model parent, {String? id}) : super(parent, id);

  static Resize? fromXml(Model parent, XmlElement xml) {
    Resize model = Resize(parent, id: Xml.get(node: xml, tag: 'id'));
    model.deserialize(xml);
    return model;
  }

  @override
  void deserialize(XmlElement xml) {
    // Deserialize
    super.deserialize(xml);

    // Properties
    width = Xml.get(node: xml, tag: 'width');
    height = Xml.get(node: xml, tag: 'height');
  }

  @override
  apply(Data? data) async {
    if (enabled == false) return;
    if (data != null) await resizeImage(data, width, height);
  }
}
