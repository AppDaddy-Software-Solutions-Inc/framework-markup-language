// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/scroller/scroller_view.dart';
import 'package:fml/event/event.dart'           ;
import 'package:fml/event/handler.dart'         ;
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

/// Button [ScrollerModel]
///
/// Defines the properties used to build a [SCROLLER.ScrollerView]
class ScrollerModel extends BoxModel
{
  @override
  String get border => 'none';

  @override
  set layout(dynamic v)
  {
    if (v is String && v.toLowerCase().trim() == 'horizontal')
    {
      v = 'row';
    }
    else if (v is String && v.toLowerCase().trim() == 'vertical')
    {
      v = 'column';
    }
    super.layout = v;
  }

  /// If true will display a scrollbar, just used as a backup if flutter's built in scrollbar doesn't work
  BooleanObservable? _scrollbar;
  set scrollbar (dynamic v)
  {
    if (_scrollbar != null)
    {
      _scrollbar!.set(v);
    }
    else if (v != null)
    {
      _scrollbar = BooleanObservable(Binding.toKey(id, 'scrollbar'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get scrollbar => _scrollbar?.get() ?? true;

  /// Calls an [Event] String when the scroll reaches max extent
  StringObservable? _onscrolledtoend;
  set onscrolledtoend (dynamic v)
  {
    if (_onscrolledtoend != null)
    {
      _onscrolledtoend!.set(v);
    }
    else if (v != null)
    {
      _onscrolledtoend = StringObservable(Binding.toKey(id, 'onscrolledtoend'), v, scope: scope, listener: onPropertyChange, lazyEval: true);
    }
  }
  dynamic get onscrolledtoend => _onscrolledtoend?.get();


  /// Calls an [Event] String when the scroll overscrolls
  StringObservable? _onpulldown;
  set onpulldown (dynamic v)
  {
    if (_onpulldown != null)
    {
      _onpulldown!.set(v);
    }
    else if (v != null)
    {
      _onpulldown = StringObservable(Binding.toKey(id, 'onpulldown'), v, scope: scope, listener: onPropertyChange, lazyEval: true);
    }
  }
  dynamic get onpulldown => _onpulldown?.get();

  BooleanObservable? _draggable;
  set draggable(dynamic v) {
    if (_draggable != null) {
      _draggable!.set(v);
    } else if (v != null) {
      _draggable = BooleanObservable(Binding.toKey(id, 'draggable'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get draggable => _draggable?.get() ?? false;


  ScrollerModel(WidgetModel parent, String? id,
      { dynamic scrollbar,
        dynamic draggable,
        dynamic layout,
        dynamic shadowcolor,
        dynamic onscrolledtoend,
        dynamic width,
        dynamic height,
        dynamic minwidth,
        dynamic minheight,
        dynamic maxwidth,
        dynamic onpulldown,
        dynamic maxheight,})
      : super(parent, id)
  {
    // constraints
    if (width     != null) this.width     = width;
    if (height    != null) this.height    = height;
    if (minwidth  != null) minWidth  = minwidth;
    if (minheight != null) minHeight = minheight;
    if (maxwidth  != null) maxWidth  = maxwidth;
    if (maxheight != null) maxHeight = maxheight;

    this.draggable = draggable;
    this.onpulldown = onpulldown;
    this.shadowcolor = shadowcolor;
    this.layout = layout;
    this.scrollbar = scrollbar;
    this.onscrolledtoend = onscrolledtoend;
  }

  static ScrollerModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    ScrollerModel? model;
    try
    {
// build model
      model = ScrollerModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'scroller.Model');
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
    layout = Xml.get(node: xml, tag: 'layout') ?? Xml.get(node: xml, tag: 'direction');
    scrollbar = Xml.get(node: xml, tag: 'scrollbar');
    onscrolledtoend = Xml.get(node: xml, tag: 'onscrolledtoend');
    shadowcolor = Xml.get(node: xml, tag: 'shadowcolor');
    onpulldown = Xml.get(node: xml, tag: 'onpulldown');
    draggable = Xml.get(node: xml, tag: 'draggable');
  }

  Future<bool> scrolledToEnd(BuildContext context) async {
    if (S.isNullOrEmpty(onscrolledtoend)) return false;
    return await EventHandler(this).execute(_onscrolledtoend);
  }

  @override
  dispose()
  {
    // Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  Future<void> onPull(BuildContext context) async
  {
    await EventHandler(this).execute(_onpulldown);
  }


  @override
  Widget getView({Key? key}) => getReactiveView(ScrollerView(this));
}


