// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class PopoverItemModel extends WidgetModel {
  ///////////
  /* label */
  ///////////
  StringObservable? _label;
  set label(dynamic v) {
    if (_label != null) {
      _label!.set(v);
    } else if (v != null) {
      _label = StringObservable(Binding.toKey(id, 'label'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String? get label => _label?.get();

  /////////////
  /* onclick */
  /////////////

  StringObservable? get onclickObservable => _onclick;
  StringObservable? _onclick;
  set onclick(dynamic v) {
    if (_onclick != null) {
      _onclick!.set(v);
    } else if (v != null) {
      _onclick = StringObservable(Binding.toKey(id, 'onclick'), v,
          scope: scope, listener: onPropertyChange, lazyEval: true);
    }
  }

  String? get onclick {
    return _onclick?.get();
  }

  //////////
  /* icon */
  //////////
  // Attribute not implemented
  IconObservable? _icon;
  set icon(dynamic v) {
    if (_icon != null) {
      _icon!.set(v);
    } else if (v != null) {
      _icon = IconObservable(Binding.toKey(id, 'icon'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  IconData? get icon => _icon?.get();

  PopoverItemModel(
    WidgetModel parent,
    String? id, {
    dynamic label,
    dynamic onclick,
  }) : super(parent, id) {
    this.label = label;
    this.onclick = onclick;
  }

  static PopoverItemModel? fromXml(WidgetModel parent, XmlElement xml) {
    PopoverItemModel? model;
    try {
      model = PopoverItemModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch(e) {
      Log().debug(e.toString());
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
    label = Xml.get(node: xml, tag: 'label');
    onclick = Xml.get(node: xml, tag: 'onclick');
  }

  @override
  dispose() {
// Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }
}
