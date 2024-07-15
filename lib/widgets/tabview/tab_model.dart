// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/box/box_view.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

class TabModel extends BoxModel {

  @override
  LayoutType layoutType = LayoutType.column;

  @override
  bool get expand => true;

  // url
  StringObservable? _url;
  set url(dynamic v) {
    if (_url != null) {
      _url!.set(v);
    } else if (v != null) {
      _url = StringObservable(Binding.toKey(id, 'url'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String? get url => _url?.get();

  /// The title of the tab
  StringObservable? _title;
  set title(dynamic v) {
    if (_title != null) {
      _title!.set(v);
    } else if (v != null) {
      _title = StringObservable(Binding.toKey(id, 'title'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String? get title => _title?.get();

  // closeable
  BooleanObservable? _closeable;
  set closeable(dynamic v) {
    if (_closeable != null) {
      _closeable!.set(v);
    } else if (v != null) {
      _closeable = BooleanObservable(Binding.toKey(id, 'closeable'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  bool get closeable => _closeable?.get() ?? true;

  TabModel(super.parent, super.id, {dynamic data, dynamic url})
      : super(scope: Scope(parent: parent?.scope)) {
    this.data = data;
    this.url = url;
  }

  static TabModel? fromXml(Model? parent, XmlElement? xml,
      {dynamic data, dynamic onTap, dynamic onLongPress}) {
    TabModel? model;
    try {
      // build model
      model = TabModel(parent, Xml.get(node: xml, tag: 'id'), data: data);
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'TabModel');
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

    // properties
    url = Xml.get(node: xml, tag: 'url');
    title = Xml.get(node: xml, tag: 'title');
    closeable = Xml.get(node: xml, tag: 'closable');
  }

  @override
  Widget getView({Key? key}) => BoxView(this, (_,__) => inflate());
}
