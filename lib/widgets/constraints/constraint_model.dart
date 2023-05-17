import 'package:flutter/material.dart';
import 'package:fml/helper/string.dart';
import 'package:fml/helper/xml.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/observable/observables/double.dart';
import 'package:fml/observable/observables/integer.dart';
import 'package:fml/observable/scope.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/constraints/constraint.dart';
import 'package:fml/widgets/viewable/viewable_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:xml/xml.dart';

class ConstraintModel extends WidgetModel
{
  ConstraintModel(WidgetModel? parent, String? id, {Scope? scope}) : super(parent, id, scope: scope);

  final Constraints system = Constraints();

  // return the model constraints
  Constraints get constraints => Constraints(width: width, height: height, minWidth: minWidth, maxWidth: maxWidth, minHeight: minHeight, maxHeight: maxHeight);

  // indicates if the widget has width defined
  bool get hasBoundedWidth => width != null || widthPercentage != null;

  // indicates if the widget has height defined
  bool get hasBoundedHeight => height != null || heightPercentage != null;

  // indicates if the widget expands infinitely in
  // it's horizontal axis if not constrained
  // override where necessary
  bool get canExpandInfinitelyWide => false;

  // indicates if the widget expands infinitely in
  // it's vertical axis if not constrained
  // override where necessary
  bool get canExpandInfinitelyHigh => false;

  // indicates if the widget normally wants to flex in
  // its horizontal axis
  // override where necessary
  bool get expandHorizontally => false;

  // indicates if the widget normally wants to flex in
  // its vertical axis
  // override where necessary
  bool get expandVertically => false;

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {
    // deserialize
    super.deserialize(xml);

    // set constraints
    width     = Xml.get(node: xml, tag: 'width');
    height    = Xml.get(node: xml, tag: 'height');
    minWidth  = Xml.get(node: xml, tag: 'minwidth');
    maxWidth  = Xml.get(node: xml, tag: 'maxwidth');
    minHeight = Xml.get(node: xml, tag: 'minheight');
    maxHeight = Xml.get(node: xml, tag: 'maxheight');
  }

  // width
  double? _widthPercentage;
  double? get widthPercentage => _widthPercentage;
  DoubleObservable? _width;
  set width(dynamic v)
  {
    if (_width != null)
    {
      _width!.set(v);
    }
    else if (v != null)
    {
      _width = DoubleObservable(Binding.toKey(id, 'width'), v, scope: scope, listener: onPropertyChange, setter: _widthSetter);
    }
  }
  double? get width => _width?.get();

  // this routine set the width silently and resets the
  // fixedWidth property
  setWidth(double? v)
  {
    // create the _width observable if it
    // hasn't already been created
    if (_width == null)
    {
      _width = DoubleObservable(Binding.toKey(id, 'width'), null, scope: scope, setter: _widthSetter);
      _width!.registerListener(onPropertyChange);
    }

    // we must remember these settings since they are
    // changed by the _widthSetter() and need to be restored
    // after assigning _width a value
    var pct = _widthPercentage;

    // set the width
    _width?.set(v, notify: false);

    // restore original settings
    if (pct != null) _widthPercentage = pct;
  }

  // this routine enforces the min and max width
  // constraints from the template
  dynamic _widthSetter(dynamic value)
  {
    // is the value a percentage?
    _widthPercentage = null;
    if (S.isPercentage(value))
    {
      _widthPercentage = S.toDouble(value.split("%")[0]);
      value = null;
    }

    // is the value a number?
    if (S.isNumber(value))
    {
      double v = S.toDouble(value)!;

      // must be greater than minWidth
      if (minWidth != null && v < minWidth!) v = minWidth!;

      // must be greater than maxWidth
      if (maxWidth != null && v > maxWidth!) v = maxWidth!;

      // cannot be negative
      if (v.isNegative) v = 0;

      if (v != S.toDouble(value)) value = v;
    }

    return value;
  }

  // height
  double? _heightPercentage;
  double? get heightPercentage => _heightPercentage;
  DoubleObservable? _height;
  set height(dynamic v)
  {
    if (_height != null)
    {
      _height!.set(v);
    }
    else if (v != null)
    {
      _height = DoubleObservable(Binding.toKey(id, 'height'), v, scope: scope, listener: onPropertyChange, setter: _heightSetter);
    }
  }
  double? get height => _height?.get();

