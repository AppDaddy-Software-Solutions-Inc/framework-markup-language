// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/viewable/viewable_widget_model.dart';
import 'package:fml/widgets/widget/widget_model_interface.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/event/handler.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/popover/popover_view.dart';
import 'package:fml/widgets/popover/item/popover_item_model.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

class PopoverModel extends ViewableWidgetModel implements IModelListener {
  List<PopoverItemModel> items = [];

  // data sourced prototype
  XmlElement? prototype;

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

  String? get label {
    return _label?.get();
  }

  // icon
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

  PopoverModel(
    WidgetModel super.parent,
    super.id, {
    dynamic enabled,
    dynamic color,
    dynamic label,
    dynamic icon,
  }) {
    this.enabled = enabled;
    this.color = color;
    this.label = label;
    this.icon = icon;
  }

  static PopoverModel? fromXml(WidgetModel parent, XmlElement xml,
      {String? type}) {
    PopoverModel? model;
    try {
      model = PopoverModel(parent, Xml.get(node: xml, tag: 'id'));
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
    enabled = Xml.get(node: xml, tag: 'enabled');
    label = Xml.get(node: xml, tag: 'label');
    icon = Xml.get(node: xml, tag: 'icon');

    // clear items
    for (var item in items) {
      item.dispose();
    }
    items.clear();

    // build popover items
    _buildItems();
  }

  void _buildItems() {
    List<PopoverItemModel> items =
        findChildrenOfExactType(PopoverItemModel).cast<PopoverItemModel>();

    // build datasource popover items
    if (!isNullOrEmpty(datasource) && items.isNotEmpty) {
      prototype = prototypeOf(items.first.element);
      items.removeAt(0);
    }

    // add items
    this.items.addAll(items);
  }

  @override
  Future<bool> onDataSourceSuccess(IDataSource source, Data? list) async {
    busy = true;

    // build options
    if (list != null && prototype != null) {
      // clear items
      for (var item in items) {
        item.dispose();
      }
      items.clear();

      for (var row in list) {
        var model = PopoverItemModel.fromXml(this, prototype!, data: row);
        if (model != null) items.add(model);
      }

      notifyListeners('list', items);
    }

    busy = false;

    return true;
  }

  @override
  dispose() {
    // clear items
    for (var item in items) {
      item.dispose();
    }
    items.clear();

    super.dispose();
  }

  Future<bool> onClick(BuildContext context, Observable onclick) async {
    // maybe requires fix
    return await EventHandler(this).execute(onclick);
  }

  @override
  onModelChange(WidgetModel model, {String? property, value}) {
    // TODO missing setState?
    onPropertyChange(StringObservable(
        null, null)); // Allow us to rebuild the child model when it changes
  }

  Future<bool> onTap(PopoverItemModel? model) async {
    data = model?.data ?? Data();
    return true;
  }

  @override
  Widget getView({Key? key}) => getReactiveView(PopoverView(this));
}
