// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/decorated_widget_model.dart';

import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/event/handler.dart' ;
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/popover/popover_view.dart';
import 'package:fml/widgets/popover/item/popover_item_model.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/helper_barrel.dart';

class PopoverModel extends DecoratedWidgetModel implements IViewableWidget, IModelListener
{
  List<PopoverItemModel> items = [];

  ///////////
  /* label */
  ///////////
  StringObservable? _label;
  set label (dynamic v)
  {
    if (_label != null)
    {
      _label!.set(v);
    }
    else if (v != null)
    {
      _label = StringObservable(Binding.toKey(id, 'label'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get label
  {
    return _label?.get();
  }

  //////////
  /* icon */
  //////////
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


  PopoverModel(
    WidgetModel parent,
    String? id, {
      dynamic enabled,
      dynamic color,
      dynamic label,
      dynamic icon,
    }
  ) : super(parent, id) {
    this.enabled = enabled;
    this.color = color;
    this.label = label;
    this.icon = icon;
  }

  static PopoverModel? fromXml(WidgetModel parent, XmlElement xml, {String? type}) {
    PopoverModel? model;
    try {
      model = PopoverModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch(e) {
      Log().debug(e.toString());
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
    enabled = Xml.get(node: xml, tag: 'enabled');
    label   = Xml.get(node: xml, tag: 'label');
    icon    = Xml.get(node: xml, tag: 'icon');

    /////////////////
    /* Build Items */
    /////////////////
    Iterable<XmlElement> nodes = xml.findElements("ITEM", namespace: "*");
      for (XmlElement node in nodes) {
        var item = PopoverItemModel.fromXml(this, node);
        if (item != null) {
          item.registerListener(this);
          this.items.add(item);
        }
      }
  }

  @override
  dispose() {
    Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  Future<bool> onClick(BuildContext context, Observable onclick) async
  {
    // maybe requires fix
    return await EventHandler(this).execute(onclick);
  }

  onModelChange(WidgetModel model, {String? property, value}) {
    // TODO missing setState?
    onPropertyChange(StringObservable(null, null)); // Allow us to rebuild the child model when it changes
  }

  Widget getView({Key? key}) => PopoverView(this);
}
