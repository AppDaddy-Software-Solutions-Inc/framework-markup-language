// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/viewable/viewable_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:pluto_grid_export/pluto_grid_export.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/row/row_model.dart';
import 'package:fml/widgets/text/text_model.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class OptionModel extends ViewableWidgetModel
{
  // label
  ViewableWidgetModel? label;

  dynamic labelValue;

  // value
  dynamic _value;
  set value (dynamic v)
  {
         if (_value is StringObservable) {
           _value.set(v);
         } else if (_value is String) {
      _value = v;
    } else if ((_value == null) && (v != null))
    {
      _value = StringObservable(Binding.toKey(id, 'value'), v, scope: scope, listener: onPropertyChange);
    }
  }
  dynamic get value
  {
    if (_value == null) return null;
    if (_value is StringObservable) return _value.get();
    if (_value is String) return _value;
    return null;
  }

  // tags 
  StringObservable? _tags;
  set tags(dynamic v) {
    if (_tags != null) {
      _tags!.set(v);
    } else if (v != null) {
      _tags = StringObservable(Binding.toKey(id, 'tags'), v, scope: scope, listener: onPropertyChange);
    }
  }

  String? get tags {
    return _tags?.get();
  }

  OptionModel(WidgetModel? parent, String? id, {dynamic data, dynamic labelValue, ViewableWidgetModel? label, dynamic value, dynamic tags}) : super(parent, id, scope: Scope(parent: parent?.scope))
  {
    this.data = data;
    if (label != null) this.label = label;
    if (labelValue != null) this.labelValue = labelValue;
    if (value != null) this.value = value;
    if (tags != null) this.tags = tags;
  }

  static OptionModel? fromXml(WidgetModel? parent, XmlElement? xml, {dynamic data})
  {
    OptionModel? model;
    try
    {
      // build model
      model = OptionModel(parent, Xml.get(node: xml, tag: 'id'), data: data);
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e, caller: 'option.Model');
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

    // Label
    String? label = Xml.attribute(node: xml, tag: 'label');
    if (label == null)
    {
      // legacy
      XmlElement? node = Xml.getElement(node: xml, tag: 'label');
      if (node != null)
      {
        if (Xml.hasChildElements(node))
        {
          this.label = RowModel.fromXml(this, node);
        }
        else
        {
          this.label = TextModel(this, null, value: Xml.getText(node));
        }
      }

      // OPTION child elements do
      // no need to be wrapped in label
      else if (viewableChildren.isNotEmpty)
      {
        // one child
        if (viewableChildren.length == 1)
        {
          this.label = viewableChildren.first.model as ViewableWidgetModel;
        }
        // multiple children
        else
        {
          this.label = RowModel(this,null);
          this.label!.children = viewableChildren.toList();
        }
      }
    }
    else
    {
      this.label = TextModel(this, null, value: label);
    }

    // remove viewable children
    children?.removeWhere((child) => viewableChildren.contains(child));

    // Empty?
    if (this.label == null)
    {
      label = Xml.getText(xml);
      if (label != null) {
        this.label = TextModel(this, null, value: label);
      }
    }

    if (this.label == null && labelValue == null) {
      labelValue = Xml.get(node: xml, tag: 'value');
      this.label = TextModel(this, null, value: labelValue);
    }

    // value
    String? value = Xml.get(node: xml, tag: 'value');
    if (value == null) {
      this.value = label;
      labelValue = label;
    }
    else {
      this.value = value;
    }
    labelValue = label;

    tags = Xml.get(node: xml, tag: 'tags');
  }

  @override
  void dispose()
  {
    // dispose of label children
    label?.dispose();

    // dispose of animations
    super.dispose();
  }
}
