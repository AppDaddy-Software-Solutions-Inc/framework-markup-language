// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/editor/editor_view.dart';
import 'package:fml/widgets/widget/decorated_widget_model.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class EditorModel extends DecoratedWidgetModel implements IViewableWidget
{
  // theme
  StringObservable? _theme;
  set theme(dynamic v)
  {
    if (_theme != null)
    {
      _theme!.set(v);
    }
    else
    {
      if (v != null) _theme = StringObservable(Binding.toKey(id, 'theme'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get theme => _theme?.get();
  
  // value
  StringObservable? _value;
  set value(dynamic v)
  {
    if (_value != null)
    {
      _value!.set(v);
    }
    else
    {
      if (v != null) _value = StringObservable(Binding.toKey(id, 'value'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get value => _value?.get();

  // language
  StringObservable? _language;
  set language(dynamic v)
  {
    if (_language != null)
    {
      _language!.set(v);
    }
    else
    {
      if (v != null) _language = StringObservable(Binding.toKey(id, 'language'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String get language => _language?.get() ?? "xml";

  EditorModel(WidgetModel? parent, String? id, {dynamic value, dynamic language}) : super(parent, id)
  {
    if (value    != null) this.value = value;
    if (language != null) this.language = language;
  }
  
  static EditorModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    EditorModel? model;
    try
    {
      model = EditorModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e, caller: 'EditorModel');
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

    value    = Xml.get(node: xml, tag: 'value');
    language = Xml.get(node: xml, tag: 'language')?.toLowerCase().trim();
    theme    = Xml.get(node: xml, tag: 'theme');
  }

  @override
  dispose()
  {
    // Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  @override
  Widget getView({Key? key}) => getReactiveView(EditorView(this));
}
