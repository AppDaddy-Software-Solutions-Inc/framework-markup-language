import 'package:flutter/material.dart';
import 'package:fml/helper/alignment.dart';
import 'package:fml/helper/xml.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/observable/observables/boolean.dart';
import 'package:fml/observable/observables/string.dart';
import 'package:fml/observable/scope.dart';
import 'package:fml/widgets/widget/decorated_widget_model.dart';
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
}
