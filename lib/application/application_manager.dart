// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/services.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/event/manager.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/navigation/navigation_manager.dart';
import 'package:fml/system.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fml/theme/themenotifier.dart';
import 'package:fml/widgets/framework/framework_view.dart';
import 'package:provider/provider.dart';
import 'package:fml/event/event.dart' ;
import 'package:fml/widgets/framework/framework_model.dart' ;
import 'package:fml/helper/common_helpers.dart';

class ApplicationManager extends StatefulWidget
{
  final Widget? child;
  ApplicationManager({Key? key, this.child}) : super(key: key);
  @override
  State<ApplicationManager> createState() => _ApplicationManagerState();
}

class _ApplicationManagerState extends State<ApplicationManager>
{
  @override
  void initState()
  {
    System().registerEventListener(EventTypes.open, onOpen);
    System().registerEventListener(EventTypes.refresh, onRefresh);
    System().registerEventListener(EventTypes.theme, onTheme);

    super.initState();
  }

  @override
  void dispose()
  {
    System().removeEventListener(EventTypes.open, onOpen);
    System().removeEventListener(EventTypes.refresh, onRefresh);
    System().removeEventListener(EventTypes.theme, onTheme);
    super.dispose();
  }

  Future<bool> onOpen(Event event, {bool refresh = false, String? dependency}) async 
  {
    // mark event as handled
    event.handled = true;

    // build parameters
    Map<String, String?>? parameters = <String, String?>{};
    if (event.parameters != null) parameters.addAll(event.parameters!);

    // get url parameters
    if (parameters.containsKey('url'))
    {
      Uri? uri = URI.parse(parameters['url']);
      if (uri?.queryParameters != null) parameters.addAll(uri!.queryParameters);
    }

    // build parameters from a data source
    if ((parameters.containsKey('data')) &&
        (event.model != null) &&
        (event.model!.scope != null)) {
      String? id = parameters['data'];
      IDataSource? source = event.model?.scope?.getDataSource(id);
      if ((source != null) && (source.data != null) && (source.data?.isNotEmpty ?? false)) {
        source.data?[0].forEach((key, value) {
          var id = Binding.toKey("${source.id}.${'data'}", key);
          if (value is String && id != null) {
            parameters[id] =
                source.data![0][key];
          }
        });
      }
      parameters.remove('data');
    }

    // open the page
    return NavigationManager().open(parameters, model: event.model, dependency: dependency, refresh: refresh);
  }

  void onRefresh(Event event) async
  {
    await NavigationManager().refresh();
  }

  void onTheme(Event event) async
  {
    final themeNotifier     = Provider.of<ThemeNotifier>(context, listen: false);
    String? eventColor      = event.parameters?['color'];
    String? eventBrightness = event.parameters?['brightness'] ?? System.theme.brightness;
    if (eventColor != null) {
      themeNotifier.setTheme(eventBrightness!, eventColor);
    } else {
      themeNotifier.setTheme(eventBrightness!);
    }
  }

  @override
  Widget build(BuildContext context)
  {
    Widget view = Stack(children: [widget.child!]);

    // set system width/height bindables
    // necessary to keep setting this for
    // web and desktop as screen sizes can change
    System().screenheight = MediaQuery.of(context).size.height;
    System().screenwidth  = MediaQuery.of(context).size.width;

    // system shortcuts
    if (kDebugMode) {
      view = Shortcuts(shortcuts: <LogicalKeySet, Intent>
    {
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.alt, LogicalKeyboardKey.keyL): ShowLogIntent(),
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.alt, LogicalKeyboardKey.keyT): ShowTemplateIntent(),
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.alt, LogicalKeyboardKey.keyR): RefreshPageIntent(),
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.alt, LogicalKeyboardKey.keyD): DebugWindowIntent(),
    },
        child: Actions(actions: <Type, Action<Intent>>{
          ShowLogIntent: ShowLogAction(),
          ShowTemplateIntent: ShowTemplateAction(),
          RefreshPageIntent: RefreshPageAction(),
          DebugWindowIntent: DebugWindowAction(),
        }, child: view));
    }

    return view;
  }
}

class ShowLogIntent extends Intent {}
class ShowLogAction extends Action<ShowLogIntent> {
  ShowLogAction();

  @override
  void invoke(covariant ShowLogIntent intent)
  {
    Log().export();
  }
}

class ShowTemplateIntent extends Intent {}
class ShowTemplateAction extends Action<ShowTemplateIntent>
{
  ShowTemplateAction();

  @override
  void invoke(covariant ShowTemplateIntent intent) async
  {
    FrameworkView? framework = NavigationManager().frameworkOf();
    if (framework != null)
    {
       FrameworkModel model = framework.model;
       EventManager.of(model)?.broadcastEvent(model,Event(EventTypes.showtemplate));
    }
    else {
      System.toast("unable to display template");
    }
  }
}

class RefreshPageIntent extends Intent {}
class RefreshPageAction extends Action<RefreshPageIntent>
{
  @override
  void invoke(covariant RefreshPageIntent intent)
  {
    NavigationManager().refresh();
  }
}

class DebugWindowIntent extends Intent {}
class DebugWindowAction extends Action<DebugWindowIntent>
{
  @override
  void invoke(covariant DebugWindowIntent intent) async
  {
    FrameworkView? framework = NavigationManager().frameworkOf();
    if (framework != null)
    {
      FrameworkModel model = framework.model;
      EventManager.of(model)?.executeEvent(model,"DEBUG.open()");
    }
  }
}