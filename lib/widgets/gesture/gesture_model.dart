// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/services.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/reactive/reactive_view.dart';
import 'package:fml/widgets/viewable/viewable_model.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/event/handler.dart';
import 'package:fml/widgets/gesture/gesture_view.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

enum Cursors {
  alias,
  allscroll,
  basic,
  cell,
  click,
  contextmenu,
  copy,
  disappearing,
  forbidden,
  grab,
  grabbing,
  help,
  move,
  nodrop,
  none,
  precise,
  progress,
  resizecolumn,
  resizedown,
  resizedownleft,
  resizedownright,
  resizeleft,
  resizeleftright,
  resizeright,
  resizerow,
  resizeup,
  resizeupdown,
  resizeupleft,
  resizeupleftdownright,
  resizeupright,
  resizeuprightdownleft,
  text,
  verticaltext,
  wait,
  zoomin,
  zoomout}

class GestureModel extends ViewableModel {

  /// On click/tap call event
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

  /// On long click/press call event
  StringObservable? _onlongpress;
  set onlongpress(dynamic v) {
    if (_onlongpress != null) {
      _onlongpress!.set(v);
    } else if (v != null) {
      _onlongpress = StringObservable(Binding.toKey(id, 'onlongpress'), v,
          scope: scope, listener: onPropertyChange, lazyEvaluation: true);
    }
  }
  String? get onlongpress => _onlongpress?.get();

  /// On double click/tap call event
  StringObservable? _ondoubletap;
  set ondoubletap(dynamic v) {
    if (_ondoubletap != null) {
      _ondoubletap!.set(v);
    } else if (v != null) {
      _ondoubletap = StringObservable(Binding.toKey(id, 'ondoubletap'), v,
          scope: scope, listener: onPropertyChange, lazyEvaluation: true);
    }
  }
  String? get ondoubletap => _ondoubletap?.get();

  /// When a user swipes left on the child element call event
  StringObservable? _onswipeleft;
  set onswipeleft(dynamic v) {
    if (_onswipeleft != null) {
      _onswipeleft!.set(v);
    } else if (v != null) {
      _onswipeleft = StringObservable(Binding.toKey(id, 'onswipeleft'), v,
          scope: scope, listener: onPropertyChange, lazyEvaluation: true);
    }
  }
  String? get onswipeleft => _onswipeleft?.get();

  /// When a user swipes right on the child element call event
  StringObservable? _onswiperight;
  set onswiperight(dynamic v) {
    if (_onswiperight != null) {
      _onswiperight!.set(v);
    } else if (v != null) {
      _onswiperight = StringObservable(Binding.toKey(id, 'onswiperight'), v,
          scope: scope, listener: onPropertyChange, lazyEvaluation: true);
    }
  }
  String? get onswiperight => _onswiperight?.get();

  /// When a user swipes up on the child element call event
  StringObservable? _onswipeup;
  set onswipeup(dynamic v) {
    if (_onswipeup != null) {
      _onswipeup!.set(v);
    } else if (v != null) {
      _onswipeup = StringObservable(Binding.toKey(id, 'onswipeup'), v,
          scope: scope, listener: onPropertyChange, lazyEvaluation: true);
    }
  }
  String? get onswipeup => _onswipeup?.get();

  /// When a user swipes down on the child element call event
  StringObservable? _onswipedown;
  set onswipedown(dynamic v) {
    if (_onswipedown != null) {
      _onswipedown!.set(v);
    } else if (v != null) {
      _onswipedown = StringObservable(Binding.toKey(id, 'onswipedown'), v,
          scope: scope, listener: onPropertyChange, lazyEvaluation: true);
    }
  }
  String? get onswipedown => _onswipedown?.get();

  /// When a user swipes down on the child element call event
  StringObservable? _onrightclick;
  set onrightclick(dynamic v) {
    if (_onrightclick != null) {
      _onrightclick!.set(v);
    } else if (v != null) {
      _onrightclick = StringObservable(Binding.toKey(id, 'onrightclick'), v,
          scope: scope, listener: onPropertyChange, lazyEvaluation: true);
    }
  }
  String? get onrightclick => _onrightclick?.get();

  /// mouse over event
  StringObservable? _onmouseover;
  set onmouseover(dynamic v) {
    if (_onmouseover != null) {
      _onmouseover!.set(v);
    } else if (v != null) {
      _onmouseover =
          StringObservable(Binding.toKey(id, 'onmouseover'), v, scope: scope);
    }
  }
  String? get onmouseover => _onmouseover?.get();

  /// mouse out event
  StringObservable? _onmouseout;
  set onmouseout(dynamic v) {
    if (_onmouseout != null) {
      _onmouseout!.set(v);
    } else if (v != null) {
      _onmouseout =
          StringObservable(Binding.toKey(id, 'onmouseout'), v, scope: scope);
    }
  }
  String? get onmouseout => _onmouseout?.get();

  /// mouse cursor on hover
  StringObservable? _cursor;
  set cursor(dynamic v) {
    if (_cursor != null) {
      _cursor!.set(v);
    } else if (v != null) {
      _cursor =
          StringObservable(Binding.toKey(id, 'cursor'), v, scope: scope);
    }
  }
  String? get cursor => _cursor?.get();

