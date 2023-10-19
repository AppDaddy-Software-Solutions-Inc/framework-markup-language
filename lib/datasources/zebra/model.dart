// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/base/model.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:fml/datasources/zebra/wedge.dart' as zebra;
import 'package:fml/datasources/detectors/barcode/barcode_detector.dart';
import 'package:fml/datasources/zebra/wedge.dart';
import 'package:xml/xml.dart';
import 'package:fml/helper/common_helpers.dart';

class ZebraModel extends DataSourceModel implements IDataSource, IZebraListener
{
  // disable datasource by default when not top of stack
  // override by setting background="true"
  @override
  bool get enabledInBackground => false;

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
      Log().exception(e,  caller: 'zebra.Model');
      model = null;
    }
    return model;
  }

  @override
  void dispose()
  {
    zebra.Reader().removeListener(this);
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

  @override
  Future<bool> start({bool refresh = false, String? key}) async
  {
    zebra.Reader().registerListener(this);
    //zebra.Reader().startScan();
    return true;
  }

  @override
  Future<bool> stop() async
  {
    zebra.Reader().removeListener(this);
    super.stop();
    return true;
  }

  @override
  onZebraData({Payload? payload})
  {
    // enabled?
    if (enabled == false) return;

    if ((payload == null) || (payload.barcodes.isEmpty)) return;

    Data data = Data();
    for (var barcode in payload.barcodes) {
      Map<dynamic, dynamic> map = <dynamic, dynamic>{};
      map["type"]    = barcode.type != null ? barcode.type.toString() : "";
      map["source"]  = barcode.source ?? "";
      map["format"]  = barcode.format;
      map["display"] = barcode.display;
      map["barcode"] = barcode.barcode != null ? barcode.barcode!.trim() : "";
      if (barcode.parameters != null) barcode.parameters!.forEach((key, value) => map[key] = value);
      data.add(map);
    }

    onSuccess(data, code: 200);
  }
}
