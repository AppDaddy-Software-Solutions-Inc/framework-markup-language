import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fml/helper/common_helpers.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/observable/observables/boolean.dart';
import 'package:fml/observable/observables/string.dart';
import 'package:fml/observable/scope.dart';
import 'package:fml/widgets/decorated/decorated_widget_model.dart';
import 'package:fml/widgets/viewable/viewable_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:xml/xml.dart';

enum LayoutType {none, row, column, stack}
enum VerticalAlignmentType {top, bottom, center, around, between, evenly}
enum HorizontalAlignmentType {left, right, center, around, between, evenly}

class LayoutModel extends DecoratedWidgetModel
{
  @required
  LayoutType get layoutType => throw(UnimplementedError);

  @required
  MainAxisSize get verticalAxisSize => throw(UnimplementedError);

  @required
  MainAxisSize get horizontalAxisSize => throw(UnimplementedError);

  // children with variable width
  List<ViewableWidgetModel> get variableWidthChildren
  {
    var viewable = viewableChildren;
    var variable = viewable.where((child) => getPercentWidth(child) != null || getFlexWidth(child) != null).toList();
    return variable;
  }

  // children with variable height
  List<ViewableWidgetModel> get variableHeightChildren
  {
    var viewable = viewableChildren;
    var variable = viewable.where((child) => getPercentHeight(child) != null || getFlexHeight(child) != null).toList();
    return variable;
  }

  // children with fixed width
  List<ViewableWidgetModel> get fixedWidthChildren
  {
    var viewable = viewableChildren;
    var variable = variableWidthChildren;
    viewable.removeWhere((child) => variable.contains(child));
    return viewable;
  }

  // children with fixed height
  List<ViewableWidgetModel> get fixedHeightChildren
  {
    var viewable = viewableChildren;
    var variable = variableHeightChildren;
    viewable.removeWhere((child) => variable.contains(child));
    return viewable;
  }

