// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/transforms/transform_model.dart';
import 'package:fml/eval/eval.dart' as EVALUATE;
import 'package:fml/observable/binding.dart';

import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:fml/helper/helper_barrel.dart';

class Eval extends TransformModel implements IDataTransform
{
  final String? source;
  final String? target;

  Eval(WidgetModel? parent, {String? id, this.source, this.target}) : super(parent, id);

  static Eval? fromXml(WidgetModel? parent, XmlElement xml)
  {
    Eval model = Eval
        (
        parent,
        id        : Xml.get(node: xml, tag: 'id'),
        source    : Xml.get(node: xml, tag: "source"),
        target    : Xml.get(node: xml, tag: "target"),
      );
    model.deserialize(xml);
    return model;
  }

  @override
  void deserialize(XmlElement xml)
  {

    // Deserialize
    super.deserialize(xml);
  }

  _eval(Data? list)
  {
    if ((list== null) || (source == null)) return null;

    List<Binding>? bindings = Binding.getBindings(source);
    list.forEach((data)
    {
      try
      {
        // get variables
        Map<String?, dynamic> variables = Json.getVariables(bindings, data);

        // evaluate
        data[target] = EVALUATE.Eval.evaluate(source, variables: variables);
      }
      catch(e) {}
    });
  }

  apply(List? list) async
  {
    if (enabled == false) return;
    _eval(list as Data?);
  }
}