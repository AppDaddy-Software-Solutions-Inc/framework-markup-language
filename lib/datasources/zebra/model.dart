// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/base/model.dart';
import 'package:fml/datasources/iDataSource.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:fml/datasources/zebra/wedge.dart' as ZEBRA;
import 'package:fml/datasources/detectors/barcode/barcode_detector.dart';
import 'package:fml/datasources/zebra/wedge.dart';
import 'package:xml/xml.dart';
import 'package:fml/helper/common_helpers.dart';

class ZebraModel extends DataSourceModel implements IDataSource, IZebraListener
{
  @override
  bool get autoexecute => super.autoexecute ?? true;

  ZebraModel(WidgetModel parent, String? id) : super(parent, id);

  static ZebraModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    ZebraModel? model;
    try
    {
      model = ZebraModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'iframe.Model');
      model = null;
    }
    return model;
  }

  @override
  void dispose()
  {
    ZEBRA.Reader().removeListener(this);
    super.dispose();
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {

    // deserialize
    super.deserialize(xml);

    // properties
  }

  Future<bool> start({bool refresh: false, String? key}) async
  {
    ZEBRA.Reader().registerListener(this);
    ZEBRA.Reader.startScan();
    return true;
  }

  Future<bool> stop() async
  {
    ZEBRA.Reader().removeListener(this);
    super.stop();
    return true;
  }

  onZebraData({Payload? payload})
  {
    // enabled?
    if (enabled == false) return;

    if ((payload == null) || (payload.barcodes.isEmpty)) return;

    Data data = Data();
    payload.barcodes.forEach((barcode)
    {
      Map<dynamic, dynamic> map = Map<dynamic, dynamic>();
      map["type"]    = barcode.type != null ? barcode.type.toString() : "";
      map["format"]  = barcode.format;
      map["display"] = barcode.display;
      map["barcode"] = barcode.barcode != null ? barcode.barcode!.trim() : "";
      if (barcode.parameters != null) barcode.parameters!.forEach((key, value) => map[key] = value);
      data.add(map);
    });

    onResponse(data, code: 200);
  }
}
