// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/decorated_widget_model.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/event/handler.dart' ;
import 'package:fml/widgets/gesture/gesture_view.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class GestureModel extends DecoratedWidgetModel implements IViewableWidget
{
  /// On click/tap call event
  StringObservable? _onclick;
  set onclick(dynamic v)
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
    return _onclick?.get();
  }

  /// On long click/press call event
  StringObservable? _onlongpress;
  set onlongpress(dynamic v)
  {
    if (_onlongpress != null)
    {
      _onlongpress!.set(v);
    }
    else if (v != null)
    {
      _onlongpress = StringObservable(Binding.toKey(id, 'onlongpress'), v, scope: scope, listener: onPropertyChange, lazyEval: true);
    }
  }
  String? get onlongpress {
    return _onlongpress?.get();
  }

  /// On double click/tap call event
  StringObservable? _ondoubletap;
  set ondoubletap(dynamic v)
  {
    if (_ondoubletap != null)
    {
      _ondoubletap!.set(v);
    }
    else if (v != null)
    {
      _ondoubletap = StringObservable(Binding.toKey(id, 'ondoubletap'), v, scope: scope, listener: onPropertyChange, lazyEval: true);
    }
  }
  String? get ondoubletap
  {
    return _ondoubletap?.get();
  }

  /// When a user swipes left on the child element call event 
  StringObservable? _onswipeleft;
  set onswipeleft(dynamic v)
  {
    if (_onswipeleft != null)
    {
      _onswipeleft!.set(v);
    }
    else if (v != null)
    {
      _onswipeleft = StringObservable(Binding.toKey(id, 'onswipeleft'), v, scope: scope, listener: onPropertyChange, lazyEval: true);
    }
  }
  String? get onswipeleft
  {
    return _onswipeleft?.get();
  }

  /// When a user swipes right on the child element call event 
  StringObservable? _onswiperight;
  set onswiperight(dynamic v)
  {
    if (_onswiperight != null)
    {
      _onswiperight!.set(v);
    }
    else if (v != null)
    {
      _onswiperight = StringObservable(Binding.toKey(id, 'onswiperight'), v, scope: scope, listener: onPropertyChange, lazyEval: true);
    }
  }
  String? get onswiperight
  {
    return _onswiperight?.get();
  }

  /// When a user swipes up on the child element call event
  StringObservable? _onswipeup;
  set onswipeup(dynamic v)
  {
    if (_onswipeup != null)
    {
      _onswipeup!.set(v);
    }
    else if (v != null)
    {
      _onswipeup = StringObservable(Binding.toKey(id, 'onswipeup'), v, scope: scope, listener: onPropertyChange, lazyEval: true);
    }
  }
  String? get onswipeup
  {
    return _onswipeup?.get();
  }

  /// When a user swipes down on the child element call event
  StringObservable? _onswipedown;
  set onswipedown(dynamic v)
  {
    if (_onswipedown != null)
    {
      _onswipedown!.set(v);
    }
    else if (v != null)
    {
      _onswipedown = StringObservable(Binding.toKey(id, 'onswipedown'), v, scope: scope, listener: onPropertyChange, lazyEval: true);
    }
  }
  String? get onswipedown
  {
    return _onswipedown?.get();
  }

  /// When a user swipes down on the child element call event
  StringObservable? _onrightclick;
  set onrightclick(dynamic v)
  {
    if (_onrightclick != null)
    {
      _onrightclick!.set(v);
    }
    else if (v != null)
    {
      _onrightclick = StringObservable(Binding.toKey(id, 'onrightclick'), v, scope: scope, listener: onPropertyChange, lazyEval: true);
    }
  }
  String? get onrightclick
  {
    return _onrightclick?.get();
  }

  GestureModel(
      WidgetModel parent,
      String? id, {
        dynamic enabled,
        dynamic onclick,
        dynamic onlongpress,
        dynamic ondoubletap,
        dynamic onswipeleft,
        dynamic onswiperight,
        dynamic onswipeup,
        dynamic onswipedown,
        dynamic onrightclick,
      }) : super(parent, id) {
    this.enabled      = enabled;
    this.onclick      = onclick;
    this.onlongpress  = onlongpress;
    this.ondoubletap  = ondoubletap;
    this.onswipeleft  = onswipeleft;
    this.onswiperight = onswiperight;
    this.onswipeup    = onswipeup;
    this.onswipedown  = onswipedown;
    this.onrightclick = onrightclick;
  }

  static GestureModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    GestureModel? model;
    try
    {
      /////////////////
      /* Build Model */
      /////////////////
      model = GestureModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      model = null;
      Log().exception(e,  caller: 'gesture.Model');
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {
    // deserialize 
    super.deserialize(xml);

    // properties
    enabled       = Xml.get(node: xml, tag: 'enabled');
    onlongpress   = Xml.get(node: xml, tag: 'onlongpress');
    ondoubletap   = Xml.get(node: xml, tag: 'ondoubletap');
    onclick       = Xml.get(node: xml, tag: 'onclick');
    onswipeleft   = Xml.get(node: xml, tag: 'onswipeleft');
    onswiperight  = Xml.get(node: xml, tag: 'onswiperight');
    onswipeup     = Xml.get(node: xml, tag: 'onswipeup');
    onswipedown   = Xml.get(node: xml, tag: 'onswipedown');
    onrightclick  = Xml.get(node: xml, tag: 'onrightclick');
  }

  @override
  dispose()
  {
Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  Future<bool> onClick(BuildContext context) async {
    if (onclick == null) return true;
    return await EventHandler(this).execute(_onclick);
  }

  Future<bool> onLongPress(BuildContext context) async {
    if (onlongpress == null) return true;
    return await EventHandler(this).execute(_onlongpress);
  }

  Future<bool> onDoubleTap(BuildContext context) async {
    if (ondoubletap == null) return true;
    return await EventHandler(this).execute(_ondoubletap);
  }

  Future<bool> onSwipeLeft(BuildContext context) async {
    if (onswipeleft == null) return true;
    return await EventHandler(this).execute(_onswipeleft);
  }

  Future<bool> onSwipeRight(BuildContext context) async {
    if (onswiperight == null) return true;
    return await EventHandler(this).execute(_onswiperight);
  }

  Future<bool> onSwipeUp(BuildContext context) async {
    if (onswipeup == null) return true;
    return await EventHandler(this).execute(_onswipeup);
  }

  Future<bool> onSwipeDown(BuildContext context) async {
    if (onswipedown == null) return true;
    return await EventHandler(this).execute(_onswipedown);
  }

  Future<bool> onRightClick(BuildContext context) async {
    if (onrightclick == null) return true;
    return await EventHandler(this).execute(_onrightclick);
  }

  Widget getView({Key? key}) => GestureView(this);
}
