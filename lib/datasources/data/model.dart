// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:convert';

import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:fml/data/data.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/observable/observable.dart';
import 'package:fml/observable/observables/string.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/datasources/base/model.dart';
import 'package:xml/xml.dart';
import 'package:fml/helper/common_helpers.dart';

class DataModel extends DataSourceModel implements IDataSource
{


  // value
  StringObservable? _datastring;

  set datastring(dynamic v)
  {
    if (_datastring != null)
    {
      _datastring!.set(v);
    }
    else
    {
      if ((v != null) || (WidgetModel.isBound(this, Binding.toKey(id, 'datastring')))) {
        _datastring = StringObservable(Binding.toKey(id, 'datastring'), v, scope: scope, listener: onPropertyChange);
      }
    }
  }
  String? get datastring => _datastring?.get();

  @override
  bool get autoexecute => super.autoexecute ?? true;


  DataModel(WidgetModel parent, String? id, {dynamic datastring}) : super(parent, id){
    if (datastring != null) this.datastring = datastring;
  }


  static DataModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    DataModel? model;
    try
    {
      model = DataModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }catch(e)
    {
      Log().exception(e, caller: 'data.Model');
      model = null;
    }
    return model;
  }

    /// Deserializes the FML template elements, attributes and children
    @override
    void deserialize(XmlElement xml){
      super.deserialize(xml);
      datastring = Xml.get(node: xml, tag: 'data');
    }

    @override
    void onPropertyChange(Observable observable) {
    //super.onPropertyChange(observable);
    final datastring = this.datastring;
    var v;
    if(datastring != null) {
      v = datastring.replaceAllMapped(RegExp(r'((?<={|,).*?(?=:))|((?<=:).*?(?=}|,))'), (match) {
        return '"${match.group(0)?.trim()}"';
      });
      onSuccess(Data.from(v, root: root));
    }
  }



}