  setHeight(double? v)
  {
    // create the _height observable if it
    // hasn't already been created
    if (_height == null)
    {
      _height = DoubleObservable(Binding.toKey(id, 'height'), null, scope: scope, setter: _heightSetter);
      _height!.registerListener(onPropertyChange);
    }

    // we must remember these settings since they are
    // changed by the _heightSetter() and need to be restored
    // after assigning _height a value
    var pct = _heightPercentage;

    // set the height
    _height?.set(v, notify:false);

    // restore original settings
    if (pct != null) _heightPercentage = pct;
  }

  // this routine enforces the min and max height
  // constraints from the template
  dynamic _heightSetter(dynamic value)
  {
    // is the value a percentage?
    _heightPercentage = null;
    if (S.isPercentage(value))
    {
      _heightPercentage = S.toDouble(value.split("%")[0]);
      value = null;
    }

    // is the value a number?
    if (S.isNumber(value))
    {
      double v = S.toDouble(value)!;

      // must be greater than minHeight
      if (minHeight != null && v < minHeight!) v = minHeight!;

      // must be less than maxHeight
      if (maxHeight != null && v > maxHeight!) v = maxHeight!;

      // cannot be negative
      if (v.isNegative) v = 0;

      if (v != S.toDouble(value)) value = v;
    }

    return value;
  }

  // flex
  IntegerObservable? _flex;
  set flex (dynamic v)
  {
    if (_flex != null)
    {
      _flex!.set(v);
    }
    else if (v != null)
    {
      _flex = IntegerObservable(Binding.toKey(id, 'flex'), v, scope: scope, listener: onPropertyChange);
    }
  }
  int? get flex => _flex?.get();

  // min width
  double? _minWidthPercentage;
  double? get minWidthPercentage => _minWidthPercentage;
  DoubleObservable? _minWidth;
  set minWidth(dynamic v)
  {
    if (v != null)
    {
      if (S.isPercentage(v))
      {
        _minWidthPercentage = S.toDouble(v.split("%")[0]);
        v = null;
      }
      else {
        _minWidthPercentage = null;
      }
      if (_minWidth == null) {
        _minWidth = DoubleObservable(Binding.toKey(id, 'minWidth'), v, scope: scope, listener: onPropertyChange);
      } else if (v != null) {
        _minWidth!.set(v);
      }
    }
  }
  double? get minWidth => _minWidth?.get();

  // max width
  double? _maxWidthPercentage;
  double? get maxWidthPercentage => _maxWidthPercentage;
  DoubleObservable? _maxWidth;
  set maxWidth(dynamic v)
  {
    if (v != null)
    {
      if (S.isPercentage(v))
      {
        _maxWidthPercentage = S.toDouble(v.split("%")[0]);
        v = null;
      }
      else {
        _maxWidthPercentage = null;
      }
      if (_maxWidth == null) {
        _maxWidth = DoubleObservable(Binding.toKey(id, 'maxwidth'), v, scope: scope, listener: onPropertyChange);
      } else if (v != null) {
        _maxWidth!.set(v);
      }
    }
  }
  double? get maxWidth => _maxWidth?.get();

  // min height
  double? _minHeightPercentage;
  double? get minHeightPercentage => _minHeightPercentage;
  DoubleObservable? _minHeight;
  set minHeight(dynamic v)
  {
    if (v != null)
    {
      if (S.isPercentage(v))
      {
        _minHeightPercentage = S.toDouble(v.split("%")[0]);
        v = null;
      }
      else {
        _minHeightPercentage = null;
      }
      if (_minHeight == null) {
        _minHeight = DoubleObservable(Binding.toKey(id, 'minheight'), v, scope: scope, listener: onPropertyChange);
      } else if (v != null) {
        _minHeight!.set(v);
      }
    }
  }
  double? get minHeight => _minHeight?.get();

