// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/viewable/viewable_widget_model.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/widgets/treeview/tree_model.dart';
import 'package:fml/widgets/treeview/node/tree_node_view.dart';
import 'package:fml/event/handler.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

class TreeNodeModel extends ViewableWidgetModel {
  TreeModel? treeview;

  /////////////
  /* onclick */
  /////////////
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
  /* Icon */
  //////////
  IconObservable? _icon;
  set icon(dynamic v) {
    if (_icon != null) {
      _icon!.set(v);
    } else if (v != null) {
      _icon = IconObservable(Binding.toKey(id, 'icon'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  IconData? get icon => _icon?.get() ?? treeview?.icon;

  ///////////////////
  /* expanded icon */
  ///////////////////
  IconObservable? _expandedicon;
  set expandedicon(dynamic v) {
    if (_expandedicon != null) {
      _expandedicon!.set(v);
    } else if (v != null) {
      _expandedicon = IconObservable(Binding.toKey(id, 'icon'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  IconData? get expandedicon => _expandedicon?.get() ?? treeview?.expandedicon;

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

  String get label => _label?.get() ?? "No Label";

  //////////////
  /* expanded */
  //////////////
  BooleanObservable? _expanded;
  set expanded(dynamic v) {
    if (_expanded != null) {
      _expanded!.set(v);
    } else if (v != null) {
      _expanded = BooleanObservable(Binding.toKey(id, 'expanded'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool? get expanded => _expanded?.get();

  //////////////
  /* selected */
  //////////////
  BooleanObservable? _selected;
  set selected(dynamic v) {
    if (_selected != null) {
      _selected!.set(v);
    } else if (v != null) {
      _selected = BooleanObservable(Binding.toKey(id, 'selected'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool? get selected => _selected?.get();

  TreeNodeModel(Model super.parent, super.id);

  static TreeNodeModel? fromXml(Model parent, XmlElement xml) {
    TreeNodeModel? model;
    try {
      model = TreeNodeModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'menu.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {
    // deserialize
    super.deserialize(xml);

    // Set treeview
    treeview = findAncestorOfExactType(TreeModel);

    // properties
    icon = Xml.get(node: xml, tag: 'icon');
    expandedicon = Xml.get(node: xml, tag: 'expandedicon');
    label = Xml.get(node: xml, tag: 'label');
    expanded = Xml.get(node: xml, tag: 'expanded') ?? false;
    onclick = Xml.get(node: xml, tag: 'onclick');
    selected = Xml.get(node: xml, tag: 'selected') ?? false;
  }

  Future<bool> onClick(BuildContext context) async {
    if (onclick == null) return true;
    return await EventHandler(this).execute(_onclick);
  }

  @override
  Widget getView({Key? key}) => getReactiveView(TreeNodeView(this));
}
