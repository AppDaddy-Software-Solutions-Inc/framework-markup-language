// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/column/column_model.dart';
import 'package:fml/widgets/row/row_model.dart';
import 'package:fml/widgets/viewable/viewable_widget_model.dart';
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
class ScrollerModel extends ViewableWidgetModel
{
  late BoxModel content;

  LayoutType get layoutType => BoxModel.getLayoutType(_layout, defaultLayout: LayoutType.column);

  String _layout = 'column';
  set layout(dynamic v)
  {
    if (v is String)
    {
      switch (v.toLowerCase().trim())
      {
        case 'row':
        case 'horizontal':
          _layout = 'row';
          break;
        default:
          _layout = 'column';
          break;
      }
    }
  }

  /// We want the scroller to expand in it cross axis by default
  /// and share space with its siblings.
  /// This can be done by returning a flex=1 to the parent box
  /// layout renderer
  @override
  int? get flex
  {
    if (super.flex != null) return super.flex;
    if (layoutType == LayoutType.row && !hasBoundedWidth) return 1;
    if (layoutType == LayoutType.column && !hasBoundedHeight) return 1;
    return null;
  }

  /// shadow attributes
  ///
  /// the color of the elevation shadow, defaults to black26
  ColorObservable? _shadowcolor;
  set shadowcolor(dynamic v)
  {
    if (_shadowcolor != null)
    {
      _shadowcolor!.set(v);
    }
    else if (v != null)
    {
      _shadowcolor = ColorObservable(Binding.toKey(id, 'shadowcolor'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color get shadowcolor => _shadowcolor?.get() ?? Colors.black26;

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

  ScrollerModel(WidgetModel parent, String? id, String? layout) : super(parent, id)
  {
    // build inner content
    switch (layoutType)
    {
      case LayoutType.row:
        content = RowModel(this, null);
        break;
      default:
        content = ColumnModel(this, null);
        break;
    }
  }

  static ScrollerModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    ScrollerModel? model;
    try
    {
      // build model
      model = ScrollerModel(parent, Xml.get(node: xml, tag: 'id'), Xml.get(node: xml, tag: 'layout') ?? Xml.get(node: xml, tag: 'direction'));
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
    scrollbar       = Xml.get(node: xml, tag: 'scrollbar');
    onscrolledtoend = Xml.get(node: xml, tag: 'onscrolledtoend');
    shadowcolor     = Xml.get(node: xml, tag: 'shadowcolor');
    onpulldown      = Xml.get(node: xml, tag: 'onpulldown');
    draggable       = Xml.get(node: xml, tag: 'draggable');

    // set the flex
    _buildContent();
  }

  _buildContent()
  {
    content.expand = false;

    // add children to the inner box
    if (children != null)
    {
      content.children ??= [];
      content.children!.addAll(children!);
    }

    // clear all children
    children?.clear();
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


