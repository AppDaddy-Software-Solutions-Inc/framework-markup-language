// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fml/data/data.dart';
import 'package:fml/log/manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

/// Chart Series Types
enum ChartSeriesType {
  area, line, bar, stack, plot, waterfall, label, pie
}

/// ChartDataPoint Object
///
/// Holds the plot values for each data node in the series
class ChartDataPoint {
  final Color? color;
  final dynamic label;
  final dynamic x;
  final dynamic y;

  ChartDataPoint({this.x, this.y, this.color, this.label});
}

/// Chart Series [ChartSeriesModel]
///
/// Defines the properties used to build a Charts's Series
class ChartPainterSeriesModel extends WidgetModel
{
  List<FlSpot> lineDataPoint = [];
  List<BarChartGroupData> barDataPoint = [];
  List<BarChartRodData> rodDataPoint = [];
  List<BarChartRodStackItem> stackDataPoint = [];
  List<dynamic> xValues = [];
  Function? plotFunction;
  dynamic dataList;
  double maxY = 0;
  double minY = 0;

  String? type = 'bar';

  ChartPainterSeriesModel(
    WidgetModel parent,
    String? id, {
      dynamic x,
      dynamic y,
      dynamic color,
      dynamic stroke,
      dynamic radius,
      dynamic size,
      dynamic label,
      this.type,
      dynamic tooltips,
      dynamic animated,
      dynamic name,
      dynamic group,
      dynamic stack,
      dynamic showarea,
      dynamic showline,
      dynamic showpoints,
    }
  ) : super(parent, id)
  {
    data = Data();
    this.x = x;
    this.y = y;
    this.color = color;
    this.stroke = stroke;
    this.radius = radius;
    this.size = size;
    this.label = label;
    this.tooltips = tooltips;
    this.animated = animated;
    this.name = name;
    this.group = group;
    this.stack = stack;
    this.showarea = showarea;
    this.showline = showline;
    this.showpoints = showpoints;
  }

  static ChartPainterSeriesModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    ChartPainterSeriesModel? model;
    try
    {
      xml = WidgetModel.prototypeOf(xml) ?? xml;
      model = ChartPainterSeriesModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'chart.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {
    //* Deserialize */
    super.deserialize(xml);

    // properties
    x           = Xml.get(node: xml, tag: 'x');
    y           = Xml.get(node: xml, tag: 'y');
    color       = Xml.get(node: xml, tag: 'color');
    stroke      = Xml.get(node: xml, tag: 'stroke');
    radius      = Xml.get(node: xml, tag: 'radius');
    size        = Xml.get(node: xml, tag: 'size');
    type        = Xml.get(node: xml, tag: 'type');
    label       = Xml.get(node: xml, tag: 'label');
    tooltips    = Xml.get(node: xml, tag: 'tooltips');
    animated    = Xml.get(node: xml, tag: 'animated');
    name        = Xml.get(node: xml, tag: 'name');
    group       = Xml.get(node: xml, tag: 'group');
    stack       = Xml.get(node: xml, tag: 'stack');
    showarea    = Xml.get(node: xml, tag: 'showarea');
    showline    = Xml.get(node: xml, tag: 'showline');
    showpoints  = Xml.get(node: xml, tag: 'showpoints');

    // Remove datasource listener. The parent chart will take care of this.
    if ((datasource != null) && (scope != null) && (scope!.datasources.containsKey(datasource))) scope!.datasources[datasource!]!.remove(this);

    // Setup the Series type and some internal properties for supporting it
    if (type != null) type = type?.trim().toLowerCase();
    switch (S.toEnum(type, ChartSeriesType.values)) {
      case ChartSeriesType.area:
        type = S.fromEnum(ChartSeriesType.area);
        break;

      case ChartSeriesType.bar:
        type = S.fromEnum(ChartSeriesType.bar);
        break;

      case ChartSeriesType.label:
        type = S.fromEnum(ChartSeriesType.label);
        break;

      case ChartSeriesType.line:
        type = S.fromEnum(ChartSeriesType.line);
        break;

      case ChartSeriesType.pie:
        type = S.fromEnum(ChartSeriesType.pie);
        break;

      case ChartSeriesType.plot:
        type = S.fromEnum(ChartSeriesType.plot);
        break;

      case ChartSeriesType.waterfall:
        type = S.fromEnum(ChartSeriesType.waterfall);
        break;

      default:
        Log().warning('Unknown ChartSeriesType: $type');
        break;
    }
  }

  /// The x coordinate
  StringObservable? _x;
  set x (dynamic v)
  {
    if (_x != null)
    {
      _x!.set(v);
    }
    else if (v != null)
    {
      _x = StringObservable(Binding.toKey(id, 'x'), v, scope: scope);
    }
  }
  String? get x => _x?.get();

  /// The y coordinate
  StringObservable? _y;
  set y (dynamic v)
  {
    if (_y != null)
    {
      _y!.set(v);
    }
    else if (v != null)
    {
      _y = StringObservable(Binding.toKey(id, 'y'), v, scope: scope);
    }
  }
  String? get y => _y?.get();

  /// The [ChartDataPoint]'s label
  StringObservable? _label;
  set label (dynamic v)
  {
    if (_label != null)
    {
      _label!.set(v);
    }
    else if (v != null)
    {
      _label = StringObservable(Binding.toKey(id, 'label'), v, scope: scope);
    }
  }
  String? get label => _label?.get();

  /// The [ChartDataPoint]'s color
  ColorObservable? _color;
  set color (dynamic v)
  {
    if (_color != null)
    {
      _color!.set(v);
    }
    else if (v != null)
    {
      _color = ColorObservable(Binding.toKey(id, 'color'), v, scope: scope);
    }
  }
  Color? get color => _color?.get();

  /// Line type (`spline`, `line` and `fastline`) stroke width
  DoubleObservable? stroke_;
  set stroke (dynamic v)
  {
    if (stroke_ != null)
    {
      stroke_!.set(v);
    }
    else if (v != null)
    {
      stroke_ = DoubleObservable(Binding.toKey(id, 'stroke'), v, scope: scope);
    }
  }
  double? get stroke => stroke_?.get();

  /// Line/Point type radius width
  DoubleObservable? radius_;
  set radius (dynamic v)
  {
    if (radius_ != null)
    {
      radius_!.set(v);
    }
    else if (v != null)
    {
      radius_ = DoubleObservable(Binding.toKey(id, 'radius'), v, scope: scope);
    }
  }
  double get radius => radius_?.get() ?? 3.5;

  /// Plot type (`plot`) size
  DoubleObservable? _size;
  set size (dynamic v)
  {
    if (_size != null)
    {
      _size!.set(v);
    }
    else if (v != null)
    {
      _size = DoubleObservable(Binding.toKey(id, 'size'), v, scope: scope);
    }
  }
  double? get size => _size?.get();
  
  /// Set to true if you want to show the area under the line series
  BooleanObservable? _showarea;
  set showarea (dynamic v)
  {
    if (_showarea != null)
    {
      _showarea!.set(v);
    }
    else if (v != null)
    {
      _showarea = BooleanObservable(Binding.toKey(id, 'showarea'), v, scope: scope);
    }
  }
  bool get showarea => _showarea?.get() ?? false;


  /// Set to false if you want to hide the line in the line series
  BooleanObservable? _showline;
  set showline (dynamic v)
  {
    if (_showline != null)
    {
      _showline!.set(v);
    }
    else if (v != null)
    {
      _showline = BooleanObservable(Binding.toKey(id, 'showline'), v, scope: scope);
    }
  }
  bool get showline => _showline?.get() ?? true;

  /// Set to false if you want to hide the points on the line series
  BooleanObservable? _showpoints;
  set showpoints (dynamic v)
  {
    if (_showpoints != null)
    {
      _showpoints!.set(v);
    }
    else if (v != null)
    {
      _showpoints = BooleanObservable(Binding.toKey(id, 'showpoints'), v, scope: scope);
    }
  }
  bool get showpoints => _showpoints?.get() ?? true;

  /// If true points will have a tooltip appear on hover
  BooleanObservable? _tooltips;
  set tooltips (dynamic v)
  {
    if (_tooltips != null)
    {
      _tooltips!.set(v);
    }
    else if (v != null)
    {
      _tooltips = BooleanObservable(Binding.toKey(id, 'tooltips'), v, scope: scope);
    }
  }
  bool? get tooltips => _tooltips?.get();

  /// If true the series animates on build
  BooleanObservable? _animated; // Kind funky with state rebuilds
  set animated (dynamic v)
  {
    if (_animated != null)
    {
      _animated!.set(v);
    }
    else if (v != null) {
      _animated = BooleanObservable(Binding.toKey(id, 'animated'), v, scope: scope);
    }
  }
  bool? get animated => _animated?.get();

