// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/decorated_widget_model.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/stack/stack_view.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class StackModel extends DecoratedWidgetModel implements IViewableWidget
{
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

  /// Expand, which is true by default, tells the widget if it should shrink to its children, or grow to its parents constraints. Width/Height attributes will override expand.
  BooleanObservable? _expand;
  set expand(dynamic v) {
    if (_expand != null) {
      _expand!.set(v);
    } else if (v != null) {
      _expand = BooleanObservable(Binding.toKey(id, 'expand'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  bool get expand => _expand?.get() ?? true;

  StackModel(
    WidgetModel parent,
    String? id, {
    dynamic width,
    dynamic height,
    dynamic minwidth,
    dynamic minheight,
    dynamic maxwidth,
    dynamic maxheight,
    dynamic valign,
    dynamic halign,
    dynamic expand,
    dynamic center,
  }) : super(parent, id)
  {
    // constraints
    if (width     != null) this.width     = width;
    if (height    != null) this.height    = height;
    if (minwidth  != null) this.minWidth  = minwidth;
    if (minheight != null) this.minHeight = minheight;
    if (maxwidth  != null) this.maxWidth  = maxwidth;
    if (maxheight != null) this.maxHeight = maxheight;

    this.halign = halign;
    this.valign = valign;
    this.center = center;
    this.expand = expand;
  }

  static StackModel? fromXml(WidgetModel parent, XmlElement xml) {
    StackModel? model;
    try {
// build model
      model = StackModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch(e) {
      Log().exception(e,
           caller: 'stack.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {
    // deserialize
    super.deserialize(xml);

    /// Attributes
    ///
    /// Constraint Attributes
    /// Layout Attributes
    center = Xml.get(node: xml, tag: 'center');

    // expand="false" is same as adding attribute shrink
    var expand = Xml.get(node: xml, tag: 'expand');
    if (expand == null && Xml.hasAttribute(node: xml, tag: 'shrink')) expand = 'false';
    this.expand = expand;

    ////////////////////////////
    /* Sort Children by Depth */
    ////////////////////////////
    if (children != null) children?.sort((a, b)
    {
      if(a.depth != null && b.depth != null) return a.depth?.compareTo(b.depth!) ?? 0;
      return 0;
    }
    );
  }

  @override
  dispose() {
// Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  Widget getView({Key? key}) => getReactiveView(StackView(this));
}
