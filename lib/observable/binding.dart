// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/helper/common_helpers.dart';
import 'package:fml/data/dotnotation.dart';
import 'package:fml/observable/scope.dart';

class Binding
{
  // This regex procures bindings from within FML/XML/JSON/Text
  // It allows for bindings using alphanumeric in any combination with `.` `:` `_` `-`
  // its not case sensitive and allows for spaces around the opening bracket `{`
  // and around the closing bracket `}` but not anywhere within the binding itself
  // See it in action: https://regex101.com/r/nEPb2T/2

  static final RegExp reg = RegExp("\\{(\\s*?\\S[a-zA-Z0-9.:_-]*?\\s*?)\\}");
  // Explanation:
  // `\\{` => starts with {
  // `(` => start of Matching Group
  // `\\s*?` => any number of spaces
  // `\\S` => must not contain only whitespace
  // `[a-zA-Z0-9.:_-]*?` => character match alphanumeric (case-insensitive), [., :, _, -] any number of times
  // `\\s*?` => any number of spaces
  // `)` => end of Matching Group
  // `\\}` => ends with }

  //////////////////////////////////////////////
  /**                                        **/
  /**   scope@source.propertry:offset        **/
  /**                                        **/
  /**   scope    - default local scope tree  **/
  /**   source   - required                  **/
  /**   property - default 'value'           **/
  /**   offset   - default 0                 **/
  /**                                        **/
  //////////////////////////////////////////////

  final String? scope;
  final String signature;
  final String source;
  final String property;
  final DotNotation? dotnotation;
  final bool? isEval;
  final int? offset;

  String? get key => toKey(source, property);

  static String? toKey(String? source, String? property)
  {
    if ((source == null) || (property == null)) return null;
    return (source + '.' + property).toLowerCase();
  }

  Binding({this.scope, required this.signature, required this.source, required this.property, this.isEval, this.dotnotation, this.offset});

  static Binding? fromString(String? binding, {Scope? bindingscope})
  {
    if (binding == null) return null;
    try
    {
      String signature = binding.trim();

      // remove braces
      binding = binding.trim();
      if (binding.startsWith("{")) binding = binding.substring(1);
      if (binding.endsWith("}"))   binding = binding.substring(0, binding.length - 1);

      String? scope;
      String? source;
      String? property;
      int? offset;

      // scope
      List<String> parts = binding.split('@');
      if (parts.length > 1)
      {
        scope = parts[0].trim();
        binding = parts[1];
      }

      // split binding signature int source.property
      parts = binding.split('.');

      // source id
      if (parts.isNotEmpty)
      {
        source = parts[0].trim();
        parts.removeAt(0);
        if (source.contains(":"))
        {
          List<String> parts = source.split(':');
          source = parts[0].trim();
          offset = S.toInt(parts[1]);
        }
      }

      // property name
      if (parts.isNotEmpty)
      {
        property = parts[0].trim();
        parts.removeAt(0);
        if (property.contains(":"))
        {
          List<String> parts = property.split(':');
          property = parts[0].trim();
          offset = S.toInt(parts[1]);
        }
      }

      // build sub-properties (name and offset) list
      DotNotation? subproperties;
      if (parts.isNotEmpty)
      {
        String? name;
        for (String part in parts) name = (name == null) ? part : "$name.$part";
        subproperties = DotNotation.fromString(name);
      }

      // default property is "value"
      if (S.isNullOrEmpty(property)) property = 'value';

      // create the bindable
      if (source!.isNotEmpty) return Binding(scope: scope, signature: signature, source: source, property: property!, dotnotation: subproperties, offset: offset);
    }
    catch(e) {}
    return null;
  }

  dynamic translate(dynamic value)
  {
    try
    {
      var v = value;

      // not found
      if (v == null) return null;

      // found value
      if (v is String) return value;

      // parse
      if (v is List)
      {
        if ((offset != null) && (offset! >= 0) && (v.length > offset!)) v = v[offset!];
        if (dotnotation != null) v = Data.findValue(v,dotnotation?.signature);
      }

      // nothing
      return v;
    }
    catch(e)
    {
      return null;
    }
  }

  static bool hasBindings(String? s)
  {
    if (s == null) return false;
    bool match = reg.hasMatch(s);
    return match;
  }

  static List<Binding>? getBindings(String? s, {Scope? scope})
  {
    if (s == null) return null;
    List<Binding>? bindings;
    List<String?>? bindingStrings = getBindingStrings(s);
    if (bindingStrings != null)
      for (String? binding in bindingStrings)
      {
        Binding? property = Binding.fromString(binding, bindingscope: scope);

        if (property != null)
        {
          if (bindings == null) bindings = [];
          bindings.add(property);
        }
      }
    return bindings;
  }

  static List<String?>? getBindingStrings(String s)
  {
    List<String?>? bindings;
    Iterable<Match> matches = reg.allMatches(s);
      for (Match m in matches)
      {
        String? binding = m.group(0);
        if (bindings == null) bindings = [];
        bindings.add(binding);
      }
    return bindings;
  }

  static List<String?>? getBindingKeys(String s)
  {
    List<String?>? keys;
    List<Binding>? bindings = getBindings(s);
    if (bindings != null)
    {
      keys = [];
      bindings.forEach((binding) => keys!.contains(binding.key) ? null : keys.add(binding.key));
    }
    return keys;
  }

  static String? applyMap(String? xml, Map? map, {String? source, bool caseSensitive: true, String? prefix, bool encode = false})
  {
    if ((map != null) && (xml != null))
      map.forEach((key, value)
      {
        String oldValue = "{" + (S.isNullOrEmpty(prefix) ? (S.isNullOrEmpty(source) ? '' : source! + '.') : prefix!) + key.toString() + "}";
        String? newValue = (value ?? '').toString();
        if ((encode) && (Xml.hasIllegalCharacters(newValue))) newValue = Xml.encodeIllegalCharacters(newValue);

        if (caseSensitive)
          xml = xml!.replaceAll(oldValue, newValue!);
        else {
          try
          {
            xml = xml!.replaceAll(RegExp(oldValue, caseSensitive: false), newValue!);
          }
          catch(e)
          {
            xml = xml!.replaceAll(oldValue.toLowerCase(), newValue!);
            xml = xml!.replaceAll(oldValue.toUpperCase(), newValue);
            xml = xml!.replaceAll(oldValue, newValue);
          }
        }
      });
    return xml;
  }
}