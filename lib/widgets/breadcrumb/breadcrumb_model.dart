// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:fml/widgets/decorated/decorated_widget_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/widgets/breadcrumb/breadcrumb_view.dart';
import 'package:fml/helpers/helpers.dart';

/// Breadcrumb Model
///
/// Defines the properties of [BREADCRUMB.BreadcrumbView] widget
class BreadcrumbModel extends DecoratedWidgetModel 
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
    // constraints
    if (height != null) this.height = height;
    if (width  != null) this.width  = width;

    this.color    = color;
    this.backgroundcolor = backgroundcolor;
    this.opacity = opacity;
  }

  static BreadcrumbModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    BreadcrumbModel? model;
    try
    {
// build model
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
  Widget getView({Key? key}) => getReactiveView(BreadcrumbView(this));
}