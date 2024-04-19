// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/widgets/viewable/viewable_widget_model.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/iframe/inline_frame_view.dart' as widget_view;
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

class InlineFrameModel extends ViewableWidgetModel {
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

  InlineFrameModel(Model super.parent, super.id);

  static InlineFrameModel? fromXml(Model parent, XmlElement xml) {
    InlineFrameModel? model =
        InlineFrameModel(parent, Xml.get(node: xml, tag: 'id'));
    model.deserialize(xml);
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {
    // deserialize
    super.deserialize(xml);

    // properties
    url = Xml.get(node: xml, tag: 'url');
  }

  @override
  Widget getView({Key? key}) => (widget_view.View(this) as Widget);
}
