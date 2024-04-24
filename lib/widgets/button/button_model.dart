// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/log/manager.dart';
import 'package:fml/event/event.dart';
import 'package:fml/event/handler.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/column/column_model.dart';
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

  /// [Event]s to execute when the button is clicked
  StringObservable? _onclick;
  set onclick(dynamic v) {
    if (_onclick != null) {
      _onclick!.set(v);
    } else if (v != null) {
      _onclick = StringObservable(Binding.toKey(id, 'onclick'), v,
          scope: scope, listener: onPropertyChange, lazyEval: true);
    }
  }

  String? get onclick => _onclick?.get();

  // onenter
  StringObservable? _onenter;
  set onenter(dynamic v) {
    if (_onenter != null) {
      _onenter!.set(v);
    } else if (v != null) {
      _onenter = StringObservable(Binding.toKey(id, 'onenter'), v,
          scope: scope, listener: onPropertyChange, lazyEval: true);
    }
  }

  String? get onenter => _onenter?.get();

  // onexit
  StringObservable? _onexit;
  set onexit(dynamic v) {
    if (_onexit != null) {
      _onexit!.set(v);
    } else if (v != null) {
      _onexit = StringObservable(Binding.toKey(id, 'onexit'), v,
          scope: scope, listener: onPropertyChange, lazyEval: true);
    }
  }

  String? get onexit => _onexit?.get();

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
  String get borderRadius => super.borderRadius ?? '20';

  /// Type of button
  ///
  /// Values: text, outlined, elevated
  StringObservable? _buttontype;
  set buttontype(dynamic v) {
    if (_buttontype != null) {
      _buttontype!.set(v);
    } else if (v != null) {
      _buttontype = StringObservable(Binding.toKey(id, 'type'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String? get buttontype => _buttontype?.get();

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
      {dynamic onclick,
      dynamic onenter,
      dynamic onexit,
      dynamic label,
      dynamic buttontype,
      dynamic color,
      dynamic enabled,
      dynamic width,
      dynamic height,
      dynamic minwidth,
      dynamic maxwidth,
      dynamic minheight,
      dynamic maxheight,
      dynamic layout,
      List<Model>? children}) {
    // constraints
    if (width != null) this.width = width;
    if (height != null) this.height = height;
    if (minwidth != null) minWidth = minwidth;
    if (minheight != null) minHeight = minheight;
    if (maxwidth != null) maxWidth = maxwidth;
    if (maxheight != null) maxHeight = maxheight;

    this.layout = layout;
    this.onclick = onclick;
    this.onenter = onenter;
    this.onexit = onexit;
    this.label = label;
    this.color = color;
    this.buttontype = buttontype;
    this.enabled = enabled;
    this.children = children;
  }

  static ButtonModel? fromXml(Model parent, XmlElement xml) {
    ButtonModel? model;
    try {
      model = ButtonModel(parent, Xml.get(node: xml, tag: 'id'),
          layout: Xml.get(node: xml, tag: 'layout'));
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
    label = Xml.get(node: xml, tag: 'value') ??
        Xml.get(node: xml, tag: 'label') ??
        Xml.getText(xml);
    onclick = Xml.get(node: xml, tag: 'onclick');
    onenter = Xml.get(node: xml, tag: 'onenter');
    onexit = Xml.get(node: xml, tag: 'onexit');
    buttontype = Xml.get(node: xml, tag: 'type');

    // create text model bound to this label as default
    if (viewableChildren.isEmpty && label != null) {
      var model = TextModel(this, null, value: "{$id.label}", weight: 500);
      (children ??= []).add(model);
    }
  }

  bool preventClicking = false;
  Timer? allowClicking;

  onPress(BuildContext context) async {
    if (preventClicking != true) {
      if (allowClicking?.isActive ?? false) allowClicking!.cancel();
      allowClicking = Timer(
          const Duration(milliseconds: 300), () => preventClicking = false);
      preventClicking = true;

      Model.unfocus();

      if (enabled != false) await onClick(context);
    }
  }

  Future<bool> onClick(BuildContext context) async {
    return await EventHandler(this).execute(_onclick);
  }

  Future<bool> onEnter(BuildContext context) async {
    return await EventHandler(this).execute(_onenter);
  }

  Future<bool> onExit(BuildContext context) async {
    return await EventHandler(this).execute(_onexit);
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
  Widget getView({Key? key}) => getReactiveView(ButtonView(this));
}
