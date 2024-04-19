// // © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
// import 'dart:ui';
// import 'package:fml/log/manager.dart';
// import 'package:fml/widgets/widget/model.dart' ;
// import 'package:xml/xml.dart';
// import 'package:fml/observable/observable_barrel.dart';
// import 'package:fml/helpers/helpers.dart';
//
// enum Axis {X, Y}
// enum AxisType {category, numeric, datetime, date, time, logarithmic}
//
// /// Chart Axis [ChartAxisModel]
// ///
// /// Defines the properties used to build a Charts's Axis
// class ChartAxisModel extends WidgetModel
// {
//
//   /// Axis type: `category`, `numeric`, `datetime`, `date` or `time`
//   ///
//   /// This is used to help display the data on an axis correctly based on the data type
//   AxisType type = AxisType.category;
//   final Axis axis;
//
//
//   /// The title of an axis, displayed beside the axis
//   StringObservable? _title;
//   set title (dynamic v)
//   {
//     if (_title != null)
//     {
//       _title!.set(v);
//     }
//     else if (v != null)
//     {
//       _title = StringObservable(Binding.toKey(id, 'title'), v, scope: scope, listener: onPropertyChange);
//     }
//   }
//   String? get title => _title?.get();
//
//   /// Format string expected from the input and output. See https://api.flutter.dev/flutter/intl/DateFormat-class.html.
//   StringObservable? _format;
//
//   set format(dynamic v) {
//     if (_format != null) {
//       _format!.set(v);
//     } else if (v != null) {
//       _format = StringObservable(Binding.toKey(id, 'format'), v,
//           scope: scope, listener: onPropertyChange);
//     }
//   }
//   String? get format => _format?.get();
//
//   /// Used to rotate long data labels so you can fit more, generally along the x axis
//   IntegerObservable? _labelrotation;
//   set labelrotation (dynamic v)
//   {
//     if (_labelrotation != null)
//     {
//       _labelrotation!.set(v);
//     }
//     else if (v != null)
//     {
//       _labelrotation = IntegerObservable(Binding.toKey(id, 'labelrotation'), v, scope: scope, listener: onPropertyChange);
//     }
//   }
//   int? get labelrotation => _labelrotation?.get();
//
//   // TODO: add support for min/max/interval to DateTimeAxis
//   // https://help.syncfusion.com/flutter/chart/axis-types#customizing-range-1
//
//   /// minimum value that displays on the axis
//   StringObservable? _minimum;
//   set minimum (dynamic v)
//   {
//     if (_minimum != null)
//       _minimum!.set(v);
//     else if (v != null)
//       _minimum = StringObservable(Binding.toKey(id, 'minimum'), v, scope: scope, listener: onPropertyChange);
//   }
//   String? get minimum => _minimum?.get();
//
//   /// maximum value that displays on the axis
//   StringObservable? _maximum;
//   set maximum (dynamic v)
//   {
//     if (_maximum != null)
//       _maximum!.set(v);
//     else if (v != null)
//       _maximum = StringObservable(Binding.toKey(id, 'maximum'), v, scope: scope, listener: onPropertyChange);
//   }
//   String? get maximum => _maximum?.get();
//
//   /// visibleminimum sets the minimum value displayed on the axis itself
//   StringObservable? _visibleminimum;
//   set visibleminimum (dynamic v) {
//     if (_visibleminimum != null)
//       _visibleminimum!.set(v);
//     else if (v != null)
//       _visibleminimum = StringObservable(Binding.toKey(id, 'visibleminimum'), v, scope: scope, listener: onPropertyChange);
//   }
//   String? get visibleminimum => _visibleminimum?.get();
//
//   /// visiblemaximum sets the maximum value displayed on the axis itself
//   StringObservable? _visiblemaximum;
//   set visiblemaximum (dynamic v)
//   {
//     if (_visiblemaximum != null)
//       _visiblemaximum!.set(v);
//     else if (v != null)
//       _visiblemaximum = StringObservable(Binding.toKey(id, 'visiblemaximum'), v, scope: scope, listener: onPropertyChange);
//   }
//   String? get visiblemaximum => _visiblemaximum?.get();
//
//   /// interval at which axis values are iterated by
//   ///
//   /// If set to 5 the axis will display 0, 5, 10, 15, etc...
//   DoubleObservable? _interval;
//   set interval (dynamic v)
//   {
//     if (_interval != null)
//       _interval!.set(v);
//     else if (v != null)
//       _interval = DoubleObservable(Binding.toKey(id, 'interval'), v, scope: scope, listener: onPropertyChange);
//   }
//   double? get interval => _interval?.get();
//
//   /// interval type to use, such as `months` if working with a `datetime` type
//   ///
//   /// cannot be used by
//   StringObservable? _intervaltype;
//   set intervaltype (dynamic v)
//   {
//     if (_intervaltype != null)
//       _intervaltype!.set(v);
//     else if (v != null)
//       _intervaltype = StringObservable(Binding.toKey(id, 'intervaltype'), v, scope: scope, listener: onPropertyChange);
//   }
//   String? get intervaltype => _intervaltype?.get();
//
//   /// Size of the text
//   IntegerObservable? _fontsize;
//   set fontsize (dynamic v)
//   {
//     if (_fontsize != null)
//     {
//       _fontsize!.set(v);
//     }
//     else if (v != null)
//     {
//       _fontsize = IntegerObservable(Binding.toKey(id, 'fontsize'), v, scope: scope, listener: onPropertyChange);
//     }
//   }
//   int get fontsize => _fontsize?.get() ?? 14;
//
//   /// Color of the text
//   ColorObservable? _fontcolor;
//   set fontcolor (dynamic v)
//   {
//     if (_fontcolor != null)
//     {
//       _fontcolor!.set(v);
//     }
//     else if (v != null)
//     {
//       _fontcolor = ColorObservable(Binding.toKey(id, 'fontcolor'), v, scope: scope, listener: onPropertyChange);
//     }
//   }
//   Color? get fontcolor => _fontcolor?.get();
//
//   /// Depreciated
//   StringObservable? _fontweight;
//   set fontweight (dynamic v)
//   {
//     if (_fontweight != null)
//     {
//       _fontweight!.set(v);
//     }
//     else if (v != null)
//     {
//       _fontweight = StringObservable(Binding.toKey(id, 'fontweight'), v, scope: scope, listener: onPropertyChange);
//     }
//   }
//   String? get fontweight => _fontweight?.get();
//
//   /// Color of the axis divider grid lines
//   ///
//   /// X axis vertical, Y axis horizontal
//   ColorObservable? _gridcolor;
//   set gridcolor (dynamic v)
//   {
//     if (_gridcolor != null)
//     {
//       _gridcolor!.set(v);
//     }
//     else if (v != null)
//     {
//       _gridcolor = ColorObservable(Binding.toKey(id, 'gridcolor'), v, scope: scope, listener: onPropertyChange);
//     }
//   }
//   Color? get gridcolor => _gridcolor?.get();
//
//   // TODO: Needs documenting
//   DoubleObservable? _zoomfactor;
//   set zoomfactor (dynamic v)
//   {
//     if (_zoomfactor != null)
//       _zoomfactor!.set(v);
//     else if (v != null)
//       _zoomfactor = DoubleObservable(Binding.toKey(id, 'zoomfactor'), v, scope: scope, listener: onPropertyChange);
//   }
//   double? get zoomfactor => _zoomfactor?.get();
//
//   // TODO: Needs documenting
//   DoubleObservable? _zoomposition;
//   set zoomposition (dynamic v)
//   {
//     if (_zoomposition != null)
//       _zoomposition!.set(v);
//     else if (v != null)
//       _zoomposition = DoubleObservable(Binding.toKey(id, 'zoomposition'), v, scope: scope, listener: onPropertyChange);
//   }
//   double? get zoomposition => _zoomposition?.get();
//
//   ChartAxisModel(
//     WidgetModel? parent,
//     String?  id,
//     this.axis,
//     {
//     dynamic  type,
//     dynamic minimum,
//     dynamic maximum,
//     dynamic visibleminimum,
//     dynamic visiblemaximum,
//     dynamic labelrotation,
//     dynamic title,
//     dynamic fontsize,
//     dynamic fontcolor,
//     dynamic fontweight,
//     dynamic gridcolor,
//     dynamic interval,
//     dynamic intervaltype,
//     dynamic zoomfactor,
//     dynamic zoomposition,
//     dynamic format,
//   }) : super(parent, id)
//
//   {
//     this.minimum        = minimum;
//     this.maximum        = maximum;
//     this.visibleminimum = visibleminimum;
//     this.visiblemaximum = visiblemaximum;
//     this.labelrotation  = labelrotation;
//     this.title          = title;
//     this.fontcolor      = fontcolor;
//     this.fontsize       = fontsize;
//     this.fontweight     = fontweight;
//     this.gridcolor      = gridcolor;
//     this.interval       = interval;
//     this.intervaltype   = intervaltype;
//     this.zoomfactor     = zoomfactor;
//     this.zoomposition   = zoomposition;
//     this.format         = format;
//
//     AxisType? axisType = axis == Axis.Y ? AxisType.numeric : AxisType.category;
//     if (type != null && type is String) {
//       type = type.trim().toLowerCase();
//       axisType = toEnum(type, AxisType.values);
//     }
//     else if (type != null && type is AxisType) {
//       axisType = type;
//     }
//     switch (axisType) {
//       case AxisType.category:
//         this.type = AxisType.category;
//         break;
//       case AxisType.numeric:
//         this.type = AxisType.numeric;
//         break;
//       case AxisType.datetime:
//         this.type = AxisType.datetime;
//         break;
//       case AxisType.date:
//         this.type = AxisType.date;
//         break;
//       case AxisType.time:
//         this.type = AxisType.time;
//         break;
//       default:
//         Log().info('axis type unset, defaulting to category');
//         this.type = AxisType.category;
//     }
//   }
//
//   static ChartAxisModel? fromXml(WidgetModel parent, XmlElement xml, Axis axis)
//   {
//     ChartAxisModel? model;
//     try
//     {
//       model = ChartAxisModel(
//         parent,
//         Xml.get(node: xml, tag: 'id'),
//         axis,
//         title           : Xml.get(node: xml, tag: 'title'),
//         fontsize        : Xml.get(node: xml, tag: 'fontsize'),
//         fontcolor       : Xml.get(node: xml, tag: 'fontcolor'),
//         type            : Xml.get(node: xml, tag: 'type'),
//         format            : Xml.get(node: xml, tag: 'format'),
//         minimum         : Xml.get(node: xml, tag: 'minimum'),
//         maximum         : Xml.get(node: xml, tag: 'maximum'),
//         visibleminimum  : Xml.get(node: xml, tag: 'minimum'),
//         visiblemaximum  : Xml.get(node: xml, tag: 'maximum'),
//         labelrotation   : Xml.get(node: xml, tag: 'labelrotation'),
//         gridcolor       : Xml.get(node: xml, tag: 'gridcolor'),
//         interval        : Xml.get(node: xml, tag: 'interval'),
//         intervaltype    : Xml.get(node: xml, tag: 'intervaltype'),
//         zoomfactor      : Xml.get(node: xml, tag: 'zoomfactor'),
//         zoomposition    : Xml.get(node: xml, tag: 'zoomposition'),
//       );
//     }
//     catch(e)
//     {
//       Log().exception(e, caller: 'chart_syncfusion.axis.Model');
//       model = null;
//     }
//     return model;
//   }
// }
