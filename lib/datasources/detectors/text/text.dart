// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/datasources/detectors/detectable/detectable.dart';
import 'package:fml/data/data.dart';

import 'text.mobile.dart'
if (dart.library.io)   'text.mobile.dart'
if (dart.library.html) 'text.web.dart';
//import 'stub.dart';

class Line
{
  String? text;
  List<String> words = [];
  Line({this.text});
}

class Payload
{
  final String? body;
  final List<Line>? lines;
  Payload({this.body, this.lines});

  static Data toData(Payload payload)
  {
    Data data = Data();

    // process lines
    int i = 0;
    if (payload.lines != null)
    payload.lines!.forEach((line)
    {
      i++;

      Map<dynamic, dynamic> map = Map<dynamic, dynamic>();
      data.add(map);
      map["body"] = (i == 1 ? payload.body : null);
      map["line"] = line.text;

      int j = 1;
      line.words.forEach((word) => map["word" + (j++).toString()] = word);
    });
    return data;
  }
}

abstract class TextDetector
{
  factory TextDetector() => getDetector();
  Future<Payload?> detect(DetectableImage image);
}
