// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/transforms/transform_interface.dart';
import 'package:fml/datasources/transforms/transform_model.dart';
import 'package:fml/eval/eval.dart' as fml_eval;
import 'package:fml/observable/binding.dart';

import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/helpers/helpers.dart';

class Eval extends TransformModel implements ITransform {
  @override
  final String? source;
  final String? target;

  Eval(Model? parent, {String? id, this.source, this.target})
      : super(parent, id);

  static Eval? fromXml(Model? parent, XmlElement xml) {
    Eval model = Eval(
      parent,
      id: Xml.get(node: xml, tag: 'id'),
      source: Xml.get(node: xml, tag: "source"),
      target: Xml.get(node: xml, tag: "target"),
    );
    model.deserialize(xml);
    return model;
  }

  @override
  void deserialize(XmlElement xml) {
    // Deserialize
    super.deserialize(xml);
  }

  _eval(Data? list) {
    if ((list == null) || (source == null)) return null;

    List<Binding>? bindings = Binding.getBindings(source);
    for (var row in list) {
      // get variables
      Map<String?, dynamic> variables = Data.find(bindings, row);

      // evaluate
      var value = fml_eval.Eval.evaluate(source, variables: variables);

      // save to the data set
      Data.write(row, target, value);
    }
  }

  @override
  apply(Data? data) async {
    if (enabled == false) return;
    _eval(data);
  }
}
