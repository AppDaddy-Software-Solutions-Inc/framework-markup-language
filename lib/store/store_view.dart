// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/application/application_model.dart';
import 'package:fml/fml.dart';
import 'package:fml/store/store_app_view.dart';
import 'package:fml/theme/theme.dart';
import 'package:fml/navigation/navigation_observer.dart';
import 'package:fml/widgets/theme/theme_model.dart';
import 'package:fml/widgets/widget/widget_model_interface.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fml/phrase.dart';
import 'package:fml/widgets/busy/busy_view.dart';
import 'package:fml/widgets/busy/busy_model.dart';
import 'package:fml/store/store_model.dart';
import 'package:fml/widgets/input/input_model.dart';
import 'package:fml/widgets/menu/menu_view.dart';
import 'package:fml/widgets/menu/menu_model.dart';
import 'package:fml/widgets/menu/item/menu_item_model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

final bool enableTestPlayground = false;

class StoreView extends StatefulWidget
{
  final MenuModel model = MenuModel(null, 'Applications');
  StoreView();

  @override
  State createState() => _ViewState();
}

class _ViewState extends State<StoreView> with SingleTickerProviderStateMixin implements IModelListener, INavigatorObserver
{
  late InputModel appURLInput;

  RoundedRectangleBorder rrbShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(8));

  @override
  void initState()
  {
    super.initState();
    appURLInput = InputModel(null, null, hint: phrase.store, value: "", icon: Icons.link, keyboardType: 'url', keyboardInput: 'done');
    Store().registerListener(this);
  }

  @override
  didChangeDependencies()
  {
    // listen to route changes
    NavigationObserver().registerListener(this);
    super.didChangeDependencies();
  }

  @override
  void dispose()
  {
    // stop listening to model changes
    Store().removeListener(this);

    // stop listening to route changes
    NavigationObserver().removeListener(this);

    // Cleanup
    Store().dispose();

    super.dispose();
  }

  @override
  BuildContext getNavigatorContext() => context;

  @override
  Map<String,String>? onNavigatorPop() => null;

  @override
  onNavigatorChange() {}

  @override
  void onNavigatorPush({Map<String?, String>? parameters})
  {
    // reset the theme
    // show tooltip in post frame callback
    WidgetsBinding.instance.addPostFrameCallback((_)
    {
      final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
      themeNotifier.setTheme(brightness: FmlEngine.defaultBrightness, color: FmlEngine.defaultColor, font: FmlEngine.defaultFont);
    });
  }

  /// Callback to fire the [_ViewState.build] when the [StoreModel] changes
  @override
  onModelChange(WidgetModel model, {String? property, dynamic value})
  {
    if (mounted) setState((){});
  }

  Future<void> addAppDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      useRootNavigator: false,
      builder: (BuildContext context)
      {
        return StatefulBuilder(builder: (context, setState)
        {
          return AlertDialog(
            title: Row(children: [Text(phrase.connectAnApplication, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
              Padding(padding: EdgeInsets.only(left: 20)),
              BusyView(BusyModel(Store(), visible: Store().busy, observable: Store().busyObservable, size: 14))]),
            content: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: AppForm()),
            contentPadding: EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 2.0),
            insetPadding: EdgeInsets.zero,
          );
        });
      },
    );
  }

  Future<void> removeApp(ApplicationModel app) async
  {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      useRootNavigator: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove Application?'),
          content: Container(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Padding(padding: EdgeInsets.only(top: 20), child: Text(app.title ?? "", style: TextStyle(fontSize: 18),),),
              Padding(padding: EdgeInsets.only(bottom: 10), child: Text('(${app.url})', style: TextStyle(fontSize: 14))),
              Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
                TextButton(
                    onPressed: () async
                    {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Removing ${app.title}'), duration: Duration(milliseconds: 1000)));
                      await Store().delete(app);
                      Navigator.of(context).pop();
                    },
                    child: Text('Remove')
                ),
                Padding(padding: EdgeInsets.only(right: 10),),
              ],),
              // BUTTON.View(storeButton, onPressCallback: () => link(),
              //     child: Padding(padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10), child: Text(phrase.loadApp, style: TextStyle(fontSize: 17)))
              // ),
            ]),
          ),
          contentPadding: EdgeInsets.fromLTRB(4.0, 16.0, 4.0, 2.0),
          insetPadding: EdgeInsets.zero,
        );
      },
    );
  }

  Future<void> quitDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      useRootNavigator: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${phrase.close} ${phrase.application}?'),
          content: SizedBox(width: MediaQuery.of(context).size.width - 60, height: 80,
            child: Column(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.end, children: [
              Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(phrase.no)),
                TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                      // SystemNavigator.pop()
                    },
                    child: Text(phrase.yes)
                ),
              ],),
              // BUTTON.View(storeButton, onPressCallback: () => link(),
              //     child: Padding(padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10), child: Text(phrase.loadApp, style: TextStyle(fontSize: 17)))
              // ),
            ]),
          ),
          contentPadding: EdgeInsets.fromLTRB(4.0, 20.0, 4.0, 10.0),
          insetPadding: EdgeInsets.zero,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context)
  {
    // build menu items
    widget.model.items = [];
    for (var app in Store().getApps())
    {
      var icon = app.icon;
      if (Theme.of(context).brightness == Brightness.light) icon = app.icon_light ?? icon;
      if (Theme.of(context).brightness == Brightness.dark)  icon = app.icon_dark ?? icon;

      var item = MenuItemModel(widget.model, app.id,
          url: app.url,
          title: app.title,
          icon:  icon == null ? 'appdaddy' : null,
          image: icon,
          onTap: () => Store().launch(app, context),
          onLongPress: () => removeApp(app));

      widget.model.items.add(item);
    }

    // store menu
    Widget store = MenuView(widget.model);

    var addButton = FloatingActionButton.extended(
        label: Text(phrase.addApp),
        icon: Icon(Icons.add),
        onPressed: () => addAppDialog(),
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
        splashColor: Theme.of(context).colorScheme.inversePrimary,
        hoverColor: Theme.of(context).colorScheme.surface,
        focusColor: Theme.of(context).colorScheme.inversePrimary,
        shape: rrbShape);

    var busyButton = FloatingActionButton.extended(
        label: Text(phrase.loadApp),
        onPressed: null,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
        splashColor: Theme.of(context).colorScheme.inversePrimary,
        hoverColor: Theme.of(context).colorScheme.surface,
        focusColor: Theme.of(context).colorScheme.inversePrimary,
        shape: rrbShape);

    var busy = Center(child: BusyModel(Store(), visible: Store().busy, observable: Store().busyObservable, modal: true).getView());

    var privacyUri    = Uri(scheme: 'https', host: 'fml.dev' , path: '/privacy.html');
    var privacyText   = Text(phrase.privacyPolicy);
    var privacyButton = InkWell(child: privacyText, onTap: () => launchUrl(privacyUri));

    var version = Text('${phrase.version} ${FmlEngine.version}');

    var text = Column(mainAxisSize: MainAxisSize.min, children: [privacyButton,version]);
    var button = Store().busy ? busyButton : addButton;

    var scaffold = Scaffold(floatingActionButton: button, body: SafeArea(child: Stack(children: [Center(child: store), Positioned(child: text, left: 10, bottom: 10), busy])));

    return WillPopScope(onWillPop: () => quitDialog().then((value) => value as bool), child: scaffold);
  }
}
