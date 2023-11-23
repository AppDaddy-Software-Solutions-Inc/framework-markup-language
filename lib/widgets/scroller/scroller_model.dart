// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/column/column_model.dart';
import 'package:fml/widgets/row/row_model.dart';
import 'package:fml/widgets/scroller/scrollable_interface.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/scroller/scroller_view.dart';
import 'package:fml/event/event.dart'           ;
import 'package:fml/event/handler.dart'         ;
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

/// Button [ScrollerModel]
///
/// Defines the properties used to build a [SCROLLER.ScrollerView]
class ScrollerModel extends BoxModel implements IScrollable
{
  // holds the inner child content
  BoxModel? _body;

  // to be implemented
  @override
  bool moreUp = false;

  @override
  bool moreDown = false;

  @override
  bool moreLeft = false;

  @override
  bool moreRight = false;

  @override
  set layout(dynamic v)
  {
    if (v is String)
    {
      switch (v.toLowerCase().trim())
      {
        case 'row':
        case 'horizontal':
          super.layout = 'row';
          break;
        default:
          super.layout = 'column';
          break;
      }
    }
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

  // allowDrag
  BooleanObservable? _allowDrag;
  set allowDrag(dynamic v) {
    if (_allowDrag != null) {
      _allowDrag!.set(v);
    } else if (v != null) {
      _allowDrag = BooleanObservable(Binding.toKey(id, 'allowdrag'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get allowDrag => _allowDrag?.get() ?? false;

  ScrollerModel(WidgetModel parent, String? id) : super(parent, id);

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
    layout          = Xml.get(node: xml, tag: 'layout') ?? Xml.get(node: xml, tag: 'direction');
    scrollbar       = Xml.get(node: xml, tag: 'scrollbar');
    onscrolledtoend = Xml.get(node: xml, tag: 'onscrolledtoend');
    shadowcolor     = Xml.get(node: xml, tag: 'shadowcolor');
    onpulldown      = Xml.get(node: xml, tag: 'onpulldown');
    allowDrag       = Xml.get(node: xml, tag: 'allowDrag');
  }

  Future<bool> scrolledToEnd(BuildContext context) async
  {
    if (isNullOrEmpty(onscrolledtoend)) return false;
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

  // returns the inner content model
  BoxModel getContentModel()
  {
    // build the _body model
    _body ??= (layoutType == LayoutType.row) ? RowModel(this, null) : ColumnModel(this, null);

    // add my children to content
    _body!.children = [];
    _body!.children!.addAll(children ?? []);

    return _body!;
  }

  @override
  void scrollUp(int pixels)
  {
    ScrollerViewState? view = findListenerOfExactType(ScrollerViewState);
    if (view == null) return;

    // already at top
    if (view.controller.offset == 0) return;

    var to = view.controller.offset - pixels;
    to = (to < 0) ? 0 : to;

    view.controller.jumpTo(to);
  }

  @override
  void scrollDown(int pixels)
  {
    ScrollerViewState? view = findListenerOfExactType(ScrollerViewState);
    if (view == null) return;

    if (view.controller.position.pixels >= view.controller.position.maxScrollExtent) return;

    var to = view.controller.offset + pixels;
    to = (to > view.controller.position.maxScrollExtent) ? view.controller.position.maxScrollExtent : to;

    view.controller.jumpTo(to);
  }

  @override
  Offset? positionOf()
  {
    ScrollerViewState? view = findListenerOfExactType(ScrollerViewState);
    return view?.positionOf();
  }

  @override
  Size? sizeOf()
  {
    ScrollerViewState? view = findListenerOfExactType(ScrollerViewState);
    return view?.sizeOf();
  }

  @override
  Widget getView({Key? key}) => getReactiveView(ScrollerView(this));
}


