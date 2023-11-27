import 'package:flutter/rendering.dart';
import 'package:fml/observable/observables/string.dart';

abstract class IDragDrop {

  String get id;

  set data(dynamic v);
  dynamic get data;

  set drop(dynamic v);
  dynamic get drop;

  StringObservable? onDropObservable;
  StringObservable? onDroppedObservable;
  StringObservable? onDragObservable;
  List<String>? accept;

  bool willAccept(IDragDrop draggable);
  void onDrop(IDragDrop draggable, {Offset? dropSpot});
  void onDrag();
}