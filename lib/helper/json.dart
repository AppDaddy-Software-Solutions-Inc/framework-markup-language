// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/dotnotation.dart';
import 'package:fml/helper/xml.dart';
import 'package:fml/observable/binding.dart';


class Json
{
  static String? get({required dynamic json, String? tag})
  {
    String? v;
    try
    {
      if (json.containsKey(tag))
      {
        if (json[tag] is String) v = json[tag];
        else if (json[tag] is Map) v = json[tag].values.first;
      }
    }
    catch(e)
    {
      v = null;
    }
    return v;
  }

  static dynamic find(dynamic json, String tag)
  {
    dynamic data = json;
    if ((data == null) || (data.isEmpty)) return null;

    // Get Dot Notation
    DotNotation? dotNotation = DotNotation.fromString(tag);

    if (data is List<dynamic>) data = data.isNotEmpty ? data[0] : null;

    if (dotNotation != null)
    for (NotationSegment? property in dotNotation)
    if (property != null)
    {
      if (data is Map)
      {
        if (!data.containsKey(property.name))
        {
          data = null;
          break;
        }
        data = data[property.name];

          if ((data is Map)  && (property.offset > 0)) data = null;
          if ((data is List) && (property.offset > data.length)) data = null;
          if ((data is List) && (property.offset < data.length) && (property.offset >= 0))  data = data[property.offset];

      }

      else if (data is List)
      {
        if (data.length < property.offset)
        {
          data = null;
          break;
        }
        data = data[property.offset];
        if ((data is Map) && (data.containsKey(property.name))) data = data[property.name];
      }

      else
      {
        data = null;
        break;
      }
    }

    // this is a very odd case. if the element contains attributes, the element value will be put into a
    // map field called "value" and its attributes will be mapped to underscore (_) names _attributename
    if ((data is Map) && (data.containsKey('value'))) data = data['value'];

    // return result;
    return data;
  }

  static String? replace(String? string, dynamic json)
  {
    // replace bindings
    List<Binding>? bindings = Binding.getBindings(string);
    if (bindings != null)
      for (Binding binding in bindings)
      {
        // fully qualified data binding name (data.value.x.y.)
        if ((binding.source.toLowerCase() == 'data'))
        {
          String signature = binding.property + (binding.dotnotation?.signature != null ? ".${binding.dotnotation!.signature}" : "");
          String value = Xml.encodeIllegalCharacters(find(json,signature)) ?? "";
          string = string!.replaceAll(binding.signature, value);
        }
      }
    return string;
  }

  static Map<String?, dynamic> getVariables(List<Binding>? bindings, dynamic json)
  {
    Map<String?, dynamic> variables = Map<String?, dynamic>();

    List<String?> processed = [];
    // replace bindings
    if (bindings != null)
      for (Binding binding in bindings)
      {
        // fully qualified data binding name (datasource.data.field1.field2.field3...fieldn)
        if ((binding.source == 'data'))
        {
          String? signature = binding.property + (binding.dotnotation?.signature != null ? ".${binding.dotnotation!.signature}" : "");
          if (!processed.contains(binding.signature))
          {
            processed.add(binding.signature);
            var value = find(json,signature) ?? "";
            variables[binding.signature] = value;
          }
        }
      }
    return variables;
  }
}