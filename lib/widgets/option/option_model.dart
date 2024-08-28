// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/option/tag_model.dart';
import 'package:fml/widgets/text/text_model.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/row/row_model.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';


enum OptionType {empty, nomatch, nodata, prototype}

class OptionModel extends RowModel {
  @override
  bool get expand => false;

  @override
  String? get valign => super.valign ?? "center";

  // option type
  String? _type;
  OptionType? get type => toEnum(_type, OptionType.values);

  // label
  StringObservable? _label;
  set label(dynamic v) {
    if (_label != null) {
      _label!.set(v);
    } else if (v != null) {
      _label = StringObservable(null, v, scope: scope);
    }
  }
  String? get label => _label?.get() ?? value;

  BooleanObservable? _startSelected;
  set startSelected(dynamic v) {
    if (_startSelected != null) {
      _startSelected!.set(v);
    } else if (v != null) {
      _startSelected = BooleanObservable(Binding.toKey(id, 'startselected'), v, scope: scope);
    }
  }

  bool get startSelected => _startSelected?.get() ?? false;

  // value
  StringObservable? _value;
  set value(dynamic v) {
    if (_value != null) {
      _value!.set(v);
    } else if (v != null) {
      _value = StringObservable(null, v, scope: scope);
    }
  }
  String? get value => _value?.get();

  // string to search on
  final List<TagModel> tags = [];

  OptionModel(super.parent, super.id, {dynamic data, String? value, String? label, dynamic startSelected})
      : super(scope: Scope(parent: parent.scope)) {
    this.data = data;
    this.startSelected = startSelected;
    if (value != null) this.value = value;
    if (label != null) this.label = label;
  }

  static OptionModel? fromXml(Model parent, XmlElement? xml,
      {dynamic data}) {
    OptionModel? model;
    try {
      // build model
      model = OptionModel(parent, Xml.get(node: xml, tag: 'id'), data: data);
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'option.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement? xml) {
    if (xml == null) return;

    // deserialize
    super.deserialize(xml);

    // Properties
    var label = Xml.get(node: xml, tag: 'label');
    var value = Xml.get(node: xml, tag: 'value');
    var startSelected = Xml.get(node: xml, tag: 'startselected');

    // <OPTION>xxx</OPTION> style
    if (label == null && viewableChildren.isEmpty) {
      var text = Xml.getText(xml);
      if (!isNullOrEmpty(text)) label = text;
    }

    // label specified but not value
    if (value == null && label != null) value = label;

    // set option type
    _type = Xml.get(node: xml, tag: 'type')?.toLowerCase().trim();

    // set label and value
    this.label = label;
    this.value = value;

    // add text model
    if (viewableChildren.isEmpty)
    {
      children ??= [];
      children!.add(TextModel(this,null,value: label ?? value));
    }

    // assign tags
    tags.addAll(findChildrenOfExactType(TagModel).cast<TagModel>());

    // remove child tags
    if (tags.isNotEmpty) {
      removeChildrenOfExactType(TagModel);
    }

    // no tags specified? default is label
    if (tags.isEmpty) {
      tags.add(TagModel(this,null,value: label ?? value));
    }
  }

  @override
  void dispose() {

    // dispose of tags
    for (var tag in tags) {
      tag.dispose();
    }

    // dispose
    super.dispose();
  }

  Widget? cachedView;

  @override
  Widget getView({Key? key}) {
    cachedView ??= super.getView();
    return cachedView!;
  }
}