  // max height
  double? _maxHeightPercentage;
  double? get maxHeightPercentage => _maxHeightPercentage;
  DoubleObservable? _maxHeight;
  set maxHeight(dynamic v)
  {
    if (v != null)
    {
      if (S.isPercentage(v))
      {
        _maxHeightPercentage = S.toDouble(v.split("%")[0]);
        v = null;
      }
      else {
        _maxHeightPercentage = null;
      }
      if (_maxHeight == null) {
        _maxHeight = DoubleObservable(Binding.toKey(id, 'maxheight'), v, scope: scope, listener: onPropertyChange);
      } else if (v != null) {
        _maxHeight!.set(v);
      }
    }
  }
  double? get maxHeight => _maxHeight?.get();

  // return the bounded width
  double? getWidth({double? widthParent})
  {
    if (!hasBoundedWidth) return null;

    double? myWidth;

    // width
    if (width != null)
    {
      myWidth = width;
    }

    // percentage width based on parent
    else if (widthPercentage != null && widthParent != null)
    {
      myWidth = ((widthPercentage!/100) * widthParent);
    }

    // apply model constraints
    if (myWidth != null)
    {
      // must be greater than minWidth
      if (minWidth != null && myWidth < minWidth!)
      {
        myWidth = minWidth!;
      }

      // must be greater than maxWidth
      if (maxWidth != null && myWidth > maxWidth!)
      {
        myWidth = maxWidth!;
      }
    }

    // cannot be negative
    if (myWidth != null && myWidth.isNegative)
    {
      myWidth = 0;
    }

    return myWidth;
  }

  // return the bounded height
  double? getHeight({double? heightParent})
  {
    if (!hasBoundedHeight) return null;

    double? myHeight;

    // height
    if (height != null)
    {
      myHeight = height;
    }

    // percentage height based on parent
    else if (heightPercentage != null && heightParent != null)
    {
      myHeight = ((heightPercentage!/100) * heightParent);
    }

    // apply model constraints
    if (myHeight != null)
    {
      // must be greater than minHeight
      if (minHeight != null && myHeight < minHeight!)
      {
        myHeight = minHeight!;
      }

      // must be greater than maxHeight
      if (maxHeight != null && myHeight > maxHeight!)
      {
        myHeight = maxHeight!;
      }
    }

    // cannot be negative
    if (myHeight != null && myHeight.isNegative)
    {
      myHeight = 0;
    }

    return myHeight;
  }

  // the flex width
  int? getWidthFlex()
  {
    // defined width takes precedence over flex
    if (hasBoundedWidth) return null;
    return flex ?? (expandHorizontally ? 1 : null);
  }

  // the flex height
  int? getHeightFlex()
  {
    // defined height takes precedence over flex
    if (hasBoundedHeight) return null;
    return flex ?? (expandVertically ? 1 : null);
  }

  //Constraints get tightest => Constraints.tightest(Constraints.tightest(model, system), calculated);
  Constraints get tightest => constraints;
  Constraints get tightestOrDefault
  {
    var constraints = tightest;
    if (constraints.height == null && constraints.maxHeight == null) constraints.maxHeight = System().screenheight.toDouble();
    if (constraints.width  == null && constraints.maxWidth  == null) constraints.maxWidth  = System().screenwidth.toDouble();
    return constraints;
  }

  setLayoutConstraints(BoxConstraints constraints)
  {
    system.minWidth  = constraints.minWidth;
    system.maxWidth  = constraints.maxWidth;
    system.minHeight = constraints.minHeight;
    system.maxHeight = constraints.maxHeight;
  }

  /// walks up the model tree looking for
  /// the first system non-null minWidth value
  double get myMinWidth
  {
    if (system.minWidth != null) return system.minWidth!;
    if (parent is ViewableWidgetModel) return (parent as ViewableWidgetModel).myMinWidth;
    return 0;
  }
  /// walks up the model tree looking for
  /// the first system non-null maxHeight value
  double get myMaxWidth
  {
    if (system.maxWidth != null && system.maxWidth != double.infinity) return system.maxWidth!;
    if (width           != null) return width!;
    if (maxWidth        != null) return maxWidth!;
    if (parent is ViewableWidgetModel) return (parent as ViewableWidgetModel).myMaxWidth;
    return 0;
  }

