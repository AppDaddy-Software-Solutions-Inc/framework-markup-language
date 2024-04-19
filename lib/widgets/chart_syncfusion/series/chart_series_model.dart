// // © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
// import 'package:fml/datasources/iDataSource.dart';
// import 'package:fml/log/manager.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:xml/xml.dart';
// import 'package:fml/widgets/widget/model.dart'  ;
// import 'package:fml/widgets/tooltip/tooltip_model.dart';
// import 'package:fml/observable/observable_barrel.dart';
// import 'package:fml/helpers/helpers.dart';
//
// /// Chart Series Types
// enum ChartSeriesType {
//   area, spline, line, fastline, bar, stackedbar, percentstackedbar, sidebar, plot, waterfall, label, pie, doughnut, explodedpie, explodeddoughnut, radial, radialbar
// }
//
// /// Point Object
// ///
// /// Holds the plot values for each data node in the series
// class Point {
//   final Color? color; final dynamic label; final dynamic x; final dynamic y;
//   Point({this.x, this.y, this.color, this.label});
// }
//
// /// Chart Series [ChartSeriesModel]
// ///
// /// Defines the properties used to build a Charts's Series
// class ChartSeriesModel extends WidgetModel
// {
//   List<Point> points = [];
//
//   String? type = type_bar;
//   dynamic sfSeries; // need to get the syncfusion series obj here...
//
//   String? tooltipTemplate;
//
//   IDataSource? source;
//
//   /// The x coordinate
//   StringObservable? _x;
//   set x (dynamic v)
//   {
//     if (_x != null)
//     {
//       _x!.set(v);
//     }
//     else if (v != null)
//     {
//       _x = StringObservable(Binding.toKey(id, 'x'), v, scope: scope, listener: onPropertyChange);
//     }
//   }
//   String? get x => _x?.get();
//
//   /// The y coordinate
//   StringObservable? _y;
//   set y (dynamic v)
//   {
//     if (_y != null)
//     {
//       _y!.set(v);
//     }
//     else if (v != null)
//     {
//       _y = StringObservable(Binding.toKey(id, 'y'), v, scope: scope, listener: onPropertyChange);
//     }
//   }
//   String? get y => _y?.get();
//
//   /// The [Point]'s label
//   StringObservable? _label;
//   set label (dynamic v)
//   {
//     if (_label != null)
//     {
//       _label!.set(v);
//     }
//     else if (v != null)
//     {
//       _label = StringObservable(Binding.toKey(id, 'label'), v, scope: scope, listener: onPropertyChange);
//     }
//   }
//   String? get label => _label?.get();
//
//   /// The [Point]'s color
//   ColorObservable? _color;
//   set color (dynamic v)
//   {
//     if (_color != null)
//     {
//       _color!.set(v);
//     }
//     else if (v != null)
//     {
//       _color = ColorObservable(Binding.toKey(id, 'color'), v, scope: scope, listener: onPropertyChange);
//     }
//   }
//   Color? get color => _color?.get();
//
//   /// Line type (`spline`, `line` and `fastline`) stroke width
//   DoubleObservable? stroke_;
//   set stroke (dynamic v)
//   {
//     if (stroke_ != null)
//     {
//       stroke_!.set(v);
//     }
//     else if (v != null)
//     {
//       stroke_ = DoubleObservable(Binding.toKey(id, 'stroke'), v, scope: scope, listener: onPropertyChange);
//     }
//   }
//   double? get stroke => stroke_?.get();
//
//   /// Plot type (`plot`) size
//   DoubleObservable? _size;
//   set size (dynamic v)
//   {
//     if (_size != null)
//     {
//       _size!.set(v);
//     }
//     else if (v != null)
//     {
//       _size = DoubleObservable(Binding.toKey(id, 'size'), v, scope: scope, listener: onPropertyChange);
//     }
//   }
//   double? get size => _size?.get();
//
//   /// Set to true if you want to label a non label type series
//   BooleanObservable? _labelled;
//   set labelled (dynamic v)
//   {
//     if (_labelled != null)
//     {
//       _labelled!.set(v);
//     }
//     else if (v != null)
//     {
//       _labelled = BooleanObservable(Binding.toKey(id, 'labelled'), v, scope: scope, listener: onPropertyChange);
//     }
//   }
//   bool? get labelled => _labelled?.get();
//
//   /// Can be a 'string' or a 'widget', default is string
//   StringObservable? _labelType;
//   set labelType (dynamic v) {
//     if (_labelType != null) {
//       _labelType!.set(v);
//     }
//     else if (v != null) {
//       _labelType = StringObservable(Binding.toKey(id, 'labelType'), v, scope: scope, listener: onPropertyChange);
//     }
//   }
//   String? get labelType => _labelType?.get();
//
//   /// If true points will have a tooltip appear on hover
//   BooleanObservable? _tooltips;
//   set tooltips (dynamic v)
//   {
//     if (_tooltips != null)
//     {
//       _tooltips!.set(v);
//     }
//     else if (v != null)
//     {
//       _tooltips = BooleanObservable(Binding.toKey(id, 'tooltips'), v, scope: scope, listener: onPropertyChange);
//     }
//   }
//   bool? get tooltips => _tooltips?.get();
//
//   /// If true the series animates on build
//   BooleanObservable? _animated; // Kind funky with state rebuilds
//   set animated (dynamic v)
//   {
//     if (_animated != null)
//     {
//       _animated!.set(v);
//     }
//     else if (v != null) {
//       _animated = BooleanObservable(Binding.toKey(id, 'animated'), v, scope: scope, listener: onPropertyChange);
//     }
//   }
//   bool? get animated => _animated?.get();
//
//   /// The series name, will be displayed in the legend if it is visible
//   StringObservable? name_;
//   set name (dynamic v)
//   {
//     if (name_ != null)
//     {
//       name_!.set(v);
//     }
//     else if (v != null)
//     {
//       name_ = StringObservable(Binding.toKey(id, 'name'), v, scope: scope, listener: onPropertyChange);
//     }
//   }
//   String? get name => name_?.get();
//
//   /// n/a
//   IntegerObservable? _selected;
//   set selected (dynamic v)
//   {
//     if (_selected != null)
//     {
//       _selected!.set(v);
//     }
//     else if (v != null)
//     {
//       _selected = IntegerObservable(Binding.toKey(id, 'selected'), v, scope: scope, listener: onPropertyChange);
//     }
//   }
//   int? get selected => _selected?.get();
//
//   static const type_bar               = 'bar';
//   static const type_stackedbar        = 'stackedbar';
//   static const type_percentstackedbar = 'percentstackedbar';
//   static const type_sidebar           = 'sidebar';
//   static const type_area              = 'area';
//   static const type_spline            = 'spline';
//   static const type_line              = 'line';
//   static const type_fastline          = 'fastline';
//   static const type_plot              = 'plot';
//   static const type_waterfall         = 'waterfall';
//   static const type_label             = 'label';
//   static const type_pie               = 'pie';
//   static const type_doughnut          = 'doughnut';
//   static const type_explodedpie       = 'explodedpie';
//   static const type_explodeddoughnut  = 'explodeddoughnut';
//   static const type_radial            = 'radial';
//   static const type_radialbar         = 'radialbar';
//
//   ChartSeriesModel(WidgetModel parent, String?  id,
//       {
//         dynamic x,
//         dynamic y,
//         dynamic color,
//         dynamic stroke,
//         dynamic size,
//         dynamic label,
//         dynamic labelled,
//         dynamic labelType,
//         String?  type,
//         dynamic tooltips,
//         dynamic animated,
//         dynamic name,
//       }) : super(parent, id)
//   {
//     this.x          = x;
//     this.y          = y;
//     this.color      = color;
//     this.stroke     = stroke;
//     this.size       = size;
//     this.label      = label;
//     this.labelled   = labelled;
//     this.labelType  = labelType;
//     this.tooltips   = tooltips;
//     this.animated   = animated;
//     this.name       = name;
//
//     if (type != null) type = type.trim().toLowerCase();
//     switch (type)
//     {
//       case type_area:
//         this.type = type_area;
//         break;
//
//       case type_spline:
//         this.type = type_spline;
//         break;
//
//       case type_line:
//         this.type = type_line;
//         break;
//
//       case type_fastline:
//         this.type = type_fastline;
//         break;
//
//       case type_bar:
//         this.type = type_bar;
//         break;
//
//       case type_stackedbar:
//         this.type = type_stackedbar;
//         break;
//
//       case type_percentstackedbar:
//         this.type = type_percentstackedbar;
//         break;
//
//       case type_sidebar:
//         this.type = type_sidebar;
//         break;
//
//       case type_plot:
//         this.type = type_plot;
//         break;
//
//       case type_waterfall:
//         this.type = type_waterfall;
//         break;
//
//       case type_label:
//         this.type = type_label;
//         break;
//
//       case type_pie:
//         this.type = type_pie;
//         break;
//
//       case type_explodedpie:
//         this.type = type_explodedpie;
//         break;
//
//       case type_doughnut:
//         this.type = type_doughnut;
//         break;
//
//       case type_explodeddoughnut:
//         this.type = type_explodeddoughnut;
//         break;
//
//       case type_radial:
//       case type_radialbar:
//         this.type = type_radial;
//         break;
//
//     }
//   }
//
//   static ChartSeriesModel? fromXml(WidgetModel parent, XmlElement xml)
//   {
//     ChartSeriesModel? model;
//     try
//     {
//       model = ChartSeriesModel(parent, Xml.get(node: xml, tag: 'id'));
//       model.deserialize(xml);
//     }
//     catch(e)
//     {
//       Log().exception(e,  caller: 'chart.Model');
//       model = null;
//     }
//     return model;
//   }
//
//   /// Deserializes the FML template elements, attributes and children
//   @override
//   void deserialize(XmlElement xml)
//   {
//
//     //* Deserialize */
//     super.deserialize(xml);
//
//     /////////////////
//     //* Properties */
//     /////////////////
//     x         = Xml.get(node: xml, tag: 'x');
//     y         = Xml.get(node: xml, tag: 'y');
//     color     = Xml.get(node: xml, tag: 'color');
//     stroke    = Xml.get(node: xml, tag: 'stroke');
//     size      = Xml.get(node: xml, tag: 'size');
//     type      = Xml.get(node: xml, tag: 'type');
//     label     = Xml.get(node: xml, tag: 'label');
//     labelled  = Xml.get(node: xml, tag: 'labelled');
//     labelType = Xml.get(node: xml, tag: 'labelType');
//     tooltips  = Xml.get(node: xml, tag: 'tooltips');
//     animated  = Xml.get(node: xml, tag: 'animated');
//     name      = Xml.get(node: xml, tag: 'name');
//
//     List<TooltipModel> tooltip = findChildrenOfExactType(TooltipModel).cast<TooltipModel>();
//     if (tooltip.isNotEmpty) tooltipTemplate = tooltip.first.element?.toXmlString();
//
//     // remove datasource listener. The parent chart will take care of this.
//     if ((datasource != null) && (scope != null) && (scope!.datasources.containsKey(datasource))) scope!.datasources[datasource!]!.remove(this);
//   }
//
//   Point point(dynamic data)
//   {
//     dynamic color;
//     if (_color != null && _color!.bindings != null && _color!.bindings!.length > 0)
//       color = replace(_color,data); // _color.set(_color?.applyMap(map)); // run eval(s)
//     else if (_color!.value != null)
//       color = _color!.value;
//     dynamic x     = replace(_x,data);
//     dynamic y     = replace(_y,data);
//     dynamic label = replace(_label,data);
//     return Point(x: x, y: y, color: color, label: label);
//   }
//
//   dynamic replace(Observable? observable, dynamic data)
//   {
//     if (observable == null) return null;
//
//     // apply data to Json data
//     dynamic value = Json.replace(observable.signature, data);
//
//     // evaluate
//     if (observable.isEval == true) value = Observable.doEvaluation(value);
//
//     // set observable value
//     observable.set(value);
//
//     // return value
//     return observable.get();
//   }
//
//   setSFSeries(s)
//   {
//     sfSeries = s;
//   }
// }
