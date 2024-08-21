// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.

import 'package:fml/data/data.dart';

class Tag {
  String? id;
  int? antenna;
  int? rssi;
  int? distance;
  int? count;
  String? data;
  String? lock;
  int?    size;
  Map<String, String?>? parameters;
}

class Payload {
  final List<Tag> tags = [];
  Payload({List<Tag>? tags}) {
    if (tags != null) this.tags.addAll(tags);
  }

  static Data toData(Payload payload) {
    Data data = Data();

    // sort by RSSI
    payload.tags.sort((a, b) => (a.rssi ?? 0).compareTo(b.rssi ?? 0));

    // build the payload
    for (var tag in payload.tags) {
      Map<dynamic, dynamic> map = <dynamic, dynamic>{};
      map["id"]       = tag.id;
      map["antenna"]  = tag.antenna;
      map["rssi"]     = tag.rssi;
      map["distance"] = tag.distance;
      map["count"]    = tag.count;
      map["size"]     = tag.size;
      map["data"]     = tag.data;
      map["lock"]     = tag.lock;
      data.add(map);
    }
    return data;
  }
}