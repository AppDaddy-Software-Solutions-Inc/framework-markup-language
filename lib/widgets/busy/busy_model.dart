// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:math';

import 'package:fml/log/manager.dart';
import 'package:fml/widgets/busy/busy_view.dart';
import 'package:fml/widgets/reactive/reactive_view.dart';
import 'package:fml/widgets/viewable/viewable_model.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

/// Busy Model
///
/// Defines the properties of a [BUSY.BusyView]
class BusyModel extends ViewableModel {
  // visible
  BooleanObservable? _visible;

  @override
  set visible(dynamic v) {
    if (_visible != null) {
      _visible!.set(v);
    } else if (v != null) {
      _visible = BooleanObservable(Binding.toKey(id, 'visible'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  @override
  bool get visible => _visible?.get() ?? false;

  /// Size of the widget sets the width and height
  bool _sizeIsPercent = false;
  DoubleObservable? _size;
  set size(dynamic v) {
    if (_size != null) {
      _size!.set(v);
      width = v;
    } else if (v != null) {
      if (isPercent(v)) {
        _sizeIsPercent = true;
        v = v.split("%")[0];
      }
      _size = DoubleObservable(Binding.toKey(id, 'size'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  double? get size {
    var s = _size?.get();
    if (s == null) return null;
    if (_sizeIsPercent == true) {
      var width = calculatedMaxHeightForPercentage * (s / 100.0);
      var height = myMaxWidthForPercentage * (s / 100.0);
      s = max(width, height);
    }
    return s;
  }

  /// if true creates a modal barrier to prevent actions until the busy disappears
  BooleanObservable? _modal;
  set modal(dynamic v) {
    if (_modal != null) {
      _modal!.set(v);
    } else if (v != null) {
      _modal = BooleanObservable(Binding.toKey(id, 'modal'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  bool get modal => _modal?.get() ?? false;

  BusyModel(Model? parent,
      {String? id,
      dynamic visible,
      dynamic expand,
      dynamic size,
      dynamic color,
      dynamic modal,
      Observable? observable})
      : super(parent, id) {
    //this.visible = (visible == true) ? true : false; // TODO this causes issues with binding as we are not setting it to widget.model's observable
    this.visible = visible;
    this.size = size;
    this.color = color;
    this.modal = modal;
    if (observable != null) observable.registerListener(onObservableChange);
  }

  void onObservableChange(Observable observable) {
    var v = observable.get();
    visible = v;
  }

  static BusyModel? fromXml(Model parent, XmlElement xml) {
    BusyModel? model;
    try {
      model = BusyModel(parent, id: Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'busy.Model');
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
    size = Xml.get(node: xml, tag: 'size');
    modal = Xml.get(node: xml, tag: 'modal');
  }

  @override
  Widget getView({Key? key}) {
    var view = BusyView(this);
    return isReactive ? ReactiveView(this, view) : view;
  }
}
