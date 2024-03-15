// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/option/tag_model.dart';
import 'package:fml/widgets/text/text_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:xml/xml.dart';
import 'package:fml/widgets/row/row_model.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

class OptionModel extends RowModel
{
  @override
  bool get expand => false;

  @override
  String? get valign => super.valign ?? "center";

  // type
  StringObservable? _type;
  set type(dynamic v)
  {
    if (_type != null)
    {
      _type!.set(v);
    }
    else if (v != null)
    {
      _type = StringObservable(null, v, scope: scope);
    }
  }
  String? get type => _type?.get();
  
  // label
  StringObservable? _label;
  set label(dynamic v)
  {
    if (_label != null)
    {
      _label!.set(v);
    }
    else if (v != null)
    {
      _label = StringObservable(null, v, scope: scope);
    }
  }
  String? get label => _label?.get() ?? labelInner ?? value;

  // list of labels from child text widgets
  String? get labelInner
  {
    String? label;
    List<TextModel> models = findDescendantsOfExactType(TextModel).cast<TextModel>();
    for (var model in models)
    {
      var text = model.value;
      if (!isNullOrEmpty(text))
      {
        label ??= "";
        label = "$label $text";
      }
    }
    return label;
  }

  // value
  StringObservable? _value;
  set value(dynamic v)
  {
    if (_value != null)
    {
      _value!.set(v);
    }
    else if (v != null)
    {
      _value = StringObservable(null, v, scope: scope);
    }
  }
  String? get value => _value?.get();

  // string to search on
  List<String> get tags
  {
    List<String> list = [];

    // child search tags specified
    List<TagModel> tags = findChildrenOfExactType(TagModel).cast<TagModel>();
    if (tags.isNotEmpty)
    {
      for (var tag in tags)
      {
        if (!isNullOrEmpty(tag.value)) list.add(tag.value!);
      }
      return list;
    }

    // search on label
    if (!isNullOrEmpty(label))
    {
      list.add(label!);
      return list;
    }

    return list;
  }

  OptionModel(super.parent, super.id, {dynamic data, String? value}) : super(scope: Scope(parent: parent.scope))
  {
    this.data = data;
    if (value != null) this.value = value;
  }

  static OptionModel? fromXml(WidgetModel parent, XmlElement? xml, {dynamic data})
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

    // Properties
    var label = Xml.get(node: xml, tag: 'label');
    var value = Xml.get(node: xml, tag: 'value');

    // <OPTION>xxx</OPTION> style
    if (label == null)
    {
      var text = Xml.getText(xml);
      if (!isNullOrEmpty(Xml.getText(xml)))
      {
        label = text;
        label = text;
      }
    }

    // label specified but not value
    if (value == null && label != null) value = label;

    type = Xml.get(node: xml, tag: 'type');
    this.label = label;
    this.value = value;
  }

  Widget? cachedView;

  @override
  Widget getView({Key? key})
  {
   if (viewableChildren.isEmpty) return Text(label ?? "");
    cachedView ??= super.getView();
    return cachedView!;
  }
}
