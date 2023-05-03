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
  ChartAxisType type = ChartAxisType.category;

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

  ChartAxisModel(
      WidgetModel parent,
      String?  id,
      this.axis,
      {
        String? type,
        dynamic labelrotation,
        dynamic title,
        dynamic format,
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
    this.title          = title;
    this.format         = format;
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
    try {
      switch (S.toEnum(type, ChartAxisType.values))
      {
        case ChartAxisType.category:
          this.type = ChartAxisType.category;
          break;
        case ChartAxisType.numeric:
          this.type = ChartAxisType.numeric;
          break;
        case ChartAxisType.datetime:
          this.type = ChartAxisType.datetime;
          break;
        case ChartAxisType.date:
          this.type = ChartAxisType.date;
          break;
        case ChartAxisType.time:
          this.type = ChartAxisType.time;
          break;
        default:
          Log().info('axis type unset, defaulting to category');
          this.type = ChartAxisType.category;
          break;
      }
    } catch(e) {
      Log().exception(e, caller: 'ChartAxisModel');
    }

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
        labelrotation   : Xml.get(node: xml, tag: 'labelrotation'),
        format          : Xml.get(node: xml, tag: 'format'),
        type            : Xml.get(node: xml, tag: 'type'),
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
