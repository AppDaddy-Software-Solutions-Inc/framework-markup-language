// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/datasources/gps/payload.dart';
import 'package:fml/observable/observable_barrel.dart';

abstract class IFormField
{
  // field id
  String? get id;

  // field type
  String get elementName;

  // field value
  dynamic get value;
  set value (dynamic v);

  // field default value
  dynamic get defaultValue;
  set defaultValue (dynamic v);

  // field default error
  dynamic get error;
  set error (dynamic v);

  // field metadata
  dynamic get meta;
  set meta (dynamic v);

  // field is required
  bool? get mandatory;
  set mandatory (dynamic v);

  // field is required
  String? get systemerrortext;
  set systemerrortext (dynamic v);


  // field has been manually updated
  bool? touched = false;

  // field has been edited
  bool? get dirty;
  set dirty (dynamic b);
  BooleanObservable? get dirtyObservable;

  // fielf is editable
  bool? get editable;
  set editable (dynamic v);

  // field is enabled for edit
  bool get enabled;
  set enabled (dynamic v);

  // return value as a list
  List<String>? get values;

  // question has been answered
  bool get answered;

  // set the field answer
  Future<bool> answer(dynamic value);

  bool? get alarming;

  bool? get hasDefaulted;
  set hasDefaulted(dynamic v);

  bool? get validationHasHit;
  set validationHasHit(dynamic v);

  /// GeoCode for each [IFormField] which is set on answer
  Payload? geocode;

  // field is postable?
  bool? post;
  bool? get postable;

  // field name overrides id if specified
  String? field;
}