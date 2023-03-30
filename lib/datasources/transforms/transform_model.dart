// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class TransformModel extends WidgetModel
{
  /// enabled
  BooleanObservable? _enabled;
  set enabled(dynamic v)
  {
    if (_enabled != null)
    {
      _enabled!.set(v);
    }
    else if (v != null)
    {
      _enabled = BooleanObservable(Binding.toKey(id, 'enabled'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get enabled => _enabled?.get() ?? true;

  // row element
  ListObservable? _row;
  set row(dynamic v)
  {
    if (_row != null)
    {
      _row!.set(v);
    }
    else if (v != null)
    {
      _row = ListObservable(Binding.toKey(id, 'row'), null, scope: scope, listener: onPropertyChange);
      _row!.set(v);
    }
  }
  get row => _row?.get();

  /// source
  StringObservable? _source;
  set source (dynamic v)
  {
    if (_source != null)
    {
      _source!.set(v);
    }
    else if (v != null)
    {
      _source = StringObservable(Binding.toKey(id, 'source'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get source => _source?.get();

  TransformModel(WidgetModel? parent, String? id) : super(parent, id);

  static TransformModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    TransformModel? model;
    try
    {
      model = TransformModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'transform_model');
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

    // properties
    enabled = Xml.get(node: xml, tag: 'enabled');
    source  = Xml.get(node: xml, tag: 'source');
  }
}
