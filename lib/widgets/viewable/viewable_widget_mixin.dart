// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/data/data.dart';
import 'package:fml/event/handler.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/animation/animation_model.dart';
import 'package:fml/widgets/dragdrop/drag_drop_interface.dart';
import 'package:fml/widgets/dragdrop/dragdrop.dart';
import 'package:fml/widgets/dragdrop/draggable_view.dart';
import 'package:fml/widgets/dragdrop/droppable_view.dart';
import 'package:fml/widgets/modal/modal_model.dart';
import 'package:fml/widgets/prototype/prototype_model.dart';
import 'package:fml/widgets/tooltip/v2/tooltip_model.dart';
import 'package:fml/widgets/tooltip/v2/tooltip_view.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'dart:math';

mixin ViewableWidgetMixin on WidgetModel implements IDragDrop {

  // model holding the tooltip
  TooltipModel? tipModel;

  // holds animations
  List<AnimationModel>? animations;

  // viewable children
  List<ViewableWidgetMixin> get viewableChildren {
    List<ViewableWidgetMixin> list = [];
    if (children != null) {
      for (var child in children!) {
        if (child is ViewableWidgetMixin) list.add(child);
      }
    }
    return list;
  }

  final Constraints system = Constraints();

  // return the model constraints
  Constraints get constraints => Constraints(
      width: width,
      height: height,
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight);

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

  // width
  double? _widthPercentage;
  double? get widthPercentage => _widthPercentage;
  DoubleObservable? _width;
  set width(dynamic v) {
    if (_width != null) {
      _width!.set(v);
    } else if (v != null) {
      _width = DoubleObservable(Binding.toKey(id, 'width'), v,
          scope: scope, listener: onPropertyChange, setter: _widthSetter);
      _width!.set(v, notify: false);
    }
  }
  double? get width => _width?.get();

  // this routine enforces the min and max width
  // constraints from the template
  dynamic _widthSetter(dynamic value, {Observable? setter}) {
    // is the value a percentage?
    _widthPercentage = null;
    if (isPercent(value)) {
      _widthPercentage = toDouble(value.split("%")[0]);
      value = null;
    }

    // is the value a number?
    if (isNumeric(value)) {
      double v = toDouble(value)!;

      // must be greater than minWidth
      if (minWidth != null && v < minWidth!) v = minWidth!;

      // must be greater than maxWidth
      if (maxWidth != null && v > maxWidth!) v = maxWidth!;

      // cannot be negative
      if (v.isNegative) v = 0;

      if (v != toDouble(value)) value = v;
    }

    return value;
  }

  // height
  double? _heightPercentage;
  double? get heightPercentage => _heightPercentage;
  DoubleObservable? _height;
  set height(dynamic v) {
    if (_height != null) {
      _height!.set(v);
    } else if (v != null) {
      _height = DoubleObservable(Binding.toKey(id, 'height'), v,
          scope: scope, listener: onPropertyChange, setter: _heightSetter);
      _height!.set(v, notify: false);
    }
  }
  double? get height => _height?.get();

  // this routine enforces the min and max height
  // constraints from the template
  dynamic _heightSetter(dynamic value, {Observable? setter}) {
    // is the value a percentage?
    _heightPercentage = null;
    if (isPercent(value)) {
      _heightPercentage = toDouble(value.split("%")[0]);
      value = null;
    }

    // is the value a number?
    if (isNumeric(value)) {
      double v = toDouble(value)!;

      // must be greater than minHeight
      if (minHeight != null && v < minHeight!) v = minHeight!;

      // must be less than maxHeight
      if (maxHeight != null && v > maxHeight!) v = maxHeight!;

      // cannot be negative
      if (v.isNegative) v = 0;

      if (v != toDouble(value)) value = v;
    }

    return value;
  }

  // flex
  IntegerObservable? _flex;
  set flex(dynamic v) {
    if (_flex != null) {
      _flex!.set(v);
    } else if (v != null) {
      _flex = IntegerObservable(Binding.toKey(id, 'flex'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  int? get flex => _flex?.get();

  // this routine set the width silently and resets the
  // fixedWidth property
  setFlex(int v) {
    // create the _flex observable if it
    // hasn't already been created
    if (_flex == null) {
      _flex = IntegerObservable(Binding.toKey(id, 'flex'), null, scope: scope);
      _flex!.registerListener(onPropertyChange);
    }

    // set the width
    _flex?.set(v, notify: false);
  }

  // flex fit
  // loose or tight are only supported types
  StringObservable? _flexfit;
  set flexfit(dynamic v) {
    if (_flexfit != null) {
      _flexfit!.set(v);
    } else if (v != null) {
      _flexfit = StringObservable(Binding.toKey(id, 'flexfit'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  FlexFit? get flexFit {
    String? fit = _flexfit?.get()?.toLowerCase().trim();
    if (fit == "loose") return FlexFit.loose;
    if (fit == "tight") return FlexFit.tight;
    return null;
  }

  // min width
  double? _minWidthPercentage;
  double? get minWidthPercentage => _minWidthPercentage;
  DoubleObservable? _minWidth;
  set minWidth(dynamic v) {
    if (v != null) {
      if (isPercent(v)) {
        _minWidthPercentage = toDouble(v.split("%")[0]);
        v = null;
      } else {
        _minWidthPercentage = null;
      }
      if (_minWidth == null) {
        _minWidth = DoubleObservable(Binding.toKey(id, 'minWidth'), v,
            scope: scope, listener: onPropertyChange);
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
  set maxWidth(dynamic v) {
    if (v != null) {
      if (isPercent(v)) {
        _maxWidthPercentage = toDouble(v.split("%")[0]);
        v = null;
      } else {
        _maxWidthPercentage = null;
      }
      if (_maxWidth == null) {
        _maxWidth = DoubleObservable(Binding.toKey(id, 'maxwidth'), v,
            scope: scope, listener: onPropertyChange);
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
  set minHeight(dynamic v) {
    if (v != null) {
      if (isPercent(v)) {
        _minHeightPercentage = toDouble(v.split("%")[0]);
        v = null;
      } else {
        _minHeightPercentage = null;
      }
      if (_minHeight == null) {
        _minHeight = DoubleObservable(Binding.toKey(id, 'minheight'), v,
            scope: scope, listener: onPropertyChange);
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
  set maxHeight(dynamic v) {
    if (v != null) {
      if (isPercent(v)) {
        _maxHeightPercentage = toDouble(v.split("%")[0]);
        v = null;
      } else {
        _maxHeightPercentage = null;
      }
      if (_maxHeight == null) {
        _maxHeight = DoubleObservable(Binding.toKey(id, 'maxheight'), v,
            scope: scope, listener: onPropertyChange);
      } else if (v != null) {
        _maxHeight!.set(v);
      }
    }
  }

  double? get maxHeight => _maxHeight?.get();

  // return the bounded width
  double? getWidth({double? widthParent}) {
    if (!hasBoundedWidth) return null;

    double? myWidth;

    // width
    if (width != null) {
      myWidth = width;
    }

    // percentage width based on parent
    else if (widthPercentage != null && widthParent != null) {
      myWidth = ((widthPercentage! / 100) * widthParent);
    }

    // apply model constraints
    if (myWidth != null) {
      // must be greater than minWidth
      var minWidth = getMinWidth(widthParent: widthParent);
      if (minWidth != null && myWidth < minWidth) {
        myWidth = minWidth;
      }

      // must be greater than maxWidth
      var maxWidth = getMaxWidth(widthParent: widthParent);
      if (maxWidth != null && myWidth > maxWidth) {
        myWidth = maxWidth;
      }
    }

    // cannot be negative
    if (myWidth != null && myWidth.isNegative) {
      myWidth = 0;
    }

    return myWidth;
  }

  double? getMinWidth({double? widthParent}) {
    double? width;

    // width
    if (minWidth != null) {
      width = minWidth;
    }

    // percentage width based on parent
    else if (minWidthPercentage != null && widthParent != null) {
      width = ((minWidthPercentage! / 100) * widthParent);
    }

    // cannot be negative
    if (width != null && width.isNegative) {
      width = 0;
    }

    return width;
  }

  double? getMaxWidth({double? widthParent}) {
    double? width;

    // width
    if (maxWidth != null) {
      width = maxWidth;
    }

    // percentage width based on parent
    else if (maxWidthPercentage != null && widthParent != null) {
      width = ((maxWidthPercentage! / 100) * widthParent);
    }

    // cannot be negative
    if (width != null && width.isNegative) {
      width = 0;
    }

    return width;
  }

  // return the bounded height
  double? getHeight({double? heightParent}) {
    if (!hasBoundedHeight) return null;

    double? myHeight;

    // height
    if (height != null) {
      myHeight = height;
    }

    // percentage height based on parent
    else if (heightPercentage != null && heightParent != null) {
      myHeight = ((heightPercentage! / 100) * heightParent);
    }

    // apply model constraints
    if (myHeight != null) {
      // must be greater than minHeight
      var minHeight = getMinHeight(heightParent: heightParent);
      if (minHeight != null && myHeight < minHeight) {
        myHeight = minHeight;
      }

      // must be greater than maxHeight
      var maxHeight = getMaxHeight(heightParent: heightParent);
      if (maxHeight != null && myHeight > maxHeight) {
        myHeight = maxHeight;
      }
    }

    // cannot be negative
    if (myHeight != null && myHeight.isNegative) {
      myHeight = 0;
    }

    return myHeight;
  }

  double? getMinHeight({double? heightParent}) {
    double? height;

    // height
    if (minHeight != null) {
      height = minHeight;
    }

    // percentage height based on parent
    else if (minHeightPercentage != null && heightParent != null) {
      height = ((minHeightPercentage! / 100) * heightParent);
    }

    // cannot be negative
    if (height != null && height.isNegative) {
      height = 0;
    }

    return height;
  }

  double? getMaxHeight({double? heightParent}) {
    double? height;

    // height
    if (maxHeight != null) {
      height = maxHeight;
    }

    // percentage height based on parent
    else if (maxHeightPercentage != null && heightParent != null) {
      height = ((maxHeightPercentage! / 100) * heightParent);
    }

    // cannot be negative
    if (height != null && height.isNegative) {
      height = 0;
    }

    return height;
  }

  //Constraints get tightest => Constraints.tightest(Constraints.tightest(model, system), calculated);
  Constraints get tightest => constraints;
  Constraints get tightestOrDefault {
    var constraints = tightest;
    if (constraints.height == null && constraints.maxHeight == null) {
      constraints.maxHeight = System().screenheight.toDouble();
    }
    if (constraints.width == null && constraints.maxWidth == null) {
      constraints.maxWidth = System().screenwidth.toDouble();
    }
    return constraints;
  }

  setLayoutConstraints(BoxConstraints constraints) {
    system.minWidth = constraints.minWidth;
    system.maxWidth = constraints.maxWidth;
    system.minHeight = constraints.minHeight;
    system.maxHeight = constraints.maxHeight;
  }

  /// walks up the model tree looking for
  /// the first system non-null minWidth value
  double get myMinWidth {
    if (system.minWidth != null) return system.minWidth!;
    if (parent is ViewableWidgetMixin) {
      return (parent as ViewableWidgetMixin).myMinWidth;
    }
    return 0;
  }

  /// walks up the model tree looking for
  /// the first system non-null maxHeight value
  double get myMaxWidth {
    if (system.maxWidth != null && system.maxWidth != double.infinity) {
      return system.maxWidth!;
    }
    if (width != null) return width!;
    if (maxWidth != null) return maxWidth!;
    if (parent is ViewableWidgetMixin) {
      return (parent as ViewableWidgetMixin).myMaxWidth;
    }
    return 0;
  }

  /// walks up the model tree looking for
  /// the first system non-null minHeight value
  double get myMinHeight {
    if (system.minHeight != null && system.minHeight != double.infinity) {
      return system.minHeight!;
    }
    if (parent is ViewableWidgetMixin) {
      return (parent as ViewableWidgetMixin).myMinHeight;
    }
    return 0;
  }

  /// walks up the model tree looking for
  /// the first system non-null maxHeight value
  double get myMaxHeight {
    if (system.maxHeight != null && system.maxHeight != double.infinity) {
      return system.maxHeight!;
    }
    if (height != null) return height!;
    if (maxHeight != null) return maxHeight!;
    if (parent is ViewableWidgetMixin) {
      return (parent as ViewableWidgetMixin).myMaxHeight;
    }
    return 0;
  }

  // returns the max width or screen width if unconstrained
  double get myMaxWidthOrDefault {
    var v = myMaxWidth;
    if (v == double.infinity) v = System().screenwidth.toDouble();
    return v;
  }

  // returns the max height or screen width if unconstrained
  double get myMaxHeightOrDefault {
    var v = myMaxHeight;
    if (v == double.infinity) v = System().screenheight.toDouble();
    return v;
  }

  // if the widgets own constraints specify a maxWidth then that is used
  // otherwise it gets the maxWidth from its parent walking up the model tree
  double get myMaxWidthForPercentage {
    if (system.maxWidth != null && system.maxWidth != double.infinity) {
      return system.maxWidth!;
    }
    if (parent is ViewableWidgetMixin) {
      return (parent as ViewableWidgetMixin).myMaxWidth;
    }
    if (maxWidth == null || maxWidth == double.infinity) {
      maxWidth = System().screenwidth.toDouble();
    }
    return maxWidth!;
  }

  // if the widgets own constraints specify a maxWidth then that is used
  // otherwise it gets the maxWidth from its parent walking up the model tree
  double get calculatedMaxHeightForPercentage {
    if (system.maxHeight != null && maxHeight != double.infinity) {
      return system.maxHeight!;
    }
    if (parent is ViewableWidgetMixin) {
      return (parent as ViewableWidgetMixin).myMaxHeight;
    }
    if (maxHeight == null || maxHeight == double.infinity) {
      return System().screenheight.toDouble();
    }
    return maxHeight!;
  }
  
  // Depth - used in stack
  DoubleObservable? _depth;

  set depth(dynamic v) {
    if (_depth != null) {
      _depth!.set(v);
    } else if (v != null) {
      _depth = DoubleObservable(Binding.toKey(id, 'depth'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double? get depth => _depth?.get();

  // the flex width
  int? get flexWidth {
    // defined width takes precedence over flex
    if (hasBoundedWidth) return null;
    if (!visible) return null;
    return flex ?? (expandHorizontally || canExpandInfinitelyWide ? 1 : null);
  }

  // the flex height
  int? flexHeight() {
    // defined height takes precedence over flex
    if (hasBoundedHeight) return null;
    if (!visible) return null;
    return flex ?? (expandVertically || canExpandInfinitelyHigh ? 1 : null);
  }

  // view width
  double? _viewWidth;
  DoubleObservable? _viewWidthObservable;
  set viewWidth(double? v) {
    // important this gets before the observable
    _viewWidth = v;

    // we handle this slightly different for performance reasons
    // The observable is only created in deserialize if its bound
    if (_viewWidthObservable != null) _viewWidthObservable!.set(v);
  }

  double? get viewWidth => _viewWidth;

  // view height
  double? _viewHeight;
  DoubleObservable? _viewHeightObservable;
  set viewHeight(double? v) {
    // important this gets before the observable
    _viewHeight = v;

    // we handle this slightly different for performance reasons
    // The observable is only created in deserialize if its bound
    if (_viewHeightObservable != null) _viewHeightObservable!.set(v);
  }

  double? get viewHeight => _viewHeight;

  // view global X position
  double? _viewX;
  DoubleObservable? _viewXObservable;
  set viewX(double? v) {
    // important this gets before the observable
    _viewX = v;

    // we handle this slightly different for performance reasons
    // The observable is only created in deserialize if its bound
    if (_viewXObservable != null) _viewXObservable!.set(v);
  }

  double? get viewX => _viewX;

  // view global Y position
  double? _viewY;
  DoubleObservable? _viewYObservable;
  set viewY(double? v) {
    // important this gets before the observable
    _viewY = v;

    // we handle this slightly different for performance reasons
    // The observable is only created in deserialize if its bound
    if (_viewYObservable != null) _viewYObservable!.set(v);
  }

  double? get viewY => _viewY;

  /// alignment and layout attributes
  ///
  /// The horizontal alignment of the widgets children, overrides `center`. Can be `left`, `right`, `start`, or `end`.
  StringObservable? _halign;
  set halign(dynamic v) {
    if (_halign != null) {
      _halign!.set(v);
    } else if (v != null) {
      _halign = StringObservable(Binding.toKey(id, 'halign'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String? get halign => _halign?.get();

  /// The vertical alignment of the widgets children, overrides `center`. Can be `top`, `bottom`, `start`, or `end`.
  StringObservable? _valign;
  set valign(dynamic v) {
    if (_valign != null) {
      _valign!.set(v);
    } else if (v != null) {
      _valign = StringObservable(Binding.toKey(id, 'valign'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String? get valign => _valign?.get();

  // used by the view to determine if it needs to wrap itself
  // in a VisibilityDetector
  bool? _addVisibilityDetector;
  bool get needsVisibilityDetector => _addVisibilityDetector ?? false;

  /// onscreen event string - fires when object is 100 on screen
  StringObservable? _onscreen;
  set onscreen(dynamic v) {
    if (_onscreen != null) {
      _onscreen!.set(v);
    } else if (v != null) {
      _onscreen =
          StringObservable(Binding.toKey(id, 'onscreen'), v, scope: scope);

      // create the visibility tag
      visibleArea = 0;
      visibleHeight = 0;
      visibleWidth = 0;
    }
  }

  String? get onscreen => _onscreen?.get();

  /// offscreen event string - fires when object is 100 on screen
  StringObservable? _offscreen;
  set offscreen(dynamic v) {
    if (_offscreen != null) {
      _offscreen!.set(v);
    } else if (v != null) {
      _offscreen =
          StringObservable(Binding.toKey(id, 'offscreen'), v, scope: scope);

      // create the visibility tag
      visibleArea = 0;
      visibleHeight = 0;
      visibleWidth = 0;
    }
  }

  String? get offscreen => _offscreen?.get();

  /// visible area - percent of object visible on screen
  DoubleObservable? _visibleArea;
  set visibleArea(dynamic v) {
    if (_visibleArea != null) {
      _visibleArea!.set(v);
    } else if (v != null) {
      _visibleArea =
          DoubleObservable(Binding.toKey(id, 'visiblearea'), v, scope: scope);
    }
  }

  double? get visibleArea => _visibleArea?.get();

  /// visible Height - percent of objects height visible on screen
  DoubleObservable? _visibleHeight;
  set visibleHeight(dynamic v) {
    if (_visibleHeight != null) {
      _visibleHeight!.set(v);
    } else if (v != null) {
      _visibleHeight =
          DoubleObservable(Binding.toKey(id, 'visibleheight'), v, scope: scope);
    }
  }

  double? get visibleHeight => _visibleHeight?.get();

  /// visible Width - percent of objects width visible on screen
  DoubleObservable? _visibleWidth;
  set visibleWidth(dynamic v) {
    if (_visibleWidth != null) {
      _visibleWidth!.set(v);
    } else if (v != null) {
      _visibleWidth =
          DoubleObservable(Binding.toKey(id, 'visiblewidth'), v, scope: scope);
    }
  }
  double? get visibleWidth => _visibleWidth?.get();

  set margins(dynamic v) {
    // build PADDINGS array
    if (v is String) {
      var s = v.split(',');

      // all
      if (s.length == 1) {
        marginTop = s[0];
        marginRight = s[0];
        marginBottom = s[0];
        marginLeft = s[0];
      }

      // top/bottom
      else if (s.length == 2) {
        marginTop = s[0];
        marginRight = s[1];
        marginBottom = s[0];
        marginLeft = s[1];
      }

      // top/bottom
      else if (s.length == 3) {
        marginTop = s[0];
        marginRight = s[1];
        marginBottom = s[2];
        marginLeft = s[1];
      }

      // top/bottom
      else if (s.length > 3) {
        marginTop = s[0];
        marginRight = s[1];
        marginBottom = s[2];
        marginLeft = s[3];
      }
    }
  }

  // margins top
  DoubleObservable? _marginTop;
  set marginTop(dynamic v) {
    if (_marginTop != null) {
      _marginTop!.set(v);
    } else if (v != null) {
      _marginTop = DoubleObservable(Binding.toKey(id, 'margintop'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  double? get marginTop => _marginTop?.get();

  // margins right
  DoubleObservable? _marginRight;
  set marginRight(dynamic v) {
    if (_marginRight != null) {
      _marginRight!.set(v);
    } else if (v != null) {
      _marginRight = DoubleObservable(Binding.toKey(id, 'marginright'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  double? get marginRight => _marginRight?.get();

  // margins bottom
  DoubleObservable? _marginBottom;
  set marginBottom(dynamic v) {
    if (_marginBottom != null) {
      _marginBottom!.set(v);
    } else if (v != null) {
      _marginBottom = DoubleObservable(Binding.toKey(id, 'marginbottom'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  double? get marginBottom => _marginBottom?.get();

  // margins left
  DoubleObservable? _marginLeft;
  set marginLeft(dynamic v) {
    if (_marginLeft != null) {
      _marginLeft!.set(v);
    } else if (v != null) {
      _marginLeft = DoubleObservable(Binding.toKey(id, 'marginleft'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  double? get marginLeft => _marginLeft?.get();

  set padding(dynamic v) {
    // build PADDINGS array
    if (v is String) {
      var s = v.split(',');

      // all
      if (s.length == 1) {
        paddingTop = s[0];
        paddingRight = s[0];
        paddingBottom = s[0];
        paddingLeft = s[0];
      }

      // top/bottom
      else if (s.length == 2) {
        paddingTop = s[0];
        paddingRight = s[1];
        paddingBottom = s[0];
        paddingLeft = s[1];
      }

      // top/bottom
      else if (s.length == 3) {
        paddingTop = s[0];
        paddingRight = s[1];
        paddingBottom = s[2];
        paddingLeft = s[1];
      }

      // top/bottom
      else if (s.length > 3) {
        paddingTop = s[0];
        paddingRight = s[1];
        paddingBottom = s[2];
        paddingLeft = s[3];
      }
    }
  }

  // paddings top
  DoubleObservable? _paddingTop;
  set paddingTop(dynamic v) {
    if (_paddingTop != null) {
      _paddingTop!.set(v);
    } else if (v != null) {
      _paddingTop = DoubleObservable(Binding.toKey(id, 'paddingtop'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double? get paddingTop => _paddingTop?.get();

  // paddings right
  DoubleObservable? _paddingRight;
  set paddingRight(dynamic v) {
    if (_paddingRight != null) {
      _paddingRight!.set(v);
    } else if (v != null) {
      _paddingRight = DoubleObservable(Binding.toKey(id, 'paddingright'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double? get paddingRight => _paddingRight?.get();

  // paddings bottom
  DoubleObservable? _paddingBottom;
  set paddingBottom(dynamic v) {
    if (_paddingBottom != null) {
      _paddingBottom!.set(v);
    } else if (v != null) {
      _paddingBottom = DoubleObservable(Binding.toKey(id, 'paddingbottom'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double? get paddingBottom => _paddingBottom?.get();

  // paddings left
  DoubleObservable? _paddingLeft;
  set paddingLeft(dynamic v) {
    if (_paddingLeft != null) {
      _paddingLeft!.set(v);
    } else if (v != null) {
      _paddingLeft = DoubleObservable(Binding.toKey(id, 'paddingleft'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double? get paddingLeft => _paddingLeft?.get();

  // visible
  BooleanObservable? _visible;
  set visible(dynamic v) {
    if (_visible != null) {
      _visible!.set(v);
    } else if (v != null) {
      _visible = BooleanObservable(Binding.toKey(id, 'visible'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool get visible => _visible?.get() ?? true;

  // enabled
  BooleanObservable? _enabled;
  set enabled(dynamic v) {
    if (_enabled != null) {
      _enabled!.set(v);
    } else if (v != null) {
      _enabled = BooleanObservable(Binding.toKey(id, 'enabled'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool get enabled => _enabled?.get() ?? true;

  // draggable
  BooleanObservable? _draggable;
  set draggable(dynamic v) {
    if (_draggable != null) {
      _draggable!.set(v);
    } else if (v != null) {
      _draggable = BooleanObservable(Binding.toKey(id, 'draggable'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool get draggable => _draggable?.get() ?? false;

  // ondrag
  @override
  StringObservable? onDragObservable;
  set ondrag(dynamic v) {
    if (onDragObservable != null) {
      onDragObservable!.set(v);
    } else if (v != null) {
      onDragObservable = StringObservable(Binding.toKey(id, 'ondrag'), v,
          scope: scope, lazyEval: true);
    }
  }

  String? get ondrag => onDragObservable?.get();

  // droppable
  BooleanObservable? _droppable;
  set droppable(dynamic v) {
    if (_droppable != null) {
      _droppable!.set(v);
    } else if (v != null) {
      _droppable = BooleanObservable(Binding.toKey(id, 'droppable'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool get droppable => _droppable?.get() ?? false;

  // ondrop - fired on the droppable when the draggable is dropped and after accept
  @override
  StringObservable? onDropObservable;
  set ondrop(dynamic v) {
    if (onDropObservable != null) {
      onDropObservable!.set(v);
    } else if (v != null) {
      onDropObservable = StringObservable(Binding.toKey(id, 'ondrop'), v,
          scope: scope, lazyEval: true);
    }
  }

  String? get ondrop => onDropObservable?.get();

  // ondropped - fired on the draggable after the ondrop
  @override
  StringObservable? onDroppedObservable;
  set ondropped(dynamic v) {
    if (onDroppedObservable != null) {
      onDroppedObservable!.set(v);
    } else if (v != null) {
      onDroppedObservable = StringObservable(Binding.toKey(id, 'ondropped'), v,
          scope: scope, lazyEval: true);
    }
  }

  String? get ondropped => onDroppedObservable?.get();

  // drop element
  ListObservable? _drop;

  @override
  set drop(dynamic v) {
    if (_drop != null) {
      _drop!.set(v);
    } else if (v != null) {
      _drop = ListObservable(Binding.toKey(id, 'drop'), null, scope: scope);

      // set the value
      _drop!.set(v);
    }
  }

  @override
  dynamic get drop => _drop?.get();

  // onWillAcceptObservable
  @override
  BooleanObservable? canDropObservable;
  set canDrop(dynamic v) {
    if (canDropObservable != null) {
      canDropObservable!.set(v);
    } else if (v != null) {
      canDropObservable =
          BooleanObservable(Binding.toKey(id, 'candrop'), v, scope: scope);
    }
  }
  bool? get canDrop => canDropObservable?.get();

  set _colors(dynamic v) {
    // build colors array
    if (v is String) {
      if (!Observable.isEvalSignature(v)) {
        var s = v.split(',');
        if (s.isNotEmpty) color = s[0].trim();
        if (s.length > 1) color2 = s[1].trim();
        if (s.length > 2) color3 = s[2].trim();
        if (s.length > 3) color4 = s[3].trim();
      } else {
        color = v;
      }
    }
  }

  // color
  ColorObservable? _color;
  set color(dynamic v) {
    if (_color != null) {
      _color!.set(v);
    } else if (v != null) {
      _color = ColorObservable(Binding.toKey(id, 'color'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  Color? get color => _color?.get();

  // color2
  ColorObservable? _color2;
  set color2(dynamic v) {
    if (_color2 != null) {
      _color2!.set(v);
    } else if (v != null) {
      _color2 = ColorObservable(Binding.toKey(id, 'color2'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  Color? get color2 => _color2?.get();

  // color3
  ColorObservable? _color3;
  set color3(dynamic v) {
    if (_color3 != null) {
      _color3!.set(v);
    } else if (v != null) {
      _color3 = ColorObservable(Binding.toKey(id, 'color3'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  Color? get color3 => _color3?.get();

  // color4
  ColorObservable? _color4;
  set color4(dynamic v) {
    if (_color4 != null) {
      _color4!.set(v);
    } else if (v != null) {
      _color4 = ColorObservable(Binding.toKey(id, 'color4'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  Color? get color4 => _color4?.get();

  /// The opacity of the widget
  DoubleObservable? _opacity;
  set opacity(dynamic v) {
    if (_opacity != null) {
      _opacity!.set(v);
    } else if (v != null) {
      _opacity = DoubleObservable(Binding.toKey(id, 'opacity'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  double? get opacity => _opacity?.get();

  // rotation
  DoubleObservable? _rotation;
  set rotation(dynamic v) {
    if (_rotation != null) {
      _rotation!.set(v);
    } else if (v != null) {
      _rotation = DoubleObservable(Binding.toKey(id, 'rotation'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  double? get rotation => _rotation?.get();

  // flip
  StringObservable? _flip;
  set flip(dynamic v) {
    if (_flip != null) {
      _flip!.set(v);
    } else if (v != null) {
      _flip = StringObservable(Binding.toKey(id, 'flip'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String? get flip => _flip?.get();

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {

    // deserialize
    super.deserialize(xml);

    // set size constraints
    width = Xml.get(node: xml, tag: 'width');
    height = Xml.get(node: xml, tag: 'height');
    minWidth = Xml.get(node: xml, tag: 'minwidth');
    maxWidth = Xml.get(node: xml, tag: 'maxwidth');
    minHeight = Xml.get(node: xml, tag: 'minheight');
    maxHeight = Xml.get(node: xml, tag: 'maxheight');
    depth = Xml.get(node: xml, tag: 'depth');

    // properties
    visible = Xml.get(node: xml, tag: 'visible');
    enabled = Xml.get(node: xml, tag: 'enabled');
    halign = Xml.get(node: xml, tag: 'halign');
    valign = Xml.get(node: xml, tag: 'valign');
    flex = Xml.get(node: xml, tag: 'flex');
    flexfit = Xml.get(node: xml, tag: 'flexfit');
    onscreen = Xml.get(node: xml, tag: 'onscreen');
    offscreen = Xml.get(node: xml, tag: 'offscreen');

    // _colors array - sets color1, color2, color3 and colo4
    _colors = Xml.get(node: xml, tag: 'color');

    // visual transforms
    opacity = Xml.get(node: xml, tag: 'opacity');
    rotation = Xml.get(node: xml, tag: 'rotate') ?? Xml.get(node: xml, tag: 'rotation');
    flip = Xml.get(node: xml, tag: 'flip');

    // drag
    draggable = Xml.get(node: xml, tag: 'draggable');
    if (draggable) {
      ondrag = Xml.get(node: xml, tag: 'ondrag');
      ondropped = Xml.get(node: xml, tag: 'ondropped');
    }

    // drop
    droppable = Xml.get(node: xml, tag: 'droppable');
    if (droppable) {
      ondrop = Xml.get(node: xml, tag: 'ondrop');
      canDrop = Xml.get(node: xml, tag: 'candrop');
      drop = Data();
    }

    // view sizing and position
    // these are treated differently for efficiency reasons
    // we only create the observable if its bound to in the template
    // otherwise we just store the value in a simple double variable
    String? key;
    if (WidgetModel.isBound(this, key = Binding.toKey(id, 'viewwidth'))) {
      _viewWidthObservable = DoubleObservable(key, null, scope: scope);
    }
    if (WidgetModel.isBound(this, key = Binding.toKey(id, 'viewheight'))) {
      _viewHeightObservable = DoubleObservable(key, null, scope: scope);
    }
    if (WidgetModel.isBound(this, key = Binding.toKey(id, 'viewx'))) {
      _viewXObservable = DoubleObservable(key, null, scope: scope);
    }
    if (WidgetModel.isBound(this, key = Binding.toKey(id, 'viewy'))) {
      _viewYObservable = DoubleObservable(key, null, scope: scope);
    }

    // view requires a VisibilityDetector if either onstage or offstage is set or
    // someone is bound to my visibility
    _addVisibilityDetector = visible &&
        (!isNullOrEmpty(onscreen) ||
            !isNullOrEmpty(offscreen) ||
            WidgetModel.isBound(this, Binding.toKey(id, 'visiblearea')) ||
            WidgetModel.isBound(this, Binding.toKey(id, 'visibleheight')) ||
            WidgetModel.isBound(this, Binding.toKey(id, 'visiblewidth')));

    // set margins. Can be comma separated top,left,bottom,right
    // space around the widget
    var margins = Xml.attribute(node: xml, tag: 'margin') ??
        Xml.attribute(node: xml, tag: 'margins');
    this.margins = margins;

    // set padding. Can be comma separated top,left,bottom,right
    // space around the widget's children
    var padding = Xml.attribute(node: xml, tag: 'pad') ??
        Xml.attribute(node: xml, tag: 'padding') ??
        Xml.attribute(node: xml, tag: 'padd');
    this.padding = padding;

    // tooltip
    var tooltip = Xml.attribute(node: xml, tag: 'tip') ??
        Xml.attribute(node: xml, tag: 'tootip');
    List<TooltipModel> tips =
    findChildrenOfExactType(TooltipModel).cast<TooltipModel>();
    if (tips.isNotEmpty) {
      tipModel = tips.first;
      removeChildrenOfExactType(TooltipModel);
    } else if (tooltip != null) {
      // build tooltip
      XmlElement eTip = XmlElement(XmlName("TOOLTIP"));

      // build text
      tooltip = tooltip.replaceAll("{this.id}", id);
      XmlElement eText = XmlElement(XmlName("TEXT"));
      eText.attributes.add(XmlAttribute(XmlName("value"), tooltip));
      eTip.children.add(eText);

      var model = WidgetModel.fromXml(this, eTip);
      tipModel = (model is TooltipModel) ? model : null;
    }

    // add animations
    children?.forEach((child) {
      if (child is AnimationModel) {
        animations ??= [];
        animations!.add(child);
      }
    });

    // remove animations from child list
    if (animations != null) {
      children?.removeWhere((element) => animations!.contains(element));
    }
  }

  AnimationModel? getAnimationModel(String id) {
    if (animations == null) return null;
    var models = animations!.where((model) => model.id == id);
    return (models.isNotEmpty) ? models.first : null;
  }

  @override
  Future<bool?> execute(
      String caller, String propertyOrFunction, List<dynamic> arguments) async {
    /// setter
    if (scope == null) return null;
    var function = propertyOrFunction.toLowerCase().trim();

    switch (function) {
      case "animate":
        animate(this, caller, propertyOrFunction, arguments);
        break;
    }
    return super.execute(caller, propertyOrFunction, arguments);
  }

  // set visibility
  double oldVisibility = 0;
  bool hasGoneOffscreen = false;
  bool hasGoneOnscreen = false;

  void onVisibilityChanged(VisibilityInfo info) {
    if (oldVisibility == (info.visibleFraction * 100)) return;

    visibleHeight = info.size.height > 0
        ? ((info.visibleBounds.height / info.size.height) * 100)
        : 0.0;
    visibleWidth = info.size.width > 0
        ? ((info.visibleBounds.width / info.size.width) * 100)
        : 0.0;
    visibleArea = info.visibleFraction * 100;

    oldVisibility = visibleArea ?? 0.0;

    if (visibleArea! > 1 && !hasGoneOnscreen) {
      if (!isNullOrEmpty(_onscreen)) EventHandler(this).execute(_onscreen);
      hasGoneOnscreen = true;
    } else if (visibleArea! == 0 && hasGoneOnscreen) {
      if (!isNullOrEmpty(_offscreen)) EventHandler(this).execute(_offscreen);
      hasGoneOnscreen = false;
    }
  }

  @override
  void dispose() {
    // dispose of tip model
    tipModel?.dispose();

    // dispose of animations
    animations?.forEach((animation) => animation.dispose());

    // dispose
    super.dispose();
  }

  Widget getReactiveView(Widget view) {
    // wrap in visibility detector?
    if (needsVisibilityDetector) {
      view = VisibilityDetector(
          key: ObjectKey(this),
          onVisibilityChanged: onVisibilityChanged,
          child: view);
    }

    // wrap in tooltip?
    if (tipModel != null) view = TooltipView(tipModel!, view);

    // droppable?
    if (droppable && view is! DroppableView) {
      view = DroppableView(this, view);
    }

    // draggable?
    if (draggable && view is! DraggableView) {
      view = DraggableView(this, view);
    }

    // wrap animations.
    if (animations != null) {
      var animations = this.animations!.reversed;
      for (var model in animations) {
        view = model.getAnimatedView(view);
      }
    }
    return view;
  }

  /// this routine creates views for all
  /// of its children
  List<Widget> inflate() {
    // process children
    List<Widget> views = [];
    for (var model in viewableChildren) {
      if (model is! ModalModel) {
        var view = model.getView();
        if (view != null) views.add(view);
      }
    }
    return views;
  }

  void layoutComplete(Size size, Offset offset) {
    // set the view width, height and position
    if (size.width != viewWidth ||
        size.height != viewHeight ||
        offset.dx != viewX ||
        offset.dy != viewY) {
      viewWidth = size.width;
      viewHeight = size.height;
      viewX = offset.dx;
      viewY = offset.dy;
    }
  }

  // animate the model
  static bool animate(ViewableWidgetMixin model, String caller,
      String propertyOrFunction, List<dynamic> arguments) {
    var animations = model.animations;
    if (animations != null) {
      var id = elementAt(arguments, 0);
      AnimationModel? animation;
      if (!isNullOrEmpty(id)) {
        var list = animations.where((animation) => animation.id == id);
        if (list.isNotEmpty) animation = list.first;
      } else {
        animation = animations.first;
      }
      animation?.execute(caller, propertyOrFunction, arguments);
    }
    return true;
  }

  // on will accept during drop
  @override
  bool willAccept(IDragDrop draggable) => DragDrop.willAccept(this, draggable);

  // on drop event
  @override
  void onDrop(IDragDrop draggable, {Offset? dropSpot}) {
    if (parent is PrototypeModel) {
      (parent as PrototypeModel)
          .onDragDrop(this, draggable, dropSpot: dropSpot);
    } else {
      DragDrop.onDrop(this, draggable, dropSpot: dropSpot);
    }
  }

  // on drag event
  @override
  void onDrag() async => await DragDrop.onDrag(this);

  // get the view
  Widget? getView() => throw ("getView() Not Implemented");
}

class Constraints {
  Constraints(
      {double? width,
        double? minWidth,
        double? maxWidth,
        double? height,
        double? minHeight,
        double? maxHeight}) {
    this.width = width;
    this.minWidth = minWidth;
    this.maxWidth = maxWidth;

    this.height = height;
    this.minHeight = minHeight;
    this.maxHeight = maxHeight;
  }

  // width
  double? _width;
  set width(double? v) => _width = v;
  double? get width {
    if (_width == null) return null;
    if (_width == double.infinity || _width == double.negativeInfinity) {
      return null;
    }
    if (_width!.isNegative) return null;
    return _width;
  }

  double? _minWidth;
  set minWidth(double? v) => _minWidth = v;
  double? get minWidth {
    if (_minWidth == null) return null;
    if (_minWidth == double.infinity || _minWidth == double.negativeInfinity) {
      return null;
    }
    if (_minWidth!.isNegative) return null;
    return _minWidth;
  }

  double? _maxWidth;
  set maxWidth(double? v) => _maxWidth = v;
  double? get maxWidth {
    if (_maxWidth == null) return null;
    if (_maxWidth == double.infinity || _maxWidth == double.negativeInfinity) {
      return null;
    }
    if (_maxWidth!.isNegative) return null;
    return _maxWidth;
  }

  // height
  double? _height;
  set height(double? v) => _height = v;
  double? get height {
    if (_height == null) return null;
    if (_height == double.infinity || _height == double.negativeInfinity) {
      return null;
    }
    if (_height!.isNegative) return null;
    return _height;
  }

  double? _minHeight;
  set minHeight(double? v) => _minHeight = v;
  double? get minHeight {
    if (_minHeight == null) return null;
    if (_minHeight == double.infinity || _minHeight == double.negativeInfinity) {
      return null;
    }
    if (_minHeight!.isNegative) return null;
    return _minHeight;
  }

  double? _maxHeight;
  set maxHeight(double? v) => _maxHeight = v;
  double? get maxHeight {
    if (_maxHeight == null) return null;
    if (_maxHeight == double.infinity || _maxHeight == double.negativeInfinity) {
      return null;
    }
    if (_maxHeight!.isNegative) return null;
    return _maxHeight;
  }

  bool get isNotEmpty => hasVerticalConstraints || hasHorizontalConstraints;
  bool get isEmpty => !isNotEmpty;

  bool get hasVerticalContractionConstraints {
    var h = height ?? minHeight ?? double.negativeInfinity;
    return h > double.negativeInfinity;
  }

  bool get hasVerticalExpansionConstraints {
    var h = height ?? maxHeight ?? double.infinity;
    return h < double.infinity;
  }

  bool get hasVerticalConstraints =>
      hasVerticalExpansionConstraints || hasVerticalContractionConstraints;

  bool get hasHorizontalContractionConstraints {
    var w = width ?? minWidth ?? double.negativeInfinity;
    return w > double.negativeInfinity;
  }

  bool get hasHorizontalExpansionConstraints {
    var w = width ?? maxWidth ?? double.infinity;
    return w < double.infinity;
  }

  bool get hasHorizontalConstraints =>
      hasHorizontalExpansionConstraints || hasHorizontalContractionConstraints;

  static Constraints clone(Constraints constraints) => Constraints(
      width: constraints.width,
      height: constraints.height,
      minWidth: constraints.minWidth,
      maxWidth: constraints.maxWidth,
      minHeight: constraints.minHeight,
      maxHeight: constraints.maxHeight);

  static Constraints tightest(
      Constraints constraints1, Constraints constraints2) {
    Constraints constraints = Constraints();

    constraints.width = min(constraints1.width ?? double.infinity,
        constraints2.width ?? double.infinity);
    if (constraints.width == double.infinity) constraints.width = null;

    constraints.minWidth = max(constraints1.minWidth ?? double.negativeInfinity,
        constraints2.minWidth ?? double.negativeInfinity);
    if (constraints.minWidth == double.negativeInfinity) {
      constraints.minWidth = null;
    }

    constraints.maxWidth = max(constraints1.maxWidth ?? double.negativeInfinity,
        constraints2.maxWidth ?? double.negativeInfinity);
    if (constraints.maxWidth == double.infinity) constraints.maxWidth = null;

    constraints.height = min(constraints1.height ?? double.infinity,
        constraints2.height ?? double.infinity);
    if (constraints.height == double.infinity) constraints.height = null;

    constraints.minHeight = max(
        constraints1.minHeight ?? double.negativeInfinity,
        constraints2.minHeight ?? double.negativeInfinity);
    if (constraints.minHeight == double.negativeInfinity) {
      constraints.minHeight = null;
    }

    constraints.maxHeight = max(
        constraints1.maxHeight ?? double.negativeInfinity,
        constraints2.maxHeight ?? double.negativeInfinity);
    if (constraints.maxHeight == double.infinity) constraints.maxHeight = null;

    return constraints;
  }
}