// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/observable/observables/boolean.dart';
import 'package:fml/observable/observables/double.dart';
import 'package:fml/observable/observables/integer.dart';
import 'package:fml/observable/observables/string.dart';
import 'package:fml/widgets/widget/decorated_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:xml/xml.dart';
import 'package:fml/helper/common_helpers.dart';

class TooltipModel extends DecoratedWidgetModel
{
  // top, bottom, left, right
  StringObservable? _position;
  set position(dynamic v)
  {
    if (_position != null)
    {
      _position!.set(v);
    }
    else if (v != null)
    {
      _position = StringObservable(Binding.toKey(id, 'position'), v, scope: scope);
    }
  }
  String? get position => _position?.get();

  /// [distance] Space between the tooltip and the trigger.
  DoubleObservable? _distance;
  set distance(dynamic v)
  {
    if (_distance != null)
    {
      _distance!.set(v);
    }
    else if (v != null)
    {
      _distance = DoubleObservable(Binding.toKey(id, 'distance'), v, scope: scope, listener: onPropertyChange);
    }
  }
  double get distance => _distance?.get() ?? 0.0;

  /// [radius] Border radius around the tooltip.
  DoubleObservable? _radius;
  set radius(dynamic v) 
  {
    if (_radius != null) 
    {
      _radius!.set(v);
    } 
    else if (v != null) 
    {
      _radius = DoubleObservable(Binding.toKey(id, 'radius'), v, scope: scope, listener: onPropertyChange);
    }
  }
  double get radius => _radius?.get() ?? 5.0;

  /// [showModal] Shows a dark layer behind the tooltip.
  BooleanObservable? _modal;
  set modal(dynamic v)
  {
    if (_modal != null)
    {
      _modal!.set(v);
    }
    else if (v != null)
    {
      _modal = BooleanObservable(Binding.toKey(id, 'modal'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get modal => _modal?.get() ?? false;

  /// [timeout] Number of seconds until the tooltip disappears automatically
  /// The default value is 0 (zero) which means it never disappears.
  // timeout
  IntegerObservable? _timeout;
  set timeout(dynamic v)
  {
    if (_timeout != null)
    {
      _timeout!.set(v);
    }
    else if (v != null)
    {
      _timeout = IntegerObservable(Binding.toKey(id, 'timetoidle'), v, scope: scope, listener: onPropertyChange);
    }
  }
  int get timeout => _timeout?.get() ?? 0;

  TooltipModel(WidgetModel parent, String? id) : super(parent, id);

  static TooltipModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    TooltipModel? model;
    try
    {
      model = TooltipModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e, caller: 'tooltip.Model');
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
    radius   = Xml.attribute(node: xml, tag: 'radius');
    position = Xml.attribute(node: xml, tag: 'position');
    modal    = Xml.attribute(node: xml, tag: 'modal');
    timeout  = Xml.get(node: xml, tag: 'timeout');
    distance = Xml.get(node: xml, tag: 'distance');
  }

  @override
  dispose()
  {
    // Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }
}
