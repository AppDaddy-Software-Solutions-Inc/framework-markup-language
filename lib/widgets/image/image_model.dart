// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/reactive/reactive_view.dart';
import 'package:fml/widgets/viewable/viewable_model.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/image/image_view.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

class ImageModel extends ViewableModel {
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

  // default
  StringObservable? _default;
  set defaultvalue(dynamic v) {
    if (_default != null) {
      _default!.set(v);
    } else if (v != null) {
      _default = StringObservable(Binding.toKey(id, 'default'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String? get defaultvalue => _default?.get();

  // fit
  StringObservable? _fit;
  set fit(dynamic v) {
    if (_fit != null) {
      _fit!.set(v);
    } else if (v != null) {
      _fit = StringObservable(Binding.toKey(id, 'fit'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String? get fit => _fit?.get();

  // interactive
  BooleanObservable? _interactive;
  set interactive(dynamic v) {
    if (_interactive != null) {
      _interactive!.set(v);
    } else if (v != null) {
      _interactive = BooleanObservable(Binding.toKey(id, 'interactive'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  bool get interactive => _interactive?.get() ?? false;

  ImageModel(Model super.parent, super.id,
      {dynamic url,
      dynamic defaultvalue,
      dynamic width,
      dynamic height,
      dynamic opacity,
      dynamic fit,
      dynamic interactive}) {
    if (width != null) this.width = width;
    if (height != null) this.height = height;

    this.opacity = opacity;
    this.url = url;
    this.defaultvalue = defaultvalue;
    this.fit = fit;
    this.interactive = interactive;
  }

  static ImageModel? fromXml(Model parent, XmlElement xml) {
    ImageModel? model;
    try {
      model = ImageModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'image.Model');
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
    url = Xml.get(node: xml, tag: 'url');
    defaultvalue = Xml.get(node: xml, tag: 'default');
    fit = Xml.get(node: xml, tag: 'fit');
    interactive = Xml.get(node: xml, tag: 'interactive');
  }

  @override
  Widget getView({Key? key}) {
    var view = ImageView(this);
    return isReactive ? ReactiveView(this, view) : view;
  }
}
