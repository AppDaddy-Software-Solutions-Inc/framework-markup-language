// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/base/model.dart';
import 'package:fml/datasources/detectors/iDetectable.dart';
import 'package:fml/datasources/iDataSource.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:fml/datasources/file/file.dart' as FILE;
import 'package:xml/xml.dart';
import 'package:fml/helper/helper_barrel.dart';

class FileModel extends DataSourceModel implements IDataSource
{
  // detectors
  List<IDetectable>? detectors;

  FileModel(WidgetModel parent, String? id) : super(parent, id);

  static FileModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    FileModel? model;
    try
    {
      model = FileModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'iframe.Model');
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

    // get detectors
    if (datasources != null)
    for (IDataSource source in datasources!)
    if (source is IDetectable)
    {
      if (detectors == null) detectors = [];
      detectors!.add(source as IDetectable);
    }
  }

  Future<bool> onFile(FILE.File file) async
  {
    busy = true;
      // save file reference
      if ((scope?.files != null) && (file.url != null))  scope!.files[file.url!] = file;

      // build the data
      Data data = Data();
      Map<dynamic, dynamic> map = Map<dynamic, dynamic>();
      map['file'] = file.url;
      map['name'] = file.name;
      map['type'] = file.mimeType;
      map['extension'] = ".${file.name}".split('.').last;
      map['size'] = file.size;

      // add map
      data.add(map);

      // notify listeners
      onResponse(data);

    busy = false;

    return true;
  }
}
