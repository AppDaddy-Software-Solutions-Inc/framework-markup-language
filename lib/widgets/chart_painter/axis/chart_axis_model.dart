// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

enum ChartAxis {X, Y}
enum ChartAxisType {category, numeric, datetime, date, time}

/// Chart Axis [ChartAxisModel]
///
/// Defines the properties used to build a Charts's Axis
class ChartAxisModel extends WidgetModel
{

  /// Axis type: `category`, `numeric`, `datetime`, `date` or `time`
  ///
  /// This is used to help display the data on an axis correctly based on the data type
  StringObservable? _type;
  set type (dynamic v)
  {
    if (_type != null)
    {
      _type!.set(v);
    }
    else if (v != null)
    {
      _type = StringObservable(Binding.toKey(id, 'type'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get type => _type?.get();

  final ChartAxis axis;

  /// The title of an axis, displayed beside the axis
  StringObservable? _title;
  set title (dynamic v)
  {
    if (_title != null)
    {
      _title!.set(v);
    }
    else if (v != null)
    {
      _title = StringObservable(Binding.toKey(id, 'title'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get title => _title?.get();

  /// The interval of an axis, displayed beside the axis
  StringObservable? _interval;
  set interval (dynamic v)
  {
    if (_interval != null)
    {
      _interval!.set(v);
    }
    else if (v != null)
    {
      _interval = StringObservable(Binding.toKey(id, 'interval'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get interval => _interval?.get();

  /// Used to rotate long data labels so you can fit more, generally along the x axis
  IntegerObservable? _labelrotation;
  set labelrotation (dynamic v)
  {
    if (_labelrotation != null)
    {
      _labelrotation!.set(v);
    }
    else if (v != null)
    {
      _labelrotation = IntegerObservable(Binding.toKey(id, 'labelrotation'), v, scope: scope, listener: onPropertyChange);
    }
  }
  int get labelrotation => _labelrotation?.get() ?? 0;

  /// Sets the font size of the tick labels
  IntegerObservable? _labelsize;
  set labelsize (dynamic v)
  {
    if (_labelsize != null)
    {
      _labelsize!.set(v);
    }
    else if (v != null)
    {
      _labelsize = IntegerObservable(Binding.toKey(id, 'labelsize'), v, scope: scope, listener: onPropertyChange);
    }
  }
  int? get labelsize => _labelsize?.get();

  /// axis labels visibility
  BooleanObservable? _labelvisible;
  set labelvisible(dynamic v) {
    if (_labelvisible != null) {
      _labelvisible!.set(v);
    } else if (v != null) {
      _labelvisible = BooleanObservable(Binding.toKey(id, 'labelvisible'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  bool get labelvisible => _labelvisible?.get() ?? true;

  /// Used for X Axis Labels with a Time Series to format the DateTime with i18n spec
  /// examples: https://stackoverflow.com/a/16126580/8272202
  StringObservable? _format;
  set format (dynamic v)
  {
    if (_format != null)
    {
      _format!.set(v);
    }
    else if (v != null)
    {
      _format = StringObservable(Binding.toKey(id, 'format'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get format => _format?.get();

  /// Sets the minimum axis value to show, only intended for numeric axis
  StringObservable? _min;
  set min (dynamic v)
  {
    if (_min != null)
    {
      _min!.set(v);
    }
    else if (v != null)
    {
      _min = StringObservable(Binding.toKey(id, 'min'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get min {
    return _min?.get();
  }

  /// Sets the maximum axis value to show, only intended for numeric axis
  StringObservable? _max;
  set max (dynamic v)
  {
    if (_max != null)
    {
      _max!.set(v);
    }
    else if (v != null)
    {
      _max = StringObservable(Binding.toKey(id, 'max'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get max {
    return _max?.get();
  }

  /// Truncating a numeric y axis will prevent the y axis forcing 0(zero) as the baseline
  /// This allows the baseline to be based on the series' y data instead
  BooleanObservable? _truncate;
  set truncate(dynamic v) {
    if (_truncate != null) {
      _truncate!.set(v);
    } else if (v != null) {
      _truncate = BooleanObservable(Binding.toKey(id, 'truncate'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  bool get truncate => _truncate?.get() ?? false;

  ChartAxisModel(
      WidgetModel? parent,
      String?  id,
      this.axis,
      {
        dynamic type,
        dynamic labelrotation,
        dynamic labelvisible,
        dynamic labelsize,
        dynamic title,
        dynamic interval,
        dynamic format,
        dynamic min,
        dynamic max,
        dynamic truncate,
        // dynamic minimum,
        // dynamic maximum,
        // dynamic visibleminimum,
        // dynamic visiblemaximum,
        // dynamic fontsize,
        // dynamic fontcolor,
        // dynamic gridcolor,
        // dynamic interval,
        // dynamic intervaltype,
        // dynamic zoomfactor,
        // dynamic zoomposition,
      }) : super(parent, id)

  {
    this.labelrotation  = labelrotation;
    this.labelvisible   = labelvisible;
    this.labelsize      = labelsize;
    this.title          = title;
    this.interval       = interval;
    this.format         = format;
    this.min            = min;
    this.max            = max;
    this.truncate       = truncate;
    this.type           = type;
    // this.minimum        = minimum;
    // this.maximum        = maximum;
    // this.visibleminimum = visibleminimum;
    // this.visiblemaximum = visiblemaximum;
    // this.fontcolor      = fontcolor;
    // this.fontsize       = fontsize;
    // this.gridcolor      = gridcolor;
    // this.interval       = interval;
    // this.intervaltype   = intervaltype;
    // this.zoomfactor     = zoomfactor;
    // this.zoomposition   = zoomposition;

    if (S.isNullOrEmpty(type)) type = type?.trim().toLowerCase();

  }

  static ChartAxisModel? fromXml(WidgetModel parent, XmlElement xml, ChartAxis axis)
  {
    ChartAxisModel? model;
    try
    {
      model = ChartAxisModel(
        parent,
        Xml.get(node: xml, tag: 'id'),
        axis,
        title           : Xml.get(node: xml, tag: 'title'),
        interval        : Xml.get(node: xml, tag: 'interval'),
        labelrotation   : Xml.get(node: xml, tag: 'labelrotation'),
        labelvisible    : Xml.get(node: xml, tag: 'labelvisible'),
        labelsize       : Xml.get(node: xml, tag: 'labelsize'),
        format          : Xml.get(node: xml, tag: 'format'),
        type            : Xml.get(node: xml, tag: 'type'),
        min             : Xml.get(node: xml, tag: 'min'),
        max             : Xml.get(node: xml, tag: 'max'),
        truncate        : Xml.get(node: xml, tag: 'truncate'),
        // fontsize        : Xml.get(node: xml, tag: 'fontsize'),
        // fontcolor       : Xml.get(node: xml, tag: 'fontcolor'),
        // format          : Xml.get(node: xml, tag: 'format'),
        // minimum         : Xml.get(node: xml, tag: 'minimum'),
        // maximum         : Xml.get(node: xml, tag: 'maximum'),
        // visibleminimum  : Xml.get(node: xml, tag: 'minimum'),
        // visiblemaximum  : Xml.get(node: xml, tag: 'maximum'),
        // gridcolor       : Xml.get(node: xml, tag: 'gridcolor'),
        // interval        : Xml.get(node: xml, tag: 'interval'),
        // intervaltype    : Xml.get(node: xml, tag: 'intervaltype'),
        // zoomfactor      : Xml.get(node: xml, tag: 'zoomfactor'),
        // zoomposition    : Xml.get(node: xml, tag: 'zoomposition'),
      );
    }
    catch(e)
    {
      Log().exception(e, caller: 'chart.axis.Model');
      model = null;
    }
    return model;
  }
}