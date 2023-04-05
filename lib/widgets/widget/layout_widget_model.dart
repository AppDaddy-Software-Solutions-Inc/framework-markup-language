import 'package:flutter/material.dart';
import 'package:fml/helper/alignment.dart';
import 'package:fml/helper/common_helpers.dart';
import 'package:fml/helper/xml.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/observable/observable.dart';
import 'package:fml/observable/observables/boolean.dart';
import 'package:fml/observable/observables/double.dart';
import 'package:fml/observable/observables/integer.dart';
import 'package:fml/observable/observables/string.dart';
import 'package:fml/observable/scope.dart';
import 'package:fml/widgets/widget/decorated_widget_model.dart';
import 'package:fml/widgets/widget/viewable_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:xml/xml.dart';

class LayoutWidgetModel extends DecoratedWidgetModel
{
  // override this routine in the outer model
  bool isVerticallyConstrained() => true;

  // override this routine in the outer model
  bool isHorizontallyConstrained() => true;

  // override this routine in the outer model
  MainAxisSize getVerticalAxisSize() => MainAxisSize.min;

  // override this routine in the outer model
  MainAxisSize getHorizontalAxisSize() => MainAxisSize.min;

  // children with variable width
  List<ViewableWidgetModel> get variableWidthChildren => viewableChildren.where((child) => child.flex != null || child.pctWidth != null).toList();

  // children with variable height
  List<ViewableWidgetModel> get variableHeightChildren => viewableChildren.where((child) => child.flex != null || child.pctHeight != null).toList();

  // children with fixed width
  List<ViewableWidgetModel> get fixedWidthChildren => viewableChildren.where((child) => child.flex == null && child.pctWidth == null).toList();

  // children with fixed height
  List<ViewableWidgetModel> get fixedHeightChildren => viewableChildren.where((child) => child.flex == null && child.pctHeight == null).toList();

