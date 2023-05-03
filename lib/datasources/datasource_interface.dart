// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'datasource_listener_interface.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/observable/observable_barrel.dart';

abstract class IDataSource
{
  String get id;
  Data? get data;
  bool get busy;
  bool? initialized;
  bool? autoexecute;

  StringObservable? get bodyObservable;
  String? body;
  String? root;
  bool get custombody;

  WidgetModel? get parent;

  Future<bool> start({bool refresh = false, String? key});
  Future<bool> stop();
  Future<bool> clear({int? start, int? end});
  register(IDataSourceListener listener);
  remove(IDataSourceListener listener);
  Future<bool> onSuccess(Data data, {int? code, String? message, Observable? onSuccessOverride});
  notify();
  dispose();
}