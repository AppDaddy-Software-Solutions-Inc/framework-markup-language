// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:fml/widgets/widget/decorated_widget_model.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:xml/xml.dart';

import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/widgets/breadcrumb/breadcrumb_view.dart';
import 'package:fml/helper/helper_barrel.dart';

/// Breadcrumb Model
///
/// Defines the properties of [BREADCRUMB.BreadcrumbView] widget
class BreadcrumbModel extends DecoratedWidgetModel implements IViewableWidget
{
  /// background color of the breadcrumb bar
  ColorObservable? _backgroundcolor;
  set backgroundcolor (dynamic v)
  {
    if (_backgroundcolor != null)
    {
      _backgroundcolor!.set(v);
    }
    else if (v != null)
    {
      _backgroundcolor = ColorObservable(Binding.toKey(id, 'backgroundcolor'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get backgroundcolor => _backgroundcolor?.get();

  /// Opacity
  DoubleObservable? _opacity;
  set opacity (dynamic v)
  {
    if (_opacity != null)
    {
      _opacity!.set(v);
    }
    else if (v != null)
    {
      _opacity = DoubleObservable(Binding.toKey(id, 'opacity'), v, scope: scope, listener: onPropertyChange);
    }
  }
  double? get opacity => _opacity?.get();

  /// Width of the breadcrumbs and bar
  DoubleObservable? _width;
  set width (dynamic v)
  {
    if (_width != null)
    {
      _width!.set(v);
    }
    else if (v != null)
    {
      _width = DoubleObservable(Binding.toKey(id, 'width'), v, scope: scope, listener: onPropertyChange);
    }
  }
  double? get width => _width?.get();

  BreadcrumbModel({
    WidgetModel? parent,
    String? id,
    dynamic height,
    dynamic color,
    dynamic backgroundcolor,
    dynamic opacity,
    dynamic width,
  }) : super(parent, id)
  {
    this.height   = height;
    this.color    = color;
    this.backgroundcolor = backgroundcolor;
    this.opacity = opacity;
    this.width = width;
  }

  static BreadcrumbModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    BreadcrumbModel? model;
    try
    {
      /////////////////
      /* Build Model */
      /////////////////
      model = BreadcrumbModel(parent: parent);
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'breadcrumb.Model');
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
    backgroundcolor = Xml.get(node: xml, tag: 'backgroundcolor');
    opacity         = Xml.get(node: xml, tag: 'opacity');
  }

  @override
  dispose()
  {
    Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  @override
  Widget getView({Key? key}) => BreadcrumbView(this);
}