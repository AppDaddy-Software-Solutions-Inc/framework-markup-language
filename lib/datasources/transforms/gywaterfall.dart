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

  StringObservable? _color;
  set color(dynamic v) {
    if (_color != null) {
      _color!.set(v);
    } else if (v != null) {
      _color = StringObservable(Binding.toKey(id, 'color'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String? get color => _color?.get();

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
      {String? id, String? x, String? y, String? color, String? group})
      : super(parent, id) {
    this.x = x;
    this.y = y;
    this.color = color;
    this.group = group;
  }

  static GYWaterfall? fromXml(Model? parent, XmlElement xml) {
    GYWaterfall model = GYWaterfall(parent,
        id: Xml.get(node: xml, tag: 'id'),
        x: Xml.get(node: xml, tag: "x"),
        y: Xml.get(node: xml, tag: "y"),
        color: Xml.get(node: xml, tag: "color"),
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
    Data result = Data();
    // build new list of data
    dynamic previousGroup;
    bool groupStart = false;
    var len = data.length;
    int i = 0;



    for (var row in data) {
      i += 1;
      var xValue = Data.read(row, x);
      double yValue = toDouble(Data.read(row, y)) ?? 0;
      var groupValue = Data.read(row, group);
      var colorValue = Data.read(row, color);

      if (result.isEmpty) {
        //add the empty initial result starting at 100
        //set the starting label to total capacity
        Map<String, dynamic> newData = <String, dynamic>{};
        newData["x"] = 'Total Capacity';
        //y0 is the fromy value
        newData["y0"] = "0";
        //y is the toy value
        newData["y"] = "100";
        newData["group"] = groupValue;
        newData["color"] = toColor('random');
        result.add(newData);

        Map<String, dynamic> newData2 = <String, dynamic>{};
        //set the x, y0, y, and group values
        newData2["x"] = xValue;
        //the fromy becomes the previous y value
        newData2["y0"] = "${(100 - yValue)}";
        newData2["y"] = "100";
        newData2["group"] = groupValue;
        newData2["color"] = colorValue;
        newData2.addAll(row);
        result.add(newData2);
        previousGroup = groupValue;
      } else {
        //ensure we are not within the first two elements of the result
        if (groupValue != previousGroup && result.length > 2) {
          Map<String, dynamic> newData = <String, dynamic>{};
          //Set the label to the group value
          newData["x"] = groupValue;
          //fromy will be 0
          newData["y0"] = "0";
          //toY will be the previous values fromy
          newData["y"] = result.last["y0"];
          newData["group"] = groupValue;
          newData["color"] =  result.last["color"];
          result.add(newData);
          groupStart = true;
        }

        //we then add the current point here
        if (groupStart) {
          Map<String, dynamic> newData = <String, dynamic>{};
          //set the x, y0, y, and group values
          newData["x"] = xValue;
          //the fromy becomes the previous y value minus the previous to y value
          newData["y"] = result.last["y"];
          double d1 = toDouble(result.last["y"]) ?? 0;
          newData["y0"] = "${d1 - yValue}";
          newData["group"] = groupValue;
          newData["color"] = colorValue;
          newData.addAll(row);
          result.add(newData);
          groupStart = false;
        } else {
          Map<String, dynamic> newData = <String, dynamic>{};
          //set the x, y0, y, and group values
          newData["x"] = xValue;
          //the fromy becomes the previous y value
          newData["y"] = result.last["y0"];
          double d1 = toDouble(result.last["y0"]) ?? 0;
          newData["y0"] = "${d1 - yValue}";
          newData["group"] = groupValue;
          newData["color"] = colorValue;
          newData.addAll(row);
          result.add(newData);
        }
        previousGroup = groupValue;
        //check if the loop is on its last item
        if(i == len){
          Map<String, dynamic> newData = <String, dynamic>{};
          //Set the label to the group value
          newData["x"] = groupValue;
          //fromy will be 0
          newData["y0"] = "0";
          //toY will be the previous values fromy
          newData["y"] = result.last["y0"];
          newData["group"] = groupValue;
          newData["color"] = colorValue;
          result.add(newData);
        }
      }
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
