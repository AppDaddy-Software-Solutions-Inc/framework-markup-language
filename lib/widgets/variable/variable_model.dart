// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:fml/event/handler.dart' ;
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class VariableModel extends WidgetModel
{
  ///////////
  /* Value */
  ///////////
  StringObservable? _value;
  set value (dynamic v)
  {
    if (_value != null)
    {
      _value!.set(v);
    }
    else
    {
      if ((v != null) || (WidgetModel.isBound(this, Binding.toKey(id, 'value')))) _value = StringObservable(Binding.toKey(id, 'value'), v, scope: scope, listener: onPropertyChange);
    }
  }
  dynamic get value => _value?.get();

  //////////////
  /* onchange */
  //////////////
  StringObservable? _onchange;
  set onchange (dynamic v)
  {
    if (_onchange != null)
    {
      _onchange!.set(v);
    }
    else if (v != null)
    {
      _onchange = StringObservable(Binding.toKey(id, 'onchange'), v, scope: scope, lazyEval: true);
    }
  }
  String? get onchange => _onchange?.get();

  //////////////////////
  /* Return Parameter */
  //////////////////////
  String? _returnas;
  set returnas (dynamic v)
  {
    if ((v != null) && (v is String)) _returnas =  v.trim().toLowerCase();
  }
  String? get returnas => _returnas;

  VariableModel(
      WidgetModel parent,
      String? id,
      {String? type, dynamic value, dynamic onchange, }) : super(parent, id)
  {
    if (value    != null) this.value    = value;
    if (onchange != null) this.onchange = onchange;
  }

  static VariableModel? fromXml(WidgetModel parent, XmlElement xml, {String? type})
  {
    VariableModel? model;
    try
    {
      model = VariableModel(parent, Xml.get(node: xml, tag: 'id'), type: type);
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e, caller: 'variable.Model');
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
    value      = Xml.get(node: xml, tag: 'value');
    onchange   = Xml.get(node: xml, tag: 'onchange');
    returnas   = Xml.get(node: xml, tag: 'return');
  }

  Future<bool> onChange() async
  {
    bool ok = true;

    if (!S.isNullOrEmpty(onchange))
    {
      // This is Hack in Case Onchange Is Bound to Its own Value
      if (_onchange!.bindings != null) _onchange!.onObservableChange(null);

      // fire onchange event
      ok = await EventHandler(this).execute(_onchange);
    }

    return ok;
  }

  @override
  void dispose()
  {
    //if (global && !persistent) System().scope.removeDataSource(this);
    super.dispose();
  }

  @override
  void onPropertyChange(Observable observable)
  {
    onChange();
  }
}