// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:collection';
import 'package:fml/helper/common_helpers.dart';

class NotationSegment
{
  String name = "";
  int  offset = 0;
}

class DotNotation with ListMixin<NotationSegment?>
{
  final List<NotationSegment?> _list = [];
  final String signature;

  DotNotation(this.signature);

  @override
  void add(NotationSegment? property) => _list.add(property);

  @override
  void addAll(Iterable<NotationSegment?> properties) => _list.addAll(properties);

  @override
  void operator []=(int index, NotationSegment? property) => _list[index] = property;

  @override
  NotationSegment? operator [](int index) => _list[index];

  @override
  set length(int newLength) => _list.length = newLength;

  @override
  int get length => _list.length;

  static DotNotation? fromString(String? string)
  {
    if (string == null) return null;

    DotNotation? dotnotation;

    // build sub-properties (name and offset) list
    List<String> parts = string.split(".");
    if (parts.isNotEmpty)
    {
      dotnotation = DotNotation(string);
      for (String part in parts)
      {
        // split by name:offset
        List<String> subparts = part.split(":");

        NotationSegment property = NotationSegment();

        // set name
        if (subparts.isNotEmpty)
        {
          property.name = subparts[0].trim();
          subparts.removeAt(0);
        }

        // set offset
        if (subparts.isNotEmpty)
        {
          String offset = subparts[0].trim();
          if (offset == "*") offset = "-1";
          property.offset = S.toInt(offset) ?? 0;
          subparts.removeAt(0);
        }

        // add to the list
        dotnotation.add(property);
      }
    }
    return dotnotation;
  }
}