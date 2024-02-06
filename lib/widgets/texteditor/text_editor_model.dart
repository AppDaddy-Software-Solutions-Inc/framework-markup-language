// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/texteditor/text_editor_view.dart';
import 'package:fml/widgets/decorated/decorated_widget_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

class TextEditorModel extends DecoratedWidgetModel
{
  
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



  TextEditorModel(WidgetModel? parent, String? id, {dynamic value, dynamic language}) : super(parent, id)
  {
    if (value    != null) this.value = value;
  }
  
  static TextEditorModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    TextEditorModel? model;
    try
    {
      model = TextEditorModel(parent, Xml.get(node: xml, tag: 'id'));
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
  }

  @override
  dispose()
  {
    // Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  @override
  Widget getView({Key? key}) => getReactiveView(TextEditorView(this));
}
