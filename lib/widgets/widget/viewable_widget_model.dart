// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/event/handler.dart';
import 'package:fml/widgets/animation/animation_model.dart';
import 'package:fml/widgets/tooltip/v2/tooltip_model.dart';
import 'package:fml/widgets/tooltip/v2/tooltip_view.dart';
import 'package:fml/widgets/widget/constraint.dart';
import 'package:fml/widgets/widget/constraint_model.dart';
import 'package:fml/widgets/widget/decorated_widget_model.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';
import 'package:fml/widgets/widget/widget_model.dart';

class ViewableWidgetModel extends WidgetModel
{
  // model holding the tooltip
  TooltipModel? tipModel;

  // holds animations
  List<AnimationModel>? animations;

  // constraints
  late final ConstraintModel _constraints;
  late final ConstraintSet constraints;
  double? calculateMinWidth()  => _constraints.calculateMinWidth();
  double? calculateMaxWidth()  => _constraints.calculateMaxWidth();
  double? calculateMinHeight() => _constraints.calculateMinHeight();
  double? calculateMaxHeight() => _constraints.calculateMaxHeight();

  // viewable children
  List<ViewableWidgetModel> get viewableChildren
  {
    List<ViewableWidgetModel> list = [];
    children?.forEach((child)
    {
      if (child is ViewableWidgetModel) list.add(child);
    });
    return list;
  }

  // width
  double? get width  => _constraints.width;
  set width(dynamic v) => _constraints.width = v;

  // height
  double? get height => _constraints.height;
  set height(dynamic v) => _constraints.height = v;

  // %width
  double? get pctWidth => _constraints.pctWidth;

  // %height
  double? get pctHeight => _constraints.pctHeight;

  // min width
  @protected
  set minWidth(dynamic v) => _constraints.minWidth = v;

  // max width
  @protected
  set maxWidth(dynamic v) => _constraints.maxWidth = v;

  // min height
  @protected
  set minHeight(dynamic v) => _constraints.minHeight = v;
  double? get minHeight => _constraints.minHeight;

  // max height
  @protected
  set maxHeight(dynamic v) => _constraints.maxHeight = v;
  double? get maxHeight => _constraints.maxHeight;

  /// VIEW LAYOUT

  // view width
  double? _viewWidth;
  DoubleObservable? _viewWidthObservable;
  set viewWidth(double? v)
  {
    // we handle this slightly different for performance reasons
    // The observable is only created in deserialize if its bound
    if (_viewWidthObservable != null) _viewWidthObservable!.set(v);
    _viewWidth = v;
  }
  double? get viewWidth => _viewWidth;

  // view height
  double? _viewHeight;
  DoubleObservable? _viewHeightObservable;
  set viewHeight(double? v)
  {
    // we handle this slightly different for performance reasons
    // The observable is only crted in deserialize if its bound
    if (_viewHeightObservable != null) _viewHeightObservable!.set(v);
    _viewHeight = v;
  }
  double? get viewHeight => _viewHeight;

  // view global X position
  double? _viewX;
  DoubleObservable? _viewXObservable;
  set viewX(double? v)
  {
    // we handle this slightly different for performance reasons
    // The observable is only crted in deserialize if its bound
    if (_viewXObservable != null) _viewXObservable!.set(v);
    _viewX = v;
  }
  double? get viewX => _viewX;

  // view global Y position
  double? _viewY;
  DoubleObservable? _viewYObservable;
  set viewY(double? v)
  {
    // we handle this slightly different for performance reasons
    // The observable is only crted in deserialize if its bound
    if (_viewYObservable != null) _viewYObservable!.set(v);
    _viewY = v;
  }
  double? get viewY => _viewY;
  
  /// alignment and layout attributes
  ///
  /// The horizontal alignment of the widgets children, overrides `center`. Can be `left`, `right`, `start`, or `end`.
  StringObservable? _halign;
  set halign(dynamic v)
  {
    if (_halign != null)
    {
      _halign!.set(v);
    }
    else if (v != null)
    {
      _halign = StringObservable(Binding.toKey(id, 'halign'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get halign => _halign?.get();

  /// The vertical alignment of the widgets children, overrides `center`. Can be `top`, `bottom`, `start`, or `end`.
  StringObservable? _valign;
  set valign(dynamic v)
  {
    if (_valign != null)
    {
      _valign!.set(v);
    }
    else if (v != null)
    {
      _valign = StringObservable(Binding.toKey(id, 'valign'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get valign => _valign?.get();

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

  // used by the view to determine if it needs to wrap itself
  // in a VisibilityDetector
  bool? _addVisibilityDetector;
  bool get needsVisibilityDetector => _addVisibilityDetector ?? false;

  /// onscreen event string - fires when object is 100 on screen
  StringObservable? _onscreen;
  set onscreen(dynamic v) 
  {
    if (_onscreen != null) 
    {
      _onscreen!.set(v);
    }
    else if (v != null)
    {
      _onscreen = StringObservable(Binding.toKey(id, 'onscreen'), v, scope: scope);

      // create the visibility tag
      visibleArea   = 0;
      visibleHeight = 0;
      visibleWidth  = 0;
    }
  }
  String? get onscreen => _onscreen?.get();

  /// offscreen event string - fires when object is 100 on screen
  StringObservable? _offscreen;
  set offscreen(dynamic v) 
  {
    if (_offscreen != null) 
    {
      _offscreen!.set(v);
    } 
    else if (v != null) 
    {
      _offscreen = StringObservable(Binding.toKey(id, 'offscreen'), v, scope: scope);

      // create the visibility tag
      visibleArea   = 0;
      visibleHeight = 0;
      visibleWidth  = 0;
    }
  }
  String? get offscreen => _offscreen?.get();

  /// visible area - percent of object visible on screen
  DoubleObservable? _visibleArea;
  set visibleArea(dynamic v) 
  {
    if (_visibleArea != null) 
    {
      _visibleArea!.set(v);
    } 
    else if (v != null) 
    {
      _visibleArea = DoubleObservable(Binding.toKey(id, 'visiblearea'), v, scope: scope);
    }
  }
  double? get visibleArea => _visibleArea?.get();

  /// visible Height - percent of objects height visible on screen
  DoubleObservable? _visibleHeight;
  set visibleHeight(dynamic v)
  {
    if (_visibleHeight != null)
    {
      _visibleHeight!.set(v);
    }
    else if (v != null)
    {
      _visibleHeight = DoubleObservable(Binding.toKey(id, 'visibleheight'), v, scope: scope);
    }
  }
  double? get visibleHeight => _visibleHeight?.get();

  /// visible Width - percent of objects width visible on screen
  DoubleObservable? _visibleWidth;
  set visibleWidth(dynamic v)
  {
    if (_visibleWidth != null)
    {
      _visibleWidth!.set(v);
    }
    else if (v != null)
    {
      _visibleWidth = DoubleObservable(Binding.toKey(id, 'visiblewidth'), v, scope: scope);
    }
  }
  double? get visibleWidth => _visibleWidth?.get();

  set padding(dynamic v)
  {
    // build PADDINGS array
    if (v is String)
    {
      var s = v.split(',');
      if (s.length > 0) padding1 = s[0];
      if (s.length > 1) padding2 = s[1];
      if (s.length > 2) padding3 = s[2];
      if (s.length > 3) padding4 = s[3];
    }
  }

  // padding
  DoubleObservable? _padding1;
  set padding1(dynamic v)
  {
    if (_padding1 != null) _padding1!.set(v);
    else if (v != null) _padding1 = DoubleObservable(Binding.toKey(id, 'pad'), v, scope: scope, listener: onPropertyChange);
  }
  double? get padding1 => _padding1?.get();

  // padding 2
  DoubleObservable? _padding2;
  set padding2(dynamic v)
  {
    if (_padding2 != null) _padding2!.set(v);
    else if (v != null) _padding2 = DoubleObservable(Binding.toKey(id, 'pad2'), v, scope: scope, listener: onPropertyChange);
  }
  double? get padding2 => _padding2?.get();

  // padding 3
  DoubleObservable? _padding3;
  set padding3(dynamic v)
  {
    if (_padding3 != null) _padding3!.set(v);
    else if (v != null)
      _padding3 = DoubleObservable(Binding.toKey(id, 'pad3'), v, scope: scope, listener: onPropertyChange);
  }
  double? get padding3 => _padding3?.get();

  // padding 4
  DoubleObservable? _padding4;
  set padding4(dynamic v)
  {
    if (_padding4 != null) _padding4!.set(v);
    else if (v != null) _padding4 = DoubleObservable(Binding.toKey(id, 'pad4'), v, scope: scope, listener: onPropertyChange);
  }
  double? get padding4 => _padding4?.get();

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

  // is visible
  static bool isVisible(DecoratedWidgetModel? widget) {
    if (widget == null) return false;
    if (widget.visible == false) return false;
    if (widget.parent is DecoratedWidgetModel)
      return isVisible(widget.parent as DecoratedWidgetModel);
    return true;
  }

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

  ViewableWidgetModel(WidgetModel? parent, String? id, {Scope? scope}) : super(parent, id, scope: scope)
  {
    // create model constraints
    _constraints = ConstraintModel(this.id, this.scope, parent, onPropertyChange);
    constraints  = ConstraintSet(_constraints);
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {
    // deserialize
    super.deserialize(xml);

    // set constraints
    _constraints.width     = Xml.get(node: xml, tag: 'width');
    _constraints.height    = Xml.get(node: xml, tag: 'height');
    _constraints.minWidth  = Xml.get(node: xml, tag: 'minwidth');
    _constraints.maxWidth  = Xml.get(node: xml, tag: 'maxwidth');
    _constraints.minHeight = Xml.get(node: xml, tag: 'minheight');
    _constraints.maxHeight = Xml.get(node: xml, tag: 'maxheight');

    // properties
    visible   = Xml.get(node: xml, tag: 'visible');
    enabled   = Xml.get(node: xml, tag: 'enabled');
    halign    = Xml.get(node: xml, tag: 'halign');
    valign    = Xml.get(node: xml, tag: 'valign');
    flex      = Xml.get(node: xml, tag: 'flex');
    onscreen  = Xml.get(node: xml, tag: 'onscreen');
    offscreen = Xml.get(node: xml, tag: 'offscreen');

    // view sizing and position
    // these are treated differently for efficiency reasons
    // we only crteate the observvable if its bound to in the template
    // otherwise we just store the value in a simple double variable
    String? key;
    if (WidgetModel.isBound(this, key = Binding.toKey(id, 'viewwidth')))  _viewWidthObservable  = DoubleObservable(key, null, scope: scope);
    if (WidgetModel.isBound(this, key = Binding.toKey(id, 'viewheight'))) _viewHeightObservable = DoubleObservable(key, null, scope: scope);
    if (WidgetModel.isBound(this, key = Binding.toKey(id, 'viewx')))      _viewXObservable      = DoubleObservable(key, null, scope: scope);
    if (WidgetModel.isBound(this, key = Binding.toKey(id, 'viewy')))      _viewYObservable      = DoubleObservable(key, null, scope: scope);
    
    // view requires a VisibilityDetector if either onstage or offstage is set or
    // someone is bound to my visibility
    _addVisibilityDetector = visible != false ||
        !S.isNullOrEmpty(onscreen) ||
        !S.isNullOrEmpty(offscreen) ||
        WidgetModel.isBound(this, Binding.toKey(id, 'visiblearea')) ||
        WidgetModel.isBound(this, Binding.toKey(id, 'visibleheight')) ||
        WidgetModel.isBound(this, Binding.toKey(id, 'visiblewidth'));

    // set padding. can be comma seperated top,left,bottom,right
    var padding = Xml.attribute(node: xml, tag: 'pad');
    if (padding == null) padding  = Xml.attribute(node: xml, tag: 'padding');
    this.padding = padding;

    // tip
    List<TooltipModel> tips = findChildrenOfExactType(TooltipModel).cast<TooltipModel>();
    if (tips.isNotEmpty)
    {
      tipModel = tips.first;
      removeChildrenOfExactType(TooltipModel);
    }

    // add animations
    children?.forEach((child)
    {
      if (child is AnimationModel)
      {
        if (animations == null) animations = [];
        animations!.add(child);
      }
    });

    // remove animations from child list
    if (animations != null) children?.removeWhere((element) => animations!.contains(element));
  }

  static double getParentVPadding(int paddings, double? padding,
      double padding2, double padding3, double padding4) {
    double insets = 0.0;
    if (paddings > 0) {
      // pad all
      if (paddings == 1)
        insets = (padding ?? 0) * 2;

      // pad directions v,h
      else if (paddings == 2)
        insets = (padding ?? 0) * 2;

      // pad sides top, right, bottom, left
      else if (paddings > 2) insets = (padding ?? 0) + padding3;
    }
    //should add up all of the padded siblings to do this so you can have multiple padded siblings unconstrained.
    return insets;
  }

  AnimationModel? getAnimationModel(String id)
  {
    if (animations == null) return null;
    var models = animations!.where((model) => model.id == id);
    return (models.isNotEmpty) ? models.first : null;
  }

  @override
  Future<bool?> execute(String caller, String propertyOrFunction, List<dynamic> arguments) async
  {
    /// setter
    if (scope == null) return null;
    var function = propertyOrFunction.toLowerCase().trim();

    switch (function)
    {
      case "animate":
        if (animations != null)
        {
          var id = S.item(arguments, 0);
          AnimationModel? animation;
          if (!S.isNullOrEmpty(id))
          {
            var list = animations!.where((animation) => animation.id == id);
            if (list.isNotEmpty) animation = list.first;
          }
          else animation = animations!.first;
          animation?.execute(caller, propertyOrFunction, arguments);
        }
        return true;
    }
    return super.execute(caller, propertyOrFunction, arguments);
  }

  // set visibility
  double oldVisibility = 0;
  bool hasGoneOffscreen = false;
  bool hasGoneOnscreen = false;

  void onVisibilityChanged(VisibilityInfo info)
  {
    if (oldVisibility == (info.visibleFraction * 100)) return;

    visibleHeight = info.size.height > 0 ? ((info.visibleBounds.height / info.size.height) * 100) : 0.0;
    visibleWidth  = info.size.width  > 0 ? ((info.visibleBounds.width  / info.size.width)  * 100) : 0.0;
    visibleArea   = info.visibleFraction * 100;

    oldVisibility = visibleArea ?? 0.0;

    if (visibleArea! > 1 && !hasGoneOnscreen)
    {
      if (!S.isNullOrEmpty(_onscreen)) EventHandler(this).execute(_onscreen);
      hasGoneOnscreen = true;
    }
    else if (visibleArea! == 0 && hasGoneOnscreen)
    {
      if (!S.isNullOrEmpty(_offscreen)) EventHandler(this).execute(_offscreen);
      hasGoneOnscreen = false;
    }
  }

  @override
  void dispose()
  {
    // dispose of tip model
    tipModel?.dispose();

    // dispose of animations
    animations?.forEach((animation) => animation.dispose());
    super.dispose();
  }

  Widget getReactiveView(Widget view)
  {
    // wrap in visibility detector?
    if (needsVisibilityDetector) view = VisibilityDetector(key: ObjectKey(this), onVisibilityChanged: onVisibilityChanged, child: view);

    // wrap in tooltip?
    if (tipModel != null) view = TooltipView(tipModel!, view);

    // wrap animations. Only animate if visible and dimesions are greater than zero
    if (this.animations != null)
    {
      var animations = this.animations!.reversed;
      animations.forEach((model) => view = model.getAnimatedView(view));
    }
    return view;
  }

  List<Widget> inflate()
  {
    List<Widget> views = [];
    viewableChildren.forEach((model) => views.add(model.getView()));
    return views;
  }

  void setLayoutConstraints(BoxConstraints constraints) => _constraints.setLayoutConstraints(constraints);

  void onLayoutComplete(RenderBox? box, Offset? position)
  {
    viewWidth  = box?.size.width;
    viewHeight = box?.size.height;
    viewX      = position?.dx;
    viewY      = position?.dy;
  }

  Widget getView() => throw("getView() Not Implemented");
}

class ConstraintSet
{
  /// holds constraints defined in the template
  late final ConstraintModel _model;
  Constraints get model => _model.getModelConstraints();
  
  // holds constraints passed in flutter layout builder
  Constraints get system => _model.system;

  /// constraints calculated by walking up the
  /// model tree comparing both model and flutter constraints
  Constraints calculate() => _model.calculate();

  ConstraintSet(ConstraintModel model)
  {
    _model = model;
  }
}


