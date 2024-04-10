// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/fml.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/navigation/navigation_manager.dart';
import 'package:fml/system.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fml/theme/theme.dart';
import 'package:provider/provider.dart';
import 'package:fml/event/event.dart';
import 'package:fml/helpers/helpers.dart';

// platform
import 'package:fml/platform/platform.vm.dart'
    if (dart.library.io) 'package:fml/platform/platform.vm.dart'
    if (dart.library.html) 'package:fml/platform/platform.web.dart';

class ApplicationManager extends StatefulWidget {
  final Widget? child;
  const ApplicationManager({super.key, this.child});
  @override
  State<ApplicationManager> createState() => _ApplicationManagerState();
}

class _ApplicationManagerState extends State<ApplicationManager> {
  @override
  void initState() {
    System().registerEventListener(EventTypes.open, onOpen);
    System().registerEventListener(EventTypes.refresh, onRefresh);
    System().registerEventListener(EventTypes.theme, onTheme);
    System().registerEventListener(EventTypes.openjstemplate, onOpenJsTemplate);
    // Allows for Javascript communication to FML
    Platform.js2fml();
    super.initState();
  }

  @override
  void dispose() {
    System().removeEventListener(EventTypes.open, onOpen);
    System().removeEventListener(EventTypes.refresh, onRefresh);
    System().removeEventListener(EventTypes.theme, onTheme);
    System().removeEventListener(EventTypes.openjstemplate, onOpenJsTemplate);
    super.dispose();
  }

  Future<bool> onOpen(Event event,
      {bool refresh = false, String? dependency}) async {
    // mark event as handled
    event.handled = true;

    // build parameters
    Map<String, String?>? parameters = <String, String?>{};
    if (event.parameters != null) parameters.addAll(event.parameters!);

    // get url parameters
    if (parameters.containsKey('url')) {
      Uri? uri = URI.parse(parameters['url']);
      if (uri?.queryParameters != null) parameters.addAll(uri!.queryParameters);
    }

    // build parameters from a data source
    if (parameters.containsKey('data') && event.model?.scope != null) {
      String? id = parameters['data'];
      IDataSource? source = event.model?.scope?.getDataSource(id);
      if (source?.data?.isNotEmpty ?? false) {
        source?.data?[0].forEach((key, value) {
          var id = Binding.toKey("${source.id}.${'data'}", key);
          if (value is String && id != null) {
            parameters[id] = source.data?[0][key];
          }
        });
      }
      parameters.remove('data');
    }

    // open the page
    return NavigationManager().open(parameters,
        model: event.model, dependency: dependency, refresh: refresh);
  }

  bool onOpenJsTemplate(Event event) {
    // mark event as handled
    event.handled = true;

    // build parameters
    Map<String, String?>? parameters = {};

    if (event.parameters != null) parameters.addAll(event.parameters!);

    String templ8 = parameters['templ8'] ??
        '<FML><TEXT value="Template Parsing Error" /></FML>';

    // open the template
    return NavigationManager().openJsTemplate(templ8);
  }

  // refresh the application
  void onRefresh(Event event) async => await NavigationManager().refresh();

  void onTheme(Event event) async {
    var brightness =
        event.parameters?['brightness']?.trim().toLowerCase() == 'dark'
            ? Brightness.dark
            : Brightness.light;
    var color = toColor(event.parameters?['color']) ??
        System.theme.colorScheme ??
        FmlEngine.defaultColor;
    var font =
        event.parameters?['font'] ?? System.theme.font ?? FmlEngine.defaultFont;

    var notifier = Provider.of<ThemeNotifier>(context, listen: false);
    notifier.setTheme(brightness: brightness, color: color, font: font);
  }

  @override
  Widget build(BuildContext context) {
    Widget view = Stack(children: [widget.child!]);

    // set system width/height bindables
    // necessary to keep setting this for
    // web and desktop as screen sizes can change
    System().screenheight = MediaQuery.of(context).size.height;
    System().screenwidth = MediaQuery.of(context).size.width;

    return view;
  }
}
