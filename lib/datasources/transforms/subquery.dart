// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/datasources/http/model.dart';
import 'package:fml/datasources/transforms/transform_interface.dart';
import 'package:fml/datasources/transforms/transform_model.dart';
import 'package:fml/observable/binding.dart';

import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:fml/helper/common_helpers.dart';

class Query extends TransformModel implements ITransform
{
  @override
  final String? source;
  final String? target;

  Query(WidgetModel parent, {String? id, this.source, this.target}) : super(parent, id);

  static Query? fromXml(WidgetModel parent, XmlElement xml)
  {
    Query model = Query(parent,
        id        : Xml.get(node: xml, tag: 'id'),
        target    : Xml.get(node: xml, tag: "target"),
      );
    model.deserialize(xml);
    return model;
  }

  @override
  void deserialize(XmlElement xml)
  {
    // deserialize
    super.deserialize(xml);
    if (datasources != null && datasources!.isNotEmpty)
    {
      datasources!.first.autoexecute = false;
    }
  }

  _execute(Data? list) async
  {
    if (list == null || datasource == null || scope == null) return null;

    // register listener
    IDataSource? source = scope!.getDataSource(datasource);
    if (source is! HttpModel) return null;
    for (var row in list)
    {
      var url = source.urlObservable?.signature ?? source.url;
      if (url != null)
      {
        url = Binding.applyMap(url, row);
        source.url = url;
        await source.start(refresh: true);

        // save to the data set
        Data.writeValue(row, target, source.data);
      }
    }
  }

  @override
  apply(Data? data) async
  {
    if (enabled == false) return;
    _execute(data);
  }
}