  /// Center attribute allows a simple boolean override for halign and valign both being center. halign and valign will override center if given.
  BooleanObservable? _center;
  set center(dynamic v) {
    if (_center != null) {
      _center!.set(v);
    } else if (v != null) {
      _center = BooleanObservable(Binding.toKey(id, 'center'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  bool get center => _center?.get() ?? false;

  /// Layout determines the widgets childrens layout. Can be `row`, `column`, `col`, or `stack`. Defaulted to `column`. If set to `stack` it can take `POSITIONED` as a child.
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

  /// wrap determines the widget, if layout is row or col, how it will wrap.
  BooleanObservable? _wrap;
  set wrap(dynamic v) {
    if (_wrap != null) {
      _wrap!.set(v);
    } else if (v != null) {
      _wrap = BooleanObservable(Binding.toKey(id, 'wrap'), v,
          scope: scope, listener: onPropertyChange);
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

  LayoutWidgetModel(
      WidgetModel? parent,
      String? id, {
        Scope?  scope,
        dynamic layout,
        dynamic expand,
        dynamic center,
        dynamic wrap,
      }) : super(parent, id, scope: scope)
  {
    if (center != null) this.center = center;
    if (layout != null) this.layout = layout;
    if (expand != null) this.expand = expand;
    if (wrap != null) this.wrap = wrap;
  }

  static LayoutWidgetModel? fromXml(WidgetModel parent, XmlElement xml, {String? type})
  {
    LayoutWidgetModel? model;
    try {
      model = LayoutWidgetModel(parent, Xml.get(node: xml, tag: 'id'));
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

    /// Layout Attributes
    layout = Xml.get(node: xml, tag: 'layout');
    center = Xml.get(node: xml, tag: 'center');
    expand = Xml.get(node: xml, tag: 'expand');
    wrap   = Xml.get(node: xml, tag: 'wrap');

    // if stack, sort children by depth
    if (AlignmentHelper.getLayoutType(layout) == LayoutType.stack)
    if (children != null)
    {
      children?.sort((a, b)
      {
        if(a.depth != null && b.depth != null) return a.depth?.compareTo(b.depth!) ?? 0;
        return 0;
      });
    }
  }

  @override
  List<Widget> inflate()
  {
    var id = this.id;

    print("inflate() => model id=$id");

    var layout = AlignmentHelper.getLayoutType(this.layout);

    var variableChildren = this.variableWidthChildren;
    var fixedChildren = (layout == LayoutType.row) ? this.fixedWidthChildren : this.fixedHeightChildren;

    List<Widget> views = [];
    for (var child in viewableChildren)
    {
      var view = child.getView();

      // if we have variable size children (% or flex)
      // register listeners on fixed size children
      if (variableChildren.isNotEmpty && fixedChildren.contains(child))
      {
        switch (layout)
        {
          case LayoutType.row:
            if (child.viewWidthObservable == null) child.viewWidthObservable = IntegerObservable(Binding.toKey(child.id, 'viewwidth'), null, scope: child.scope);
            child.viewWidthObservable!.registerListener(onWidthChange);
            child.viewWidth = null;
            break;

          case LayoutType.column:
            if (child.viewHeightObservable == null) child.viewHeightObservable = IntegerObservable(Binding.toKey(child.id, 'viewheight'), null, scope: child.scope);
            child.viewHeightObservable!.registerListener(onHeightChange);
            child.viewHeight = 0;
            break;

          default:
            break;
        }
      }

      // add the view
      views.add(view);
    }

    return views;
  }

  @override
  void onLayoutComplete(RenderBox? box, Offset? position)
  {
    super.onLayoutComplete(box, position);

    var id = this.id;

    var layout = AlignmentHelper.getLayoutType(this.layout);
    var fixedChildren = (layout == LayoutType.row) ? this.fixedWidthChildren : this.fixedHeightChildren;
    if (fixedChildren.isEmpty)
    {
      switch (layout)
      {
        case LayoutType.row:
          onWidthChange(null);
          break;

        case LayoutType.column:
          onHeightChange(null);
          break;

        default:
          break;
      }
    }
  }

  void onWidthChange(_)
  {
    var id = this.id;

    // layout can be performed when all fixed sized children have been laid out
    var unsizedChildren = fixedWidthChildren.where((child) => child.viewWidth == null);
    if (unsizedChildren.isEmpty)
    {
      print("onWidthChange() => model id=$id");

      // calculate maximum space
      var maximum = width ?? calculateMaxWidth() ?? 0;

      var variableChildren = this.variableWidthChildren;
      var fixedChildren = this.fixedWidthChildren;

      // calculate fixed space
      double fixed = 0;
      for (var child in fixedChildren)
      {
        if (child.visible) fixed += (child.viewWidth ?? 0);
      };

      // calculate usable space (max - fixed)
      var usable = maximum - fixed;

      // set % sizing on variable children
      var free = usable;
      for (var child in variableChildren)
      {
        if (child.visible && child.pctWidth != null)
        {
          var size = (usable * (child.pctWidth!/100)).toPrecision(0);
          free = free - size;
          if (child.width != size)
          {
            child.setWidth(size, notify: true);
          }
        }
      };

      // calculate sum of all flex values
      double flexsum = 0;
      for (var child in variableChildren)
      {
        if (child.visible && child.pctWidth == null && child.flex != null && child.flex! > 0)
        {
          flexsum += child.flex!;
        }
      };

      // set flex sizing on flexible children
      for (var child in variableChildren)
      {
        // % takes priority over flexibility
        // and would have been laid out above
        if (child.visible && child.pctWidth == null && child.flex != null && child.flex! > 0)
        {
          var size = ((child.flex! / flexsum) * free).toPrecision(0);
          if (size < 0) size = 0;
          if (child.width != size)
          {
            child.setWidth(size, notify: true);
          }
        }
      };
    }
  }

  void onHeightChange(_)
  {
    var id = this.id;

    // layout can be performed when all fixed sized children have been laid out
    var unsizedChildren = fixedHeightChildren.where((child) => child.viewHeight == null);
    if (unsizedChildren.isEmpty)
    {
      print("onHeightChange() => model id=$id");

      // calculate maximum space
      var maximum = height ?? calculateMaxHeight() ?? 0;

      var variableChildren = this.variableHeightChildren;
      var fixedChildren = this.fixedHeightChildren;

      // calculate fixed space
      double fixed = 0;
      for (var child in fixedChildren)
      {
        if (child.visible) fixed += (child.viewHeight ?? 0);
      };

      // calculate usable space (max - fixed)
      var usable = maximum - fixed;

      // set % sizing on variable children
      var free = usable;
      for (var child in variableChildren)
      {
        if (child.visible && child.pctHeight != null)
        {
          var size = (usable * (child.pctHeight!/100)).toPrecision(0);
          free = free - size;
          if (child.height != size)
          {
            child.setHeight(size, notify: true);
          }
        }
      };

      // calculate sum of all flex values
      double flexsum = 0;
      for (var child in variableChildren)
      {
        if (child.visible && child.pctHeight == null && child.flex != null && child.flex! > 0)
        {
          flexsum += child.flex!;
        }
      };

      // set flex sizing on flexible children
      for (var child in variableChildren)
      {
        // % takes priority over flexibility
        // and would have been laid out above
        if (child.visible && child.pctHeight == null && child.flex != null && child.flex! > 0)
        {
          var size = ((child.flex! / flexsum) * free).toPrecision(0);
          if (size < 0) size = 0;
          if (child.height != size)
          {
            child.setHeight(size, notify: true);
          }
        }
      };
    }
  }
}
