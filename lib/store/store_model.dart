// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/application/application_model.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/widget/model.dart';

class StoreModel extends Model {

  bool initialized = false;

  static final StoreModel _singleton = StoreModel._initialize();
  factory StoreModel() => _singleton;
  StoreModel._initialize() : super(null, "STORE");

  Future addApp(ApplicationModel app) async {
    busy = true;

    // add the application
    bool ok = await System.addApplication(app);

    // notify
    if (!ok) System.toast('Failed to add the application');

    busy = false;
  }

  Future deleteApp(ApplicationModel app) async {
    busy = true;

    // delete the application
    bool ok = await System.deleteApplication(app);

    // notify
    if (!ok) System.toast('Failed to delete the application');

    busy = false;
  }

  ApplicationModel? findApp({String? url}) {

    // find app with matching url
    for (var app in System.apps)
    {
      if (app.url == url) return app;
    }
    return null;
  }
}
