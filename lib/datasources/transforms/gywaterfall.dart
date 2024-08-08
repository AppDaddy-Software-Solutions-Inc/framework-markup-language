// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/transforms/transform_interface.dart';
import 'package:fml/datasources/transforms/transform_model.dart';
import 'package:fml/log/manager.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

class GYWaterfall extends TransformModel implements ITransform {
  // column
  StringObservable? _x;
  set x(dynamic v) {
    if (_x != null) {
      _x!.set(v);
    } else if (v != null) {
      _x = StringObservable(Binding.toKey(id, 'x'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String? get x => _x?.get();

  // row
  StringObservable? _y;
  set y(dynamic v) {
    if (_y != null) {
      _y!.set(v);
    } else if (v != null) {
      _y = StringObservable(Binding.toKey(id, 'y'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String? get y => _y?.get();

  // The group used to group each waterfall section
  StringObservable? _group;
  set group(dynamic v) {
    if (_group != null) {
      _group!.set(v);
    } else if (v != null) {
      _group = StringObservable(Binding.toKey(id, 'group'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String? get group => _group?.get();



 GYWaterfall(Model? parent,
      {String? id, String? x, String? y, String? group})
      : super(parent, id) {
    this.x = x;
    this.y = y;
    this.group = group;
  }

  static GYWaterfall? fromXml(Model? parent, XmlElement xml) {
    GYWaterfall model = GYWaterfall(parent,
        id: Xml.get(node: xml, tag: 'id'),
        x: Xml.get(node: xml, tag: "x"),
        y: Xml.get(node: xml, tag: "y"),
        group: Xml.get(node: xml, tag: "group"),);
    model.deserialize(xml);
    return model;
  }

  @override
  void deserialize(XmlElement xml) {
    // Deserialize
    super.deserialize(xml);
  }

  Data? _waterfall(Data data) {
    bool xFound = false;
    bool yFound = false;
    bool groupFound = false;
    Data result = Data();
    // build new list of data
    dynamic previousGroup;





    for (var row in data) {
      Map<String, dynamic> newData = <String, dynamic>{};
      var xValue = Data.read(row, x);
      var yValue = Data.read(row, y);
      var groupValue = Data.read(row, group);

      if (result.isEmpty) {
        //this will be set to 0-100 in the chart
        newData["$x"] = 'Total Capacity';
        newData["$y"] = 100;
        newData["$group"] = groupValue;
        result.add(newData);
      }

      newData["$x"] = xValue;
      newData["$y"] = yValue;
      newData["$group"] = groupValue;
      result.add(newData);

      //ensure we are not within the first two elements of the result
      if(groupValue != previousGroup && result.length > 2){
        //Set the X to the group value
        newData["$x"] = groupValue;
        newData["$y"] = 0;
        newData["$group"] = groupValue;
        result.add(newData);
      }

      previousGroup = groupValue;




    }



    return result;
  }

  @override
  apply(Data? data) async {
    if (enabled == false) return;
    Data? result;
    try {
      if (data != null) result = _waterfall(data);
    } catch (e) {
      Log().exception(e);
    }

    if (result != null) {
      data!.clear();
      data.addAll(result);
    }
  }
}
