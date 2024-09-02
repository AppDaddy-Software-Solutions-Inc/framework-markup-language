// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.

import 'package:fml/data/data.dart';

class Tag {
  String? source;
  String? id;
  int? antenna;
  int? rssi;
  int? distance;
  String? memoryBankData;
  String? lockData;
  int?    size;
  String? seen;
  Map<String, String?>? parameters;
}

class Payload {
  final List<Tag> tags = [];
  Payload({List<Tag>? tags}) {
    if (tags != null) this.tags.addAll(tags);
  }

  static Data toData(Payload payload) {
    Data data = Data();

    // build the payload
    for (var tag in payload.tags) {
      Map<dynamic, dynamic> map = <dynamic, dynamic>{};
      map["source"]   = tag.source;
      map["id"]       = tag.id;
      map["antenna"]  = tag.antenna;
      map["rssi"]     = tag.rssi;
      map["distance"] = tag.distance;
      map["size"]     = tag.size;
      map["data"]     = tag.memoryBankData;
      map["lock"]     = tag.lockData;
      map["seen"]     = tag.seen;
      data.add(map);
    }
    return data;
  }
}