  /// layout style
  StringObservable? _layout;
  set layout(dynamic v)
  {
    if (_layout != null)
    {
      _layout!.set(v);
    }
    else if (v != null)
    {
      _layout = StringObservable(Binding.toKey(id, 'layout'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get layout => _layout?.get()?.toLowerCase().trim();

  /// Center attribute allows a simple boolean override for halign and valign both being center. halign and valign will override center if given.
  BooleanObservable? _center;
  set center(dynamic v)
  {
    if (_center != null)
    {
      _center!.set(v);
    }
    else if (v != null)
    {
      _center = BooleanObservable(Binding.toKey(id, 'center'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get center => _center?.get() ?? false;

  /// wrap determines the widget, if layout is row or col, how it will wrap.
  BooleanObservable? _wrap;
  set wrap(dynamic v)
  {
    if (_wrap != null)
    {
      _wrap!.set(v);
    }
    else if (v != null)
    {
      _wrap = BooleanObservable(Binding.toKey(id, 'wrap'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get wrap => _wrap?.get() ?? false;

  /// Expand, which is true by default, tells the widget if it should shrink to its children, or grow to its parents constraints. Width/Height attributes will override expand.
  BooleanObservable? _expand;
  set expand(dynamic v)
  {
    if (_expand != null)
    {
      _expand!.set(v);
    }
    else if (v != null)
    {
      _expand = BooleanObservable(Binding.toKey(id, 'expand'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get expand => _expand?.get() ?? true;

  LayoutModel(WidgetModel? parent, String? id, {Scope?  scope}) : super(parent, id, scope: scope);

  static LayoutModel? fromXml(WidgetModel parent, XmlElement xml, {String? type})
  {
    LayoutModel? model;
    try {
      model = LayoutModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'box.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement? xml)
  {
    if (xml == null) return;

    // deserialize
    super.deserialize(xml);

    // properties
    center = Xml.get(node: xml, tag: 'center');
    wrap   = Xml.get(node: xml, tag: 'wrap');
    expand = Xml.get(node: xml, tag: 'expand');
  }

  double?
  getPercentWidth(ViewableWidgetModel child)
  {
    // child is fixed width?
    if (child.isFixedWidth) return null;

    // child has percent width specified
    if (child.widthPercentage != null) return child.widthPercentage;

    // we want to allow the child to expand 100% in its cross axisu
    switch (layoutType)
    {
      case LayoutType.stack:
      case LayoutType.column:
      if (expand && child.isHorizontallyExpanding) return 100;
        break;
      default:
        break;
    }

    return null;
  }

  double? getPercentHeight(ViewableWidgetModel child)
  {
    // child is fixed height?
    if (child.isFixedHeight) return null;

    // child has percent height specified
    if (child.heightPercentage != null) return child.heightPercentage;

    // we want to allow the child to expand 100% in its cross axis
    switch (layoutType)
    {
      case LayoutType.stack:
      case LayoutType.row:
      if (expand && child.isVerticallyExpanding) return 100;
        break;
      default:
        break;
    }
    return null;
  }

  int? getFlexWidth(ViewableWidgetModel child)
  {
    // percent width is priority over flex
    if (getPercentWidth(child) != null) return null;

    // flex only if both me and my child are horizontally expanding
    if (this.isHorizontallyExpanding && child.isHorizontallyExpanding) return child.flex ?? 1;

    return null;
  }

  int? getFlexHeight(ViewableWidgetModel child)
  {
    // percent height is priority over flex
    if (getPercentHeight(child) != null) return null;

    // flex only if both me and my child are vertically expanding
    if (this.isVerticallyExpanding && child.isVerticallyExpanding) return child.flex ?? 1;

    return null;
  }

  @override
  void onLayoutComplete()
  {
    super.onLayoutComplete();

    // no need to perform resizing if there are no variable width children
    if (variableWidthChildren.isNotEmpty)  _onWidthChange();

    // no need to perform resizing if there are no variable height children
    if (variableHeightChildren.isNotEmpty) _onHeightChange();
  }

  void _onWidthChange()
  {
    // layout cannot be performed until all fixed width children have been laid out
    var unsized = fixedWidthChildren.where((child) => child.viewWidth == null);
    if (unsized.isNotEmpty) return;

    // calculate maximum space
    var maximum = myMaxWidth;
    if (maximum == double.infinity) maximum = viewWidth ?? 0;

    var variable = this.variableWidthChildren;
    var fixed    = this.fixedWidthChildren;

    // calculate fixed space
    double reserved = 0;
    for (var child in fixed) reserved += (child.visible) ? (child.viewWidth ?? 0) : 0;
    if (layoutType != LayoutType.row) reserved = 0;

    // calculate usable space (max - reserved)
    var usable = maximum - reserved;

    //print("WIDTH-> id=$id max=$maximum usable=$usable");

    // set % sizing on variable children
    var free = usable;
    for (var child in variable)
    if (child.visible)
    {
      var pct = getPercentWidth(child) ?? 0;
      if (pct > 0)
      {
        // calculate size from %
        int size = (usable * (pct/100)).floor();

        // get user defined constraints
        var constraints = child.constraints.model;

        // must not be less than min width
        if (constraints.minWidth != null && size < constraints.minWidth!) size = constraints.minWidth!.toInt();

        // must not be greater than max width
        if (constraints.maxWidth != null && size > constraints.maxWidth!) size = constraints.maxWidth!.toInt();

        // must be 0 or greater
        if (size.isNegative) size = 0;

        // reduce free space in the main axis
        if (layoutType == LayoutType.row) free = free - size;

        //print("WIDTH-> id=$id child=${child.id} %=$pct size=$size free=$free");

        // set the size
        if (child.width != size) child.setWidth(size.toDouble(), notify: true);
      }
    }

    // calculate sum of all flex values
    double flexsum = 0;
    for (var child in variable)
    if (child.visible) flexsum += max(getFlexWidth(child) ?? 0, 0);

    // set flex sizing on flexible children
    for (var child in variable)
    if (child.visible)
    {
      var flex = getFlexWidth(child) ?? 0;
      if (flex > 0)
      {
        // calculate size from flex
        var size = ((flex / flexsum) * free).floor();

        // get user defined constraints
        var constraints = child.constraints.model;

        // must not be less than min width
        if (constraints.minWidth != null && size < constraints.minWidth!) size = constraints.minWidth!.toInt();

        // must not be greater than max width
        if (constraints.maxWidth != null && size > constraints.maxWidth!) size = constraints.maxWidth!.toInt();

        // must be 0 or greater
        if (size.isNegative) size = 0;

        //print("WIDTH-> id=$id child=${child.id} flexsum=$flexsum flex=$flex size=$size");

        // set the size
        if (child.width != size) child.setWidth(size.toDouble(), notify: true);
      }
    }
  }

  void _onHeightChange()
  {
    // layout cannot be performed until all fixed height children have been laid out
    var unsized = fixedHeightChildren.where((child) => child.viewHeight == null);
    if (unsized.isNotEmpty) return;

    // calculate maximum space
    var maximum = myMaxHeight;
    if (maximum == double.infinity) maximum = viewHeight ?? 0;

    var variable = this.variableHeightChildren;
    var fixed = this.fixedHeightChildren;

    // calculate fixed space
    double reserved = 0;
    for (var child in fixed) reserved += (child.visible) ? (child.viewHeight ?? 0) : 0;
    if (layoutType != LayoutType.column) reserved = 0;

    // calculate usable space (max - reserved)
    var usable = maximum - reserved;

    //print("HEIGHT-> parent=${this.parent?.id} id=$id max=$maximum usable=$usable");

    // set % sizing on variable children
    var free = usable;
    for (var child in variable)
    if (child.visible)
    {
      var pct = getPercentHeight(child) ?? 0;
      if (pct > 0)
      {
        // calculate size from %
        var size = (usable * (pct/100)).floor();

        // get user defined constraints
        var constraints = child.constraints.model;

        // must not be less than min height
        if (constraints.minHeight != null && size < constraints.minHeight!) size = constraints.minHeight!.toInt();

        // must not be greater than max height
        if (constraints.maxHeight != null && size > constraints.maxHeight!) size = constraints.maxHeight!.toInt();

        // must be 0 or greater
        if (size.isNegative) size = 0;

        // reduce free space in the main axis
        if (layoutType == LayoutType.column) free = free - size;

        //print("HEIGHT-> id=$id child=${child.id} %=$pct size=$size free=$free");

        // set the size
        if (child.height != size) child.setHeight(size.toDouble(), notify: true);
      }
    }

    // calculate sum of all flex values
    double flexsum = 0;
    for (var child in variable)
    if (child.visible) flexsum += max(getFlexHeight(child) ?? 0, 0);

    // set flex sizing on flexible children
    for (var child in variable)
    if (child.visible)
    {
      var flex = getFlexHeight(child) ?? 0;
      if (flex > 0)
      {
        // calculate size from flex
        var size = ((flex / flexsum) * free).floor();

        // get user defined constraints
        var constraints = child.constraints.model;

        // must not be less than min height
        if (constraints.minHeight != null && size < constraints.minHeight!) size = constraints.minHeight!.toInt();

        // must not be greater than max height
        if (constraints.maxHeight != null && size > constraints.maxHeight!) size = constraints.maxHeight!.toInt();

        // must be 0 or greater
        if (size.isNegative) size = 0;

        //print("HEIGHT-> id=$id child=${child.id} flexsum=$flexsum flex=$flex size=$size");

        // set the size
        if (child.height != size) child.setHeight(size.toDouble(), notify: true);
      }
    }
  }

  static LayoutType getLayoutType(String? layout, {LayoutType defaultLayout = LayoutType.none})
  {
    switch (layout?.toLowerCase().trim())
    {
      case 'col':
      case 'column':
        return LayoutType.column;

      case 'row':
        return LayoutType.row;

      case 'stack':
        return LayoutType.stack;

      default: return defaultLayout;
    }
  }
}
