// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/application/application_model.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/widget/widget_model_interface.dart';
import 'package:fml/widgets/widget/widget_model.dart';

class Store extends WidgetModel implements IModelListener {

  bool initialized = false;

  static final Store _singleton = Store._initialize();
  factory Store() => _singleton;
  Store._initialize() : super(null, "STORE") {
    init();
  }

  init() async {
    initialized = await _initialize();
  }

  Future<bool> _initialize() async {

    busy = true;

    // register a listener to each app
    for (var app in System.apps) {
      app.registerListener(this);
    }

    busy = false;
    return true;
  }

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

  @override
  onModelChange(WidgetModel model, {String? property, value}) {
    notifyListeners(property, value);
  }
}