  /// walks up the model tree looking for
  /// the first system non-null minHeight value
  double get myMinHeight
  {
    if (system.minHeight != null && system.minHeight != double.infinity) return system.minHeight!;
    if (parent is ViewableWidgetModel) return (parent as ViewableWidgetModel).myMinHeight;
    return 0;
  }

  /// walks up the model tree looking for
  /// the first system non-null maxHeight value
  double get myMaxHeight
  {
    if (system.maxHeight != null && system.maxHeight != double.infinity) return system.maxHeight!;
    if (height           != null) return height!;
    if (maxHeight        != null) return maxHeight!;
    if (parent is ViewableWidgetModel) return (parent as ViewableWidgetModel).myMaxHeight;
    return 0;
  }

  // returns the constraints as calculated
  // by walking up the model tree and
  // examining system and local model constraints
  Constraints get calculated
  {
    Constraints constraints = Constraints();

    // calculated constraints
    Constraints calculated = Constraints();
    calculated.minWidth  = myMinWidth;
    calculated.maxWidth  = myMaxWidth;
    calculated.minHeight = myMinHeight;
    calculated.maxHeight = myMaxHeight;

    // constraints as specified on the model template
    Constraints model = this.constraints;

    // WIDTH
    constraints.width     = model.width;
    constraints.minWidth  = model.width  ?? model.minWidth  ?? calculated.minWidth;
    constraints.maxWidth  = model.width  ?? model.maxWidth  ?? calculated.maxWidth;

    // ensure not negative
    if (constraints.minWidth == null || constraints.minWidth!.isNegative) constraints.minWidth = null;
    if (constraints.maxWidth == null || constraints.maxWidth!.isNegative) constraints.maxWidth = null;

    // ensure max > min
    if (constraints.minWidth != null && constraints.maxWidth != null && constraints.minWidth! > constraints.maxWidth!)
    {
      var v = constraints.minWidth;
      constraints.minWidth = constraints.maxWidth;
      constraints.maxWidth = v;
    }

    // HEIGHT
    constraints.height    = model.height;
    constraints.minHeight = model.height ?? model.minHeight ?? calculated.minHeight;
    constraints.maxHeight = model.height ?? model.maxHeight ?? calculated.maxHeight;

    // ensure not negative
    if (constraints.minHeight != null && constraints.minHeight!.isNegative) constraints.minHeight = null;
    if (constraints.maxHeight != null && constraints.maxHeight!.isNegative) constraints.maxHeight = null;

    // ensure max > min
    if (constraints.minHeight != null && constraints.maxHeight != null && constraints.minHeight! > constraints.maxHeight!)
    {
      var v = constraints.minHeight;
      constraints.minHeight = constraints.maxHeight;
      constraints.maxHeight = v;
    }

    return constraints;
  }

  // returns the max width or screen width if unconstrained
  double get calculatedMaxWidthOrDefault
  {
    var v = myMaxWidth;
    if (v == double.infinity) v = System().screenwidth.toDouble();
    return v;
  }

  // returns the max height or screen width if unconstrained
  double get calculatedMaxHeightOrDefault
  {
    var v = myMaxHeight;
    if (v == double.infinity) v = System().screenheight.toDouble();
    return v;
  }

  // if the widgets own constraints specify a maxWidth then that is used
  // otherwise it gets the maxWidth from its parent walking up the model tree
  double get calculatedMaxWidthForPercentage
  {
    if (system.maxWidth != null && system.maxWidth != double.infinity) return system.maxWidth!;
    if (parent is ViewableWidgetModel) return (parent as ViewableWidgetModel).myMaxWidth;
    if (maxWidth == null || maxWidth == double.infinity) maxWidth = System().screenwidth.toDouble();
    return maxWidth!;
  }

  // if the widgets own constraints specify a maxWidth then that is used
  // otherwise it gets the maxWidth from its parent walking up the model tree
  double get calculatedMaxHeightForPercentage
  {
    if (system.maxHeight != null && maxHeight != double.infinity) return system.maxHeight!;
    if (parent is ViewableWidgetModel) return (parent as ViewableWidgetModel).myMaxHeight;
    if (maxHeight == null || maxHeight == double.infinity) return System().screenheight.toDouble();
    return maxHeight!;
  }
}