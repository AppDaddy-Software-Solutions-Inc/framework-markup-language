// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/event/handler.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/animation/animation_model.dart';
import 'package:fml/widgets/layout/ilayout.dart';
import 'package:fml/widgets/layout/layout_model.dart';
import 'package:fml/widgets/tooltip/v2/tooltip_model.dart';
import 'package:fml/widgets/tooltip/v2/tooltip_view.dart';
import 'package:fml/widgets/constraints/constraint.dart';
import 'package:fml/widgets/constraints/constraint_model.dart';
import 'package:fml/widgets/decorated/decorated_widget_model.dart';
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

  double get calculatedMinHeight => _constraints.calculatedMinHeight;
  double get calculatedMaxHeight => _constraints.calculatedMaxHeight;
  double get calculatedMaxHeightOrDefault
  {
    var v = calculatedMaxHeight;
    if (v == double.infinity) v = System().screenheight.toDouble();
    return v;
  }

  double get calculatedMinWidth => _constraints.calculatedMinWidth;
  double get calculatedMaxWidth => _constraints.calculatedMaxWidth;
  double get calculatedMaxWidthOrDefault => _constraints.calculatedMaxWidthOrDefault;

  setWidth(double? v, {bool notify = false}) => _constraints.setWidth(v, notify: notify);
  setHeight(double? v, {bool notify = false}) => _constraints.setHeight(v, notify: notify);

  @override
  double get verticalPadding  => (marginTop ?? 0)  + (marginBottom ?? 0);

  @override
  double get horizontalPadding => (marginLeft ?? 0) + (marginRight  ?? 0);

  bool get verticallyConstrained
  {
    if (constraints.model.hasVerticalExpansionConstraints)  return true;
    if (constraints.system.hasVerticalExpansionConstraints) return true;
    if (parent is ViewableWidgetModel) return (parent as ViewableWidgetModel).verticallyConstrained;
    return false;
  }

  bool get horizontallyConstrained
  {
    if (constraints.model.hasHorizontalExpansionConstraints)  return true;
    if (constraints.system.hasHorizontalExpansionConstraints) return true;
    if (parent is ViewableWidgetModel) return (parent as ViewableWidgetModel).horizontallyConstrained;
    return false;
  }

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
  bool fixedWidth = false;
  double? get width  => _constraints.width;
  set width(dynamic v) => _constraints.width = v;

  // height
  bool fixedHeight = false;
  double? get height => _constraints.height;
  set height(dynamic v) => _constraints.height = v;

  // min width
  @protected
  set minWidth(dynamic v) => _constraints.minWidth = v;

  // max width
  @protected
  set maxWidth(dynamic v) => _constraints.maxWidth = v;
  double? get maxWidth => _constraints.maxWidth;

  // min height
  @protected
  set minHeight(dynamic v) => _constraints.minHeight = v;
  double? get minHeight => _constraints.minHeight;

  // max height
  @protected
  set maxHeight(dynamic v) => _constraints.maxHeight = v;
  double? get maxHeight => _constraints.maxHeight;

  /// VIEW LAYOUT
  // this tells the layout builder that the widget is variable width
  bool get isVariableWidth
  {
    if (fixedWidth) return false;
    if (pctWidth != null) return true;
    if (parent is ILayout && (parent as ILayout).expandsHorizontally && _flex?.get() != null) return true;
    return false;
  }

  // this tells the layout builder that the widget is variable height
  bool get isVariableHeight
  {
    if (fixedHeight) return false;
    if (pctHeight != null) return true;
    if (parent is ILayout && (parent as ILayout).expandsVertically && _flex?.get() != null) return true;
    return false;
  }

  // %width
  double? get pctWidth => _constraints.widthPercentage;

  // %height
  double? get pctHeight => _constraints.heightPercentage;

  // view width
  double? _viewWidth;
  DoubleObservable? viewWidthObservable;
  set viewWidth(double? v)
  {
    // important this gets before the observable
    _viewWidth = v;

    // we handle this slightly different for performance reasons
    // The observable is only created in deserialize if its bound
    if (viewWidthObservable != null) viewWidthObservable!.set(v);
  }
  double? get viewWidth => _viewWidth;

  // view height
  double? _viewHeight;
  DoubleObservable? viewHeightObservable;
  set viewHeight(double? v)
  {
    // important this gets before the observable
    _viewHeight = v;

    // we handle this slightly different for performance reasons
    // The observable is only created in deserialize if its bound
    if (viewHeightObservable != null) viewHeightObservable!.set(v);
  }
  double? get viewHeight => _viewHeight;

  // view global X position
  double? _viewX;
  DoubleObservable? _viewXObservable;
  set viewX(double? v)
  {
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
  set viewY(double? v)
  {
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

  int? get flexWidth
  {
    // parent must be a row, column or box or stack
    if (this.parent is! LayoutModel || fixedWidth) return null;

    var parent = (this.parent as LayoutModel);

    // we can flex only if the parent expands in the horizontal axis
    if (parent.expandsHorizontally) return _flex?.get() ?? (parent.expand ? 1 : null);

    return null;
  }

  int? get flexHeight
  {
    // parent must be a row, column or box or stack
    if (this.parent is! LayoutModel || fixedHeight) return null;

    var parent = (this.parent as LayoutModel);

    // we can flex only if the parent expands in the vertical axis
    if (parent.expandsVertically) return _flex?.get() ?? (parent.expand ? 1 : null);

    return null;
  }

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

  set margins(dynamic v)
  {
    // build PADDINGS array
    if (v is String)
    {
      var s = v.split(',');

      // all
      if (s.length == 1)
      {
        marginTop=s[0];
        marginRight=s[0];
        marginBottom=s[0];
        marginLeft=s[0];
      }

      // top/bottom
      else if (s.length == 2)
      {
        marginTop=s[0];
        marginRight=s[1];
        marginBottom=s[0];
        marginLeft=s[1];
      }

      // top/bottom
      else if (s.length == 3)
      {
        marginTop=s[0];
        marginRight=s[1];
        marginBottom=s[2];
        marginLeft=null;
      }

      // top/bottom
      else if (s.length > 3)
      {
        marginTop=s[0];
        marginRight=s[1];
        marginBottom=s[2];
        marginLeft=s[3];
      }
    }
  }

  // margins top
  DoubleObservable? _marginTop;
  set marginTop(dynamic v)
  {
    if (_marginTop != null) _marginTop!.set(v);
    else if (v != null) _marginTop = DoubleObservable(Binding.toKey(id, 'margintop'), v, scope: scope, listener: onPropertyChange);
  }
  double? get marginTop => _marginTop?.get();

  // margins right
  DoubleObservable? _marginRight;
  set marginRight(dynamic v)
  {
    if (_marginRight != null) _marginRight!.set(v);
    else if (v != null) _marginRight = DoubleObservable(Binding.toKey(id, 'marginright'), v, scope: scope, listener: onPropertyChange);
  }
  double? get marginRight => _marginRight?.get();

  // margins bottom
  DoubleObservable? _marginBottom;
  set marginBottom(dynamic v)
  {
    if (_marginBottom != null) _marginBottom!.set(v);
    else if (v != null)
      _marginBottom = DoubleObservable(Binding.toKey(id, 'marginbottom'), v, scope: scope, listener: onPropertyChange);
  }
  double? get marginBottom => _marginBottom?.get();

  // margins left
  DoubleObservable? _marginLeft;
  set marginLeft(dynamic v)
  {
    if (_marginLeft != null) _marginLeft!.set(v);
    else if (v != null) _marginLeft = DoubleObservable(Binding.toKey(id, 'marginleft'), v, scope: scope, listener: onPropertyChange);
  }
  double? get marginLeft => _marginLeft?.get();

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
    fixedWidth = _constraints.width != null;

    _constraints.height    = Xml.get(node: xml, tag: 'height');
    fixedHeight = _constraints.height != null;

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
    // we only create the observable if its bound to in the template
    // otherwise we just store the value in a simple double variable
    String? key;
    if (WidgetModel.isBound(this, key = Binding.toKey(id, 'viewwidth')))  viewWidthObservable  = DoubleObservable(key, null, scope: scope);
    if (WidgetModel.isBound(this, key = Binding.toKey(id, 'viewheight'))) viewHeightObservable = DoubleObservable(key, null, scope: scope);
    if (WidgetModel.isBound(this, key = Binding.toKey(id, 'viewx')))      _viewXObservable      = DoubleObservable(key, null, scope: scope);
    if (WidgetModel.isBound(this, key = Binding.toKey(id, 'viewy')))      _viewYObservable      = DoubleObservable(key, null, scope: scope);
    
    // view requires a VisibilityDetector if either onstage or offstage is set or
    // someone is bound to my visibility
    _addVisibilityDetector = visible && (!S.isNullOrEmpty(onscreen) || !S.isNullOrEmpty(offscreen) || WidgetModel.isBound(this, Binding.toKey(id, 'visiblearea')) || WidgetModel.isBound(this, Binding.toKey(id, 'visibleheight')) || WidgetModel.isBound(this, Binding.toKey(id, 'visiblewidth')));

    // set margins. Can be comma separated top,left,bottom,right
    var margins = Xml.attribute(node: xml, tag: 'margin') ?? Xml.attribute(node: xml, tag: 'margins');
    this.margins = margins;

    // legacy support.
    // Use margins when referring to space around the outside of the widget.
    // Use padding when referring to space around the contents of inside of the widget.
    var padding = Xml.attribute(node: xml, tag: 'pad') ?? Xml.attribute(node: xml, tag: 'padding') ?? Xml.attribute(node: xml, tag: 'padd');
    if (margins == null && padding != null) this.margins = padding;

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

    // wrap animations.
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

  void onLayoutComplete() async
  {
    if (this.context == null) return;

    var box = context!.findRenderObject() as RenderBox?;
    if (box == null) return;

    var position = box.localToGlobal(Offset.zero);
    var size = box.size;

    if (size.width != viewWidth || size.height != viewHeight || position.dx != viewX || position.dy != viewY)
    {
      viewWidth  = size.width;
      viewHeight = size.height;
      viewX      = position.dx;
      viewY      = position.dy;
      if (parent is ViewableWidgetModel) (parent as ViewableWidgetModel).onLayoutComplete();
    }
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
  Constraints get calculated => _model.calculated;

  Constraints get tightest => Constraints.tightest(Constraints.tightest(model, system), calculated);
  Constraints get tightestOrDefault
  {
    var constraints = tightest;
    if (constraints.height == null && constraints.maxHeight == null) constraints.maxHeight = System().screenheight.toDouble();
    if (constraints.width  == null && constraints.maxWidth  == null) constraints.maxWidth  = System().screenwidth.toDouble();
    return constraints;
  }

  ConstraintSet(this._model);
}


