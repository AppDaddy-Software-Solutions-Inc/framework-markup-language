// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/http/get/model.dart';
import 'package:fml/datasources/http/model.dart';
import 'package:fml/datasources/transforms/transform_interface.dart';
import 'package:fml/datasources/transforms/transform_model.dart';
import 'package:fml/observable/binding.dart';

import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/helpers/helpers.dart';

class Query extends TransformModel implements ITransform {

  final String? source;
  final String? target;

  HttpModel? ds;

  Query(Model parent, {String? id, this.source, this.target})
      : super(parent, id);

  static Query? fromXml(Model parent, XmlElement xml) {
    Query model = Query(parent,
        id: Xml.get(node: xml, tag: 'id'),
        target: Xml.get(node: xml, tag: 'target'));

    // deserialize the model
    model.deserialize(xml);

    return model;
  }

  @override
  void deserialize(XmlElement xml) {

    // deserialize
    super.deserialize(xml);

    // find element
    for (XmlElement node in xml.childElements) {
      String name = node.localName.toLowerCase();
      if (name == 'get' && parent != null) {
        ds = HttpGetModel.fromXml(parent!, node);
        ds!.autoexecute = false;
        ds!.autoquery = false;
        ds!.timetolive = 0;
        ds!.canRunInBackground = false;
      }
      if (ds != null) break;
    }
  }

  _execute(Data? list) async {
    if (list == null || ds == null) return null;

    // register listener
    for (var row in list) {
      var url = ds!.urlObservable?.signature ?? ds!.url;
      if (url != null) {
        url = Binding.applyMap(url, row);
        ds!.url = url;
        await ds!.start(refresh: true);

        // save to the data set
        if (ds!.statuscode == 200) Data.write(row, target, ds!.data);
      }
    }
  }

  @override
  apply(Data? data) async {
    if (enabled == false) return;
    await _execute(data);
  }
}