  GestureModel(
    Model super.parent,
    super.id, {
    dynamic enabled,
    dynamic onclick,
    dynamic onlongpress,
    dynamic ondoubletap,
    dynamic onswipeleft,
    dynamic onswiperight,
    dynamic onswipeup,
    dynamic onswipedown,
    dynamic onrightclick,
  }) {
    this.enabled = enabled;
    this.onclick = onclick;
    this.onlongpress = onlongpress;
    this.ondoubletap = ondoubletap;
    this.onswipeleft = onswipeleft;
    this.onswiperight = onswiperight;
    this.onswipeup = onswipeup;
    this.onswipedown = onswipedown;
    this.onrightclick = onrightclick;
  }

  static GestureModel? fromXml(Model parent, XmlElement xml) {
    GestureModel? model;
    try {
// build model
      model = GestureModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch (e) {
      model = null;
      Log().exception(e, caller: 'gesture.Model');
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {
    // deserialize
    super.deserialize(xml);

    // properties
    enabled = Xml.get(node: xml, tag: 'enabled');
    onlongpress = Xml.get(node: xml, tag: 'onlongpress');
    ondoubletap = Xml.get(node: xml, tag: 'ondoubletap');
    onclick = Xml.get(node: xml, tag: 'onclick');
    onswipeleft = Xml.get(node: xml, tag: 'onswipeleft');
    onswiperight = Xml.get(node: xml, tag: 'onswiperight');
    onswipeup = Xml.get(node: xml, tag: 'onswipeup');
    onswipedown = Xml.get(node: xml, tag: 'onswipedown');
    onrightclick = Xml.get(node: xml, tag: 'onrightclick');

    onmouseover = Xml.get(node: xml, tag: 'onmouseover');
    onmouseout = Xml.get(node: xml, tag: 'onmouseout');

    cursor = Xml.get(node: xml, tag: 'cursor');
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

  Future<bool> onMouseOver(BuildContext context) async {
    if (onmouseover == null) return true;
    return await EventHandler(this).execute(_onmouseover);
  }

  Future<bool> onMouseOut(BuildContext context) async {
    if (onmouseout == null) return true;
    return await EventHandler(this).execute(_onmouseout);
  }

  @override
  Widget getView({Key? key}) {
    var view = GestureView(this);
    return isReactive ? ReactiveView(this, view) : view;
  }

  static SystemMouseCursor toCursor(String? cursor) {

    // set system cursor
    switch (toEnum(cursor?.toLowerCase().trim(), Cursors.values) ?? Cursors.click) {
      case Cursors.alias:
        return SystemMouseCursors.alias;
      case Cursors.allscroll:
        return SystemMouseCursors.allScroll;
      case Cursors.basic:
        return SystemMouseCursors.basic;
      case Cursors.cell:
        return SystemMouseCursors.cell;
      case Cursors.click:
        return SystemMouseCursors.click;
      case Cursors.contextmenu:
        return SystemMouseCursors.contextMenu;
      case Cursors.copy:
        return SystemMouseCursors.copy;
      case Cursors.disappearing:
        return SystemMouseCursors.disappearing;
      case Cursors.forbidden:
        return SystemMouseCursors.forbidden;
      case Cursors.grab:
        return SystemMouseCursors.grab;
      case Cursors.grabbing:
        return SystemMouseCursors.grabbing;
      case Cursors.help:
        return SystemMouseCursors.help;
      case Cursors.move:
        return SystemMouseCursors.move;
      case Cursors.nodrop:
        return SystemMouseCursors.noDrop;
      case Cursors.precise:
        return SystemMouseCursors.precise;
      case Cursors.progress:
        return SystemMouseCursors.progress;
      case Cursors.resizecolumn:
        return SystemMouseCursors.resizeColumn;
      case Cursors.resizedown:
        return SystemMouseCursors.resizeDown;
      case Cursors.resizedownleft:
        return SystemMouseCursors.resizeDownLeft;
      case Cursors.resizedownright:
        return SystemMouseCursors.resizeDownRight;
      case Cursors.resizeleft:
        return SystemMouseCursors.resizeLeft;
      case Cursors.resizeleftright:
        return SystemMouseCursors.resizeLeftRight;
      case Cursors.resizeright:
        return SystemMouseCursors.resizeRight;
      case Cursors.resizerow:
        return SystemMouseCursors.resizeRow;
      case Cursors.resizeup:
        return SystemMouseCursors.resizeUp;
      case Cursors.resizeupdown:
        return SystemMouseCursors.resizeUpDown;
      case Cursors.resizeupleft:
        return SystemMouseCursors.resizeUpLeft;
      case Cursors.resizeupleftdownright:
        return SystemMouseCursors.resizeUpLeftDownRight;
      case Cursors.resizeupright:
        return SystemMouseCursors.resizeUpRight;
      case Cursors.resizeuprightdownleft:
        return SystemMouseCursors.resizeUpRightDownLeft;
      case Cursors.text:
        return SystemMouseCursors.text;
      case Cursors.verticaltext:
        return SystemMouseCursors.verticalText;
      case Cursors.wait:
        return SystemMouseCursors.wait;
      case Cursors.zoomin:
        return SystemMouseCursors.zoomIn;
      case Cursors.zoomout:
        return SystemMouseCursors.zoomOut;
      case Cursors.none:
        return SystemMouseCursors.none;
    }
  }
}
