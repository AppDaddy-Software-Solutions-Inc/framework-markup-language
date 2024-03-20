// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/decorated/decorated_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/widgets/positioned/positioned_view.dart';
import 'package:fml/helpers/helpers.dart';

class PositionedModel extends DecoratedWidgetModel {
  // left
  // bool _leftIsPercent = false;
  DoubleObservable? _left;
  set left(dynamic v) {
    if (_left != null) {
      _left!.set(v);
    } else if (v != null) {
      if (isPercent(v)) {
        // _leftIsPercent = true;
        v = v.split("%")[0];
      }
      _left = DoubleObservable(Binding.toKey(id, 'left'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double? get left => _left?.get();

  // right
  // bool _rightIsPercent = false;
  DoubleObservable? _right;
  set right(dynamic v) {
    if (_right != null) {
      _right!.set(v);
    } else if (v != null) {
      if (isPercent(v)) {
        // _rightIsPercent = true;
        v = v.split("%")[0];
      }
      _right = DoubleObservable(Binding.toKey(id, 'right'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double? get right => _right?.get();

  // top
  // bool _topIsPercent = false;
  DoubleObservable? _top;
  set top(dynamic v) {
    if (_top != null) {
      _top!.set(v);
    } else if (v != null) {
      if (isPercent(v)) {
        // _topIsPercent = true;
        v = v.split("%")[0];
      }
      _top = DoubleObservable(Binding.toKey(id, 'top'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double? get top => _top?.get();

  // bottom
  // bool _bottomIsPercent = false;
  DoubleObservable? _bottom;
  set bottom(dynamic v) {
    if (_bottom != null) {
      _bottom!.set(v);
    } else if (v != null) {
      if (isPercent(v)) {
        // _bottomIsPercent = true;
        v = v.split("%")[0];
      }
      _bottom = DoubleObservable(Binding.toKey(id, 'bottom'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double? get bottom => _bottom?.get();

  // horizontal center
  DoubleObservable? _xoffset;
  set xoffset(dynamic v) {
    if (_xoffset != null) {
      _xoffset!.set(v);
    } else if (v != null) {
      _xoffset = DoubleObservable(Binding.toKey(id, 'xoffset'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double? get xoffset => _xoffset?.get();

  // vertical center
  DoubleObservable? _yoffset;
  set yoffset(dynamic v) {
    if (_yoffset != null) {
      _yoffset!.set(v);
    } else if (v != null) {
      _yoffset = DoubleObservable(Binding.toKey(id, 'yoffset'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double? get yoffset => _yoffset?.get();

  // depth
  DoubleObservable? _depth;
  @override
  set depth(dynamic v) {
    if (_depth != null) {
      _depth!.set(v);
    } else if (v != null) {
      _depth = DoubleObservable(Binding.toKey(id, 'depth'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  @override
  double get depth => _depth?.get() ?? 1.0;

  PositionedModel(WidgetModel super.parent, super.id,
      {dynamic left,
      dynamic right,
      dynamic top,
      dynamic bottom,
      dynamic xoffset,
      dynamic yoffset,
      dynamic depth,
      super.scope}) {
    this.top = top;
    this.bottom = bottom;
    this.left = left;
    this.right = right;
    this.xoffset = xoffset;
    this.yoffset = yoffset;
    this.depth = depth;
  }

  static PositionedModel? fromXml(WidgetModel parent, XmlElement xml) {
    PositionedModel? model;
    try {
      // build model
      model = PositionedModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'positioned.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {
    // deserialize
    super.deserialize(xml);

    // properties
    left = Xml.get(node: xml, tag: 'left');
    right = Xml.get(node: xml, tag: 'right');
    top = Xml.get(node: xml, tag: 'top');
    bottom = Xml.get(node: xml, tag: 'bottom');
    xoffset = Xml.get(node: xml, tag: 'xoffset'); // formally hcenter
    yoffset = Xml.get(node: xml, tag: 'yoffset'); // formally vcenter
    depth = Xml.get(node: xml, tag: 'depth');
  }

  @override
  Widget getView({Key? key}) => getReactiveView(PositionedView(this));
}
