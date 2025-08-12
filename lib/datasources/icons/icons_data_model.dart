// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async' show Completer;

import 'package:fml/data/data.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/graphics.dart' deferred as icons;
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/datasources/base/model.dart';
import 'package:xml/xml.dart';
import 'package:fml/helpers/helpers.dart';

class IconsDataModel extends DataSourceModel implements IDataSource {

  static Completer? libraryLoader;

  @override
  bool get autoexecute => true;

  IconsDataModel(super.parent, super.id, {dynamic datastring}) {

    // load the library
    if (libraryLoader == null) {
      libraryLoader = Completer();
      icons.loadLibrary().then((value) => libraryLoader!.complete(true));
    }

    // wait for the library to load
    if (!libraryLoader!.isCompleted) {
      libraryLoader!.future.whenComplete(() {
        var data = _generate();
        onSuccess(data, code: 200, message: "Ok");
      });
    }
  }

  static IconsDataModel? fromXml(Model parent, XmlElement xml) {
    IconsDataModel? model = IconsDataModel(parent, Xml.get(node: xml, tag: 'id'));
    model.deserialize(xml);
    return model;
  }

  static Data _generate() {
    Data data = Data();
    for (var key in icons.Graphics.icons.keys) {
      var row = <String, dynamic>{};
      row["icon"] = key;
      data.add(row);
    }
    return data;
  }
}
