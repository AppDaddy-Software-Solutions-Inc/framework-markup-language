// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/datasources/file/model.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:xml/xml.dart';
import 'package:fml/helpers/helpers.dart';

class CameraImageModel extends FileModel implements IDataSource
{
  CameraImageModel(super.parent, super.id);

  static CameraImageModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    CameraImageModel? model;
    try
    {
      model = CameraImageModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e, caller: 'camera.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {

    // deserialize
    super.deserialize(xml);
  }
}
