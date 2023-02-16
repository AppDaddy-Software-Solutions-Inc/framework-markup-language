// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/iDataSource.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/datasources/base/model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

enum DetectorSources {image, stream, any}

class DetectorModel extends DataSourceModel implements IDataSource
{
  // source of image
  DetectorSources? source;

  // count
  IntegerObservable? _count;
  set count(dynamic v)
  {
    if (_count != null)
    {
      _count!.set(v);
    }
    else if (v != null)
    {
      _count = IntegerObservable(Binding.toKey(id, 'count'), v, scope: scope, listener: onPropertyChange);
    }
  }
  int get count
  {
    if (_count == null) return 0;
    return _count?.get() ?? 0;
  }

  // item was detected
  IntegerObservable? _detected;
  set detected(dynamic v)
  {
    if (_detected != null)
    {
      _detected!.set(v);
    }
    else if (v != null)
    {
      _detected = IntegerObservable(Binding.toKey(id, 'detected'), v, scope: scope, listener: onPropertyChange);
    }
  }
  int get detected => _detected?.get() ?? 0;

  DetectorModel(WidgetModel parent, String? id) : super(parent, id);

  static DetectorModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    DetectorModel? model;
    try
    {
      model = DetectorModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'detector.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {

    super.deserialize(xml);

    enabled   = Xml.get(node: xml, tag: 'enabled');
    source    = S.toEnum(Xml.get(node: xml, tag: 'source'), DetectorSources.values) ?? DetectorSources.any;
  }

  Future<bool> onDetected(Data data) async
  {
    // enabled?
    if (enabled == false) return true;

    // notify listeners

      detected = detected + 1;
      return await onSuccess(data, code: 200);
  }

  Future<bool> onDetectionFailed(Data data) async
  {
    // notify listeners
    return await onFail(data);
  }
}

