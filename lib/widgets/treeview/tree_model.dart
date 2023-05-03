// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/event/event.dart';
import 'package:fml/log/manager.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/decorated/decorated_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/widgets/treeview/tree_view.dart';
import 'package:fml/widgets/treeview/node/tree_node_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class TreeModel extends DecoratedWidgetModel 
{
  // Icon
  IconObservable? _icon;
  set icon (dynamic v)
  {
    if (_icon != null)
    {
      _icon!.set(v);
    }
    else if (v != null)
    {
      _icon = IconObservable(Binding.toKey(id, 'icon'), v, scope: scope, listener: onPropertyChange);
    }
  }
  IconData? get icon => _icon?.get();

  // expanded icon
  IconObservable? _expandedicon;
  set expandedicon (dynamic v)
  {
    if (_expandedicon != null)
    {
      _expandedicon!.set(v);
    }
    else if (v != null)
    {
      _expandedicon = IconObservable(Binding.toKey(id, 'expandedicon'), v, scope: scope, listener: onPropertyChange);
    }
  }
  IconData? get expandedicon => _expandedicon?.get();

  TreeNodeModel? nodeTemplate;
  final List<TreeNodeModel> nodes = [];
  final List<TreeNodeModel?> youngestGeneration = [];

  TreeModel(WidgetModel parent, String?  id) : super(parent, id);

  static TreeModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    TreeModel? model;
    try
    {
      model = TreeModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e, caller: 'TreeModel');
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
    icon = Xml.get(node: xml, tag: 'icon');
    expandedicon = Xml.get(node: xml, tag: 'expandedicon');

    // Build Nodes and find the youngestGeneration

    // clear nodes
    for (var model in this.nodes) {
      model.dispose();
    }
    this.nodes.clear();

    for (var model in youngestGeneration) {
      model?.dispose();
    }
    youngestGeneration.clear();

    List<TreeNodeModel> nodes = findChildrenOfExactType(TreeNodeModel).cast<TreeNodeModel>();
    for (var node in nodes) {
     this.nodes.add(node);
     recurseChildren(node);
    }

    if ((datasource != null) && (this.nodes.isNotEmpty))
    {
      nodeTemplate = this.nodes.first;
      this.nodes.removeAt(0);
    }
  }

  @override
  dispose()
  {
    // Log().debug('dispose called on => <$elementName id="$id">');

    // clear nodes
    for (var model in nodes) {
      model.dispose();
    }
    nodes.clear();

    for (var model in youngestGeneration) {
      model?.dispose();
    }
    youngestGeneration.clear();

    super.dispose();
  }

  void focusTreeNode(TreeNodeModel? node)
  {
      for (TreeNodeModel? n in youngestGeneration)
      {
        if (node == null) {
          n!.selected = false;
        } else if (n!.id == node.id) {
          n.selected = true;
        } else {
          n.selected = false;
        }
      }
  }

  // show this node as focused
  void onFocus(Event event) async
  {
    // set focus
    if (event.parameters != null)
    {
      // key of model that opened the focsed tab
      String? key = event.parameters!.containsKey('key') ? event.parameters!['key'] : null;

      // node needs to be focused in the treeview?
      if (key != null)
      {
        // find node in model tree children
        TreeNodeModel? node = model.findDescendantOfExactType(TreeNodeModel, id: key);

        // found? set focus
        if (node != null)
        {
          event.handled = true;
          focusTreeNode(node);
        }
      }
    }

    // set empty focus if event wasnt handled
    if (!event.handled) focusTreeNode(null);
  }

  void recurseChildren(dynamic node) {
    for (dynamic n in node.children) {
      if (n.children != null && n.children.length > 0) {
        recurseChildren(n);
      } else {
        youngestGeneration.add(n);
      }
    }
  }

  @override
  Widget getView({Key? key}) => getReactiveView(TreeView(this));
}
