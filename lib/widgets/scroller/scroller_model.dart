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
  /// Scroll direction, `horizontal` or `vertical`
  StringObservable? _direction;
  set direction (dynamic v)
  {
    if (_direction != null)
    {
      _direction!.set(v);
    }
    else if (v != null)
    {
      _direction = StringObservable(Binding.toKey(id, 'direction'), v, scope: scope, listener: onPropertyChange);
    }
  }
  dynamic get direction => _direction?.get() ?? 'vertical';

  /// alignment and layout attributes
  ///


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
  set layout(dynamic v) {
    if (_layout != null) {
      _layout!.set(v);
    } else if (v != null) {
      _layout = StringObservable(Binding.toKey(id, 'layout'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String get layout => _layout?.get()?.toLowerCase() ?? 'column';


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
  StringObservable? _ondrag;
  set ondrag (dynamic v)
  {
    if (_ondrag != null)
    {
      _ondrag!.set(v);
    }
    else if (v != null)
    {
      _ondrag = StringObservable(Binding.toKey(id, 'ondrag'), v, scope: scope, listener: onPropertyChange, lazyEval: true);
    }
  }
  dynamic get ondrag => _ondrag?.get();

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
        dynamic height,
        dynamic minwidth,
        dynamic minheight,
        dynamic maxwidth,
        dynamic ondrag,
        dynamic maxheight,})
      : super(parent, id)
  {
    this.direction = direction;
    this.draggable = draggable;
    this.ondrag = ondrag;
    this.align = align;
    this.width = width;
    this.shadowcolor = shadowcolor;
    this.height = height;
    this.minWidth = minwidth;
    this.minHeight = minheight;
    this.maxWidth = maxwidth;
    this.maxHeight = maxheight;
    this.layout = layout;
    this.scrollbar = scrollbar;
    this.onscrolledtoend = onscrolledtoend;
  }

  static ScrollerModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    ScrollerModel? model;
    try
    {
      /////////////////
      /* Build Model */
      /////////////////
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
    direction = Xml.get(node: xml, tag: 'direction');
    scrollbar = Xml.get(node: xml, tag: 'scrollbar');
    align = Xml.get(node: xml, tag: 'align');
    layout = Xml.get(node: xml, tag: 'layout');
    onscrolledtoend = Xml.get(node: xml, tag: 'onscrolledtoend');
    shadowcolor = Xml.get(node: xml, tag: 'shadowcolor');
    ondrag = Xml.get(node: xml, tag: 'ondrag');
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
    await EventHandler(this).execute(_ondrag);
  }


  Widget getView({Key? key}) => ScrollerView(this);
}