  /// The series name, will be displayed in the legend if it is visible
  StringObservable? _name;
  set name (dynamic v)
  {
    if (_name != null)
    {
      _name!.set(v);
    }
    else if (v != null)
    {
      _name = StringObservable(Binding.toKey(id, 'name'), v, scope: scope);
    }
  }
  String? get name => _name?.get();
  
  /// The series group, allows multiple bar series to be displayed beside each other if they match
  StringObservable? _group;
  set group (dynamic v)
  {
    if (_group != null)
    {
      _group!.set(v);
    }
    else if (v != null)
    {
      _group = StringObservable(Binding.toKey(id, 'group'), v, scope: scope);
    }
  }
  String? get group => _group?.get();

  /// The series stack, allows multiple bar series to be displayed on top each other if they match
  StringObservable? _stack;
  set stack (dynamic v)
  {
    if (_stack != null)
    {
      _stack!.set(v);
    }
    else if (v != null)
    {
      _stack = StringObservable(Binding.toKey(id, 'stack'), v, scope: scope);
    }
  }
  String? get stack => _stack?.get();

  /// n/a
  IntegerObservable? _selected;
  set selected (dynamic v)
  {
    if (_selected != null)
    {
      _selected!.set(v);
    }
    else if (v != null)
    {
      _selected = IntegerObservable(Binding.toKey(id, 'selected'), v, scope: scope);
    }
  }
  int? get selected => _selected?.get();


  @override
  // we purposely don't want to do anything on change since there is no view
  // and the entire chart gets rebuilt
  void onPropertyChange(Observable observable) {}


  determinePlotFunctions(String chartType, int seriesIndex){

    if (data == null) return;

    if(chartType == 'line')
    {
      lineDataPoint.clear();
      //check if series is date
      plotFunction = pointFromLineData;
    } else if (chartType == 'bar')
    {
      if(type == 'bar' || S.isNullOrEmpty(type)) {
        plotFunction = pointFromBarData;
      } else if (type == 'stacked'){
        plotFunction = pointFromStackedBarData;

        barDataPoint.add(BarChartGroupData(x: seriesIndex, barRods: [BarChartRodData(toY: 20, rodStackItems: stackDataPoint)]));
      } else if (type == 'grouped') {
        plotFunction = pointFromGroupedBarData;
        barDataPoint.add(BarChartGroupData(x: seriesIndex, barRods: rodDataPoint));
      }
    }
  }

  //This function takes in the function related to the type of point plotted
  void iteratePoints(dynamic data, {bool plotOnFirstPass = false}){
    dataList =  data;
    for (var pointData in data) {
      //set the data of the series for databinding
      this.data = pointData;
      //add the value of x to the list only if the type is category.
      xValues.add(S.toInt(x));
      //plot the point as a point object based on the desired function based on series and chart type.
      if(plotOnFirstPass) plotFunction!();
    }
  }

  void plotLineCategoryPoints(dynamic uniqueXValueList){

    for (var pointData in dataList) {
      //set the data of the series for databinding
      data = pointData;
      //ensure the value is in the list, it always should be.
      if (uniqueXValueList.contains(S.toInt(x))) {
        x = uniqueXValueList.toList().indexOf(S.toInt(x));
        //plot the point as a point object based on the desired function based on series and chart type.
        plotFunction!();
      }
      data = null;
      dataList = null;
      plotFunction = null; 
    }
  }

  // these should possibly be called from the chart after determining all values by index.
  void pointFromLineData()
  {
    FlSpot point = FlSpot(S.toDouble(x) ?? 0, S.toDouble(y) ?? 0);
    lineDataPoint.add(point);
  }

  void pointFromBarData()
  {
    //barchartrodstackitem allows stacking within series group.
    BarChartGroupData point = BarChartGroupData(x: S.toInt(x) ?? 0, barRods: [BarChartRodData(toY: S.toDouble(y) ?? 0, color: color ?? ColorHelper.fromString('random'))]);
    barDataPoint.add(point);
  }

  void pointFromGroupedBarData()
  {
    //barchartrodstackitem allows stacking within series group.
    BarChartRodData point = BarChartRodData(toY: S.toDouble(y) ?? 0, color: color ?? ColorHelper.fromString('random'));
    rodDataPoint.add(point);
  }

  void pointFromStackedBarData()
  {
    //barchartrodstackitem allows stacking within series group.
    BarChartRodStackItem point = BarChartRodStackItem(0, S.toDouble(y) ?? 0, color ?? ColorHelper.fromString('random') ?? Colors.blue);
    stackDataPoint.add(point);
  }
}
