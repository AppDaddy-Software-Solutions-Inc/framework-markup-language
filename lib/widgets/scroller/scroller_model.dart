// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/viewable_widget_model.dart';
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
class ScrollerModel extends ViewableWidgetModel implements IViewableWidget
{
  @override
  double? get globalMaxWidth
  {
    if (layout == 'row')
         return null;
    else return super.globalMaxWidth;
  }

  @override
  double? get globalMaxHeight
  {
    if (layout == 'column')
         return null;
    else return super.globalMaxHeight;
  }

  /// The cross alignment of the widgets children. Can be `top`, `bottom`, `start`, or `end`.
  StringObservable? _align;

  set align(dynamic v) {
    if (_align != null) {
      _align!.set(v);
    } else if (v != null) {
      _align = StringObservable(Binding.toKey(id, 'align'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String? get align => _align?.get();



  /// Layout determines the widgets childrens layout. Can be `row`, `column`, `col`. Defaulted to `column`. Overrides direction.
  StringObservable? _layout;
  set layout(dynamic v)
  {
    if (v == 'horizontal') v = 'row';
    if (v == 'vertical')   v = 'column';
    if (v == 'col')        v = 'column';
    if (_layout != null)
    {
      _layout!.set(v);
    }
    else if (v != null)
    {
      _layout = StringObservable(Binding.toKey(id, 'layout'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String get layout
  {
    var v = _layout?.get()?.toLowerCase().trim();
    if (v == 'horizontal') v = 'row';
    if (v == 'vertical')   v = 'column';
    if (v == 'col')        v = 'column';
    return v ?? 'column';
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
  bool? get scrollbar => _scrollbar?.get();

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

  ColorObservable? _shadowcolor;
  set shadowcolor(dynamic v) {
    if (_shadowcolor != null) {
      _shadowcolor!.set(v);
    } else if (v != null) {
      _shadowcolor = ColorObservable(
          Binding.toKey(id, 'shadowcolor'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  Color? get shadowcolor => _shadowcolor?.get();


  ScrollerModel(WidgetModel parent, String? id,
      { dynamic direction,
        dynamic scrollbar,
        dynamic draggable,
        dynamic align,
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
    if (minwidth  != null) this.minWidth  = minwidth;
    if (minheight != null) this.minHeight = minheight;
    if (maxwidth  != null) this.maxWidth  = maxwidth;
    if (maxheight != null) this.maxHeight = maxheight;

    this.draggable = draggable;
    this.onpulldown = onpulldown;
    this.align = align;
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
  void deserialize(XmlElement xml)
  {

    // deserialize 
    super.deserialize(xml);

    // properties
    scrollbar = Xml.get(node: xml, tag: 'scrollbar');
    align = Xml.get(node: xml, tag: 'align');
    layout = Xml.get(node: xml, tag: 'layout') ?? Xml.get(node: xml, tag: 'direction');
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


  Widget getView({Key? key}) => getReactiveView(ScrollerView(this));
}


