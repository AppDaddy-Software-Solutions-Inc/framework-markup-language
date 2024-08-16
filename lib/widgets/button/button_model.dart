// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/log/manager.dart';
import 'package:fml/event/event.dart';
import 'package:fml/event/handler.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/column/column_model.dart';
import 'package:fml/widgets/reactive/reactive_view.dart';
import 'package:fml/widgets/row/row_model.dart';
import 'package:fml/widgets/stack/stack_model.dart';
import 'package:fml/widgets/text/text_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/widgets/button/button_view.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

/// Button [ButtonModel]
///
/// Defines the properties used to build a [BUTTON.ButtonView]
class ButtonModel extends BoxModel {
  BoxModel? _body;

  final double defaultMargin = 3;

  @override
  double? get marginTop => super.marginTop ?? defaultMargin;

  @override
  double? get marginRight => super.marginRight ?? defaultMargin;

  @override
  double? get marginBottom => super.marginBottom ?? defaultMargin;

  @override
  double? get marginLeft => super.marginLeft ?? defaultMargin;

  @override
  LayoutType get layoutType => BoxModel.getLayoutType(layout);

  @override
  bool get center => true;

  @override
  String get border => 'none';

  /// The number of milliseconds used for allowing the next click
  /// and firing the onclick event
  IntegerObservable? _debounce;
  set debounce(dynamic v) {
    if (_debounce != null) {
      _debounce!.set(v);
    } else if (v != null) {
      _debounce = IntegerObservable(Binding.toKey(id, 'debounce'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  int get debounce => _debounce?.get() ?? 300;

  /// [Event]s to execute when the button is clicked
  StringObservable? _onclick;
  set onclick(dynamic v) {
    if (_onclick != null) {
      _onclick!.set(v);
    } else if (v != null) {
      _onclick = StringObservable(Binding.toKey(id, 'onclick'), v,
          scope: scope, listener: onPropertyChange, lazyEvaluation: true);
    }
  }
  String? get onclick => _onclick?.get();

  /// Text value for Button
  ///
  /// Label is not required and can be ignored if a child [TEXT.Model] is defined
  /// or if the button is not intended to contain text.
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
    if (_label == null) return null;
    String? l = _label?.get();
    try {
      if ((l is String) && (l.contains(':'))) l = parseEmojis(l);
    } catch (e) {
      Log().debug('$e');
    }
    return l;
  }

  @override
  String get radius => super.radius ?? '5';

  /// Type of button
  ///
  /// Values: text, outlined, elevated
  StringObservable? _type;
  set type(dynamic v) {
    if (_type != null) {
      _type!.set(v);
    } else if (v != null) {
      _type = StringObservable(Binding.toKey(id, 'type'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String? get type => _type?.get();

  BooleanObservable? _expand;
  @override
  set expand(dynamic v) {
    if (_expand != null) {
      _expand!.set(v);
    } else if (v != null) {
      _expand = BooleanObservable(Binding.toKey(id, 'expand'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  @override
  bool get expand => _expand?.get() ?? false;

  ButtonModel(super.parent, super.id,
      {
      dynamic type,
      dynamic label,
      dynamic color,
      dynamic onclick,
      dynamic enabled,
      List<Model>? children}) {

    this.type = type;
    this.label = label;
    this.color = color;
    this.onclick = onclick;
    this.enabled = enabled;
    this.children = children;
  }

  static ButtonModel? fromXml(Model parent, XmlElement xml) {
    ButtonModel? model;
    try {
      model = ButtonModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'button.Model');
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
    type = Xml.get(node: xml, tag: 'type');
    label = Xml.get(node: xml, tag: 'value') ??
        Xml.get(node: xml, tag: 'label') ??
        Xml.getText(xml);

    debounce = Xml.get(node: xml, tag: 'debounce');
    onclick = Xml.get(node: xml, tag: 'onclick');

    // create text model bound to this label as default
    if (viewableChildren.isEmpty && label != null) {
      var model = TextModel(this, null, value: "{$id.label}", weight: 500, color: type == 'elevated' ? "{THEME.onprimary}" : null);
      (children ??= []).add(model);
    }
  }

  // onclick event handler
  Future<bool> onClick() async {
    bool ok = await EventHandler(this).execute(_onclick);
    Model.unfocus();
    return ok;
  }

  // returns the inner content model
  BoxModel getContentModel() {
    // build the _body model
    if (_body == null) {
      switch (layoutType) {
        case LayoutType.column:
          _body = ColumnModel(this, null);
          break;
        case LayoutType.stack:
          _body = StackModel(this, null);
          break;
        case LayoutType.row:
        default:
          _body = RowModel(this, null);
          _body!.center = true;
          break;
      }
    }

    // add my children to content
    _body!.expand = expand;
    _body!.children = [];
    _body!.children!.addAll(children ?? []);

    return _body!;
  }

  @override
  Widget getView({Key? key}) {
    var view = ButtonView(this);
    return isReactive ? ReactiveView(this, view) : view;
  }
}
