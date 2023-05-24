// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/log/manager.dart';

import 'package:fml/system.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/datasources/base/model.dart';
import 'package:xml/xml.dart';
import 'gps_litener_interface.dart';
import 'payload.dart';
import 'package:fml/helper/common_helpers.dart';

class GpsModel extends DataSourceModel implements IDataSource, IGpsListener
{
  @override
  bool get autoexecute => super.autoexecute ?? true;

  GpsModel(WidgetModel parent, String? id) : super(parent, id);

  static GpsModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    GpsModel? model;
    try
    {
      model = GpsModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'gps.Model');
      model = null;
    }
    return model;
  }

  @override
  void dispose()
  {
    System().gps.removeListener(this);
    super.dispose();
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {
    // deserialize
    super.deserialize(xml);
  }

  @override
  Future<bool> start({bool refresh = false, String? key}) async
  {
     System().gps.registerListener(this);
     return true;
  }

  @override
  Future<bool> stop() async
  {
    System().gps.removeListener(this);
    super.stop();
    return true;
  }

  @override
  onGpsData({Payload? payload})
  {
    // enabled?
    if (enabled == false) return;

    busy = false;

    if (payload != null)
    {
      // build data
      Data data = Data();
      data.add(payload.map);
      onSuccess(data, code: 200);
    } else {
      //we should check for permissions here and possibly have a permissiongranted="" permissiondenied="" event?
      onFail(Data(), code: 400);
    }
  }
}
