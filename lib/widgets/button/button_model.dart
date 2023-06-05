// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/log/manager.dart';
import 'package:fml/event/event.dart' ;
import 'package:fml/event/handler.dart' ;
import 'package:flutter/material.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/widgets/button/button_view.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

/// Button [ButtonModel]
///
/// Defines the properties used to build a [BUTTON.ButtonView]
class ButtonModel extends BoxModel
{
  /// [Event]s to execute when the button is clicked
  StringObservable? _onclick;
  set onclick (dynamic v)
  {
    if (_onclick != null)
    {
      _onclick!.set(v);
    }
    else if (v != null)
    {
      _onclick = StringObservable(Binding.toKey(id, 'onclick'), v, scope: scope, listener: onPropertyChange, lazyEval: true);
    }
  }
  String? get onclick
  {
    if (_onclick == null) return null;
    return _onclick?.get();
  }

  final bool expandByDefault = false;

  /////////////
  /* onenter */
  /////////////
  StringObservable? _onenter;
  set onenter (dynamic v)
  {
    if (_onenter != null)
    {
      _onenter!.set(v);
    }
    else if (v != null)
    {
      _onenter = StringObservable(Binding.toKey(id, 'onenter'), v, scope: scope, listener: onPropertyChange, lazyEval: true);
    }
  }
  String? get onenter
  {
    if (_onenter == null) return null;
    return _onenter?.get();
  }

  /////////////
  /* onexit */
  /////////////
  StringObservable? _onexit;
  set onexit (dynamic v)
  {
    if (_onexit != null)
    {
      _onexit!.set(v);
    }
    else if (v != null)
    {
      _onexit = StringObservable(Binding.toKey(id, 'onexit'), v, scope: scope, listener: onPropertyChange, lazyEval: true);
    }
  }
  String? get onexit
  {
    if (_onexit == null) return null;
    return _onexit?.get();
  }

  /// Text value for Button
  ///
  /// Label is not required and can be ignored if a child [TEXT.Model] is defined
  /// or if the button is not intended to contain text.
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
    if (_label == null) return null;
    String? l = _label?.get();
    try {
      if ((l is String) && (l.contains(':'))) l = S.parseEmojis(l);
    } catch(e) {
      Log().debug('$e');
    }
    return l;
  }


  /// Type of button
  ///
  /// Values: text, outlined, elevated
  StringObservable? _buttontype;
  set buttontype (dynamic v)
  {
    if (_buttontype != null)
    {
      _buttontype!.set(v);
    }
    else if (v != null)
    {
      _buttontype = StringObservable(Binding.toKey(id, 'type'), v, scope: scope, listener: onPropertyChange);
    }
  }

  String? get buttontype
  {
    if (_buttontype == null) return null;
    return _buttontype?.get();
  }

  /// Returns the children
  List<WidgetModel>? get contents
  {
    if (children == null) return null;
    return children;
  }

  @override
  set children(List<WidgetModel>? s)
  {
    super.children = s;
  }

  ButtonModel(WidgetModel? parent, String? id, {
    dynamic onclick,
    dynamic onenter,
    dynamic onexit,
    dynamic label,
    dynamic buttontype,
    dynamic color,
    dynamic radius,
    dynamic enabled,
    dynamic width,
    dynamic height,
    dynamic minwidth,
    dynamic maxwidth,
    dynamic minheight,
    dynamic maxheight,
    List<WidgetModel>? children
  }) : super(parent, id)
  {
    // constraints
    if (width     != null) this.width     = width;
    if (height    != null) this.height    = height;
    if (minwidth  != null) minWidth  = minwidth;
    if (minheight != null) minHeight = minheight;
    if (maxwidth  != null) maxWidth  = maxwidth;
    if (maxheight != null) maxHeight = maxheight;

    this.onclick    = onclick;
    this.onenter    = onenter;
    this.onexit     = onexit;
    this.label      = label;
    this.color      = color;
    this.buttontype = buttontype;
    this.color      = color;
    this.radius     = radius;
    this.enabled    = enabled;
    if (children != null)
    {
      this.children = [];
      this.children!.addAll(children);
    }

  }
  static ButtonModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    ButtonModel? model;
    try
    {
      model = ButtonModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'button.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement? xml)
  {

    // deserialize 
    super.deserialize(xml);

    // properties
    String?                      text = Xml.get(node: xml, tag: 'value');
    if (S.isNullOrEmpty(text))  text = Xml.get(node: xml, tag: 'label');
    if (S.isNullOrEmpty(text))  text = Xml.getText(xml);

    label             = text;
    onclick           = Xml.get(node: xml, tag: 'onclick');
    onenter           = Xml.get(node: xml, tag: 'onenter');
    onexit            = Xml.get(node: xml, tag: 'onexit');
    buttontype        = Xml.get(node: xml, tag: 'type');
    radius            = Xml.get(node: xml, tag: 'radius');
  }

  @override
  dispose()
  {
    // Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  bool preventClicking = false;
  Timer? allowClicking;

  onPress(BuildContext context) async
  {
    if (preventClicking != true)
    {
      if (allowClicking?.isActive ?? false) allowClicking!.cancel();
      allowClicking = Timer(Duration(milliseconds: 300), () => preventClicking = false);
      preventClicking = true;

      WidgetModel.unfocus();
      await System().onCommit();

      if (enabled != false) await onClick(context);
    }
  }

  Future<bool> onClick(BuildContext context) async
  {
    return await EventHandler(this).execute(_onclick);
  }

  Future<bool> onEnter(BuildContext context) async
  {
    return await EventHandler(this).execute(_onenter);
  }

  Future<bool> onExit(BuildContext context) async
  {
    return await EventHandler(this).execute(_onexit);
  }

  @override
  Widget getView({Key? key}) => getReactiveView(ButtonView(this));
}

