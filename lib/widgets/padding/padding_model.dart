// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/viewable_widget_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/padding/padding_view.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class PaddingModel extends ViewableWidgetModel implements IViewableWidget
{
  //////////
  /* all */
  //////////
  DoubleObservable? _all;
  set all(dynamic v) {
    if (_all != null) {
      _all!.set(v);
    } else if (v != null) {
      _all = DoubleObservable(Binding.toKey(id, 'all'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double? get all => _all?.get();

  //////////
  /* left */
  //////////
  DoubleObservable? _left;
  set left(dynamic v) {
    if (_left != null) {
      _left!.set(v);
    } else if (v != null) {
      _left = DoubleObservable(Binding.toKey(id, 'left'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double? get left => _left?.get();

  ///////////
  /* right */
  ///////////
  DoubleObservable? _right;
  set right(dynamic v) {
    if (_right != null) {
      _right!.set(v);
    } else if (v != null) {
      _right = DoubleObservable(Binding.toKey(id, 'right'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double? get right => _right?.get();

  /////////
  /* top */
  /////////
  DoubleObservable? _top;
  set top(dynamic v) {
    if (_top != null) {
      _top!.set(v);
    } else if (v != null) {
      _top = DoubleObservable(Binding.toKey(id, 'top'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double? get top => _top?.get();

  ////////////
  /* bottom */
  ////////////
  DoubleObservable? _bottom;
  set bottom(dynamic v) {
    if (_bottom != null) {
      _bottom!.set(v);
    } else if (v != null) {
      _bottom = DoubleObservable(Binding.toKey(id, 'bottom'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double? get bottom => _bottom?.get();

  ///////////
  /* vertical */
  ///////////
  DoubleObservable? _vertical;
  set vertical(dynamic v) {
    if (_vertical != null) {
      _vertical!.set(v);
    } else if (v != null) {
      _vertical = DoubleObservable(Binding.toKey(id, 'vertical'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double? get vertical => _vertical?.get();

  ///////////
  /* horizontal */
  ///////////
  DoubleObservable? _horizontal;
  set horizontal(dynamic v) {
    if (_horizontal != null) {
      _horizontal!.set(v);
    } else if (v != null) {
      _horizontal = DoubleObservable(
          Binding.toKey(id, 'horizontal'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double? get horizontal => _horizontal?.get();

  PaddingModel(WidgetModel parent, String? id,
      {dynamic all,
      dynamic left,
      dynamic right,
      dynamic top,
      dynamic bottom,
      dynamic vertical,
      dynamic horizontal,
      Scope? scope})
      : super(parent, id, scope: scope) {
    this.all = all;
    if (all == null) {
      this.top = top;
      this.bottom = bottom;
      this.left = left;
      this.right = right;
      this.horizontal = horizontal;
      this.vertical = vertical;
    }
  }

  static PaddingModel? fromXml(WidgetModel parent, XmlElement xml) {
    PaddingModel? model;
    try {
      /////////////////
      /* Build Model */
      /////////////////
      model = PaddingModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch(e) {
      Log().exception(e,
           caller: 'padding.Model');
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

    // properties
    all = Xml.get(node: xml, tag: 'all');
    if (all == null) {
      left = Xml.get(node: xml, tag: 'left');
      right = Xml.get(node: xml, tag: 'right');
      top = Xml.get(node: xml, tag: 'top');
      bottom = Xml.get(node: xml, tag: 'bottom');
      horizontal = Xml.get(node: xml, tag: 'horizontal') ?? Xml.get(node: xml, tag: 'hor');
      vertical = Xml.get(node: xml, tag: 'vertical') ?? Xml.get(node: xml, tag: 'ver');
    }
  }

  @override
  dispose() {
// Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  Widget getView({Key? key}) => getReactiveView(PaddingView(this));
}
