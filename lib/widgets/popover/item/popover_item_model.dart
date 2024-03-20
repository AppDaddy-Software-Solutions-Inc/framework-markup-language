// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/event/handler.dart';
import 'package:fml/log/manager.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/popover/popover_model.dart';
import 'package:fml/widgets/row/row_model.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

class PopoverItemModel extends RowModel {
  @override
  bool get expand => false;

  // label
  StringObservable? _label;
  set label(dynamic v) {
    if (_label != null) {
      _label!.set(v);
    } else if (v != null) {
      _label = StringObservable(Binding.toKey(id, 'label'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  // label will crash if null
  String get label => _label?.get() ?? "";

  // onclick
  StringObservable? _onclick;
  set onclick(dynamic v) {
    if (_onclick != null) {
      _onclick!.set(v);
    } else if (v != null) {
      _onclick = StringObservable(Binding.toKey(id, 'onclick'), v,
          scope: scope, listener: onPropertyChange, lazyEval: true);
    }
  }

  String? get onclick => _onclick?.get();

  // icon
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
    super.parent,
    super.id, {
    dynamic data,
    dynamic label,
    dynamic onclick,
  }) : super(scope: Scope(parent: parent.scope)) {
    this.data = data;
    this.label = label;
    this.onclick = onclick;
  }

  static PopoverItemModel? fromXml(WidgetModel parent, XmlElement xml,
      {dynamic data}) {
    PopoverItemModel? model;
    try {
      model =
          PopoverItemModel(parent, Xml.get(node: xml, tag: 'id'), data: data);
      model.deserialize(xml);
    } catch (e) {
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
    icon = Xml.get(node: xml, tag: 'icon');
    onclick = Xml.get(node: xml, tag: 'onclick');
  }

  Future<bool> onTap() async {
    if (parent is PopoverModel) {
      (parent as PopoverModel).onTap(this);
    }
    return await EventHandler(this).execute(_onclick);
  }
}
