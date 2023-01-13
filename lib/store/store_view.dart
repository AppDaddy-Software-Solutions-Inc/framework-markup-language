// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/hive/app.dart';
import 'package:fml/navigation/manager.dart';
import 'package:fml/navigation/page.dart';
import 'package:fml/theme/themenotifier.dart';
import 'package:fml/navigation/observer.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fml/phrase.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/busy/busy_view.dart';
import 'package:fml/widgets/busy/busy_model.dart';
import 'package:fml/store/store_model.dart';
import 'package:fml/widgets/button/button_model.dart';
import 'package:fml/widgets/input/input_model.dart';
import 'package:fml/widgets/menu/menu_view.dart';
import 'package:fml/widgets/menu/menu_model.dart';
import 'package:fml/widgets/menu/item/menu_item_model.dart';
import 'package:provider/provider.dart';
import 'package:fml/helper/helper_barrel.dart';

final bool enableTestPlayground = false;

class StoreView extends StatefulWidget
{
  StoreView();

  @override
  State createState() => _ViewState();
}

class _ViewState extends State<StoreView> with SingleTickerProviderStateMixin implements IModelListener, INavigatorObserver
{

  BusyView? busy;

  bool _visible = false;
  late InputModel appURLInput;
  ButtonModel? storeButton;
  MenuModel menuModel = MenuModel(null, 'Application Menu');
  Widget? storeDisplay;

  @override
  void initState()
  {
    super.initState();
    appURLInput = InputModel(null, null, hint: phrase.store, value: "", icon: Icons.link, keyboardtype: 'url', keyboardinput: 'done');
  }

  @override
  void didUpdateWidget(oldWidget)
  {
    super.didUpdateWidget(oldWidget);
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
    // stop listening to route changes
    NavigationObserver().removeListener(this);

    // Cleanup
    Store().dispose();

    super.dispose();
  }

  BuildContext getNavigatorContext() => context;

  Map<String,String>? onNavigatorPop() => null;
  onNavigatorChange() {}

  void onNavigatorPush({Map<String?, String>? parameters})
  {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    themeNotifier.setTheme('light', 'lightblue');
  }

  /// Callback to fire the [_ViewState.build] when the [StoreModel] changes
  onModelChange(WidgetModel model, {String? property, dynamic value})
  {
    if (this.mounted) setState((){});
  }

  @override
  Widget build(BuildContext context)
  {
    if (!isWeb)
    {
      // build menu items
      menuModel.items = [];
      var apps = Store().apps.toList();
      for (var app in apps)
      {
        var item = MenuItemModel(menuModel, app.key, url: app.url, title: app.title, subtitle: '', icon: app.icon == null ? 'appdaddy' : null, image: app.icon, onTap: () => _launchApp(app.url), onLongPress: () => removeApp(app));
        menuModel.items.add(item);
      }

      Widget storeDisplay = MenuView(menuModel);

      storeButton = ButtonModel(null, null, enabled: !S.isNullOrEmpty(appURLInput.value), label: phrase.loadApp, buttontype: "raised", color: Theme.of(context).colorScheme.secondary);

      Widget noAppDisplay = Center(
        child: AnimatedOpacity(
          opacity: _visible ? 1.0 : 0.0,
          duration: Duration(milliseconds: 200),
          child: Text(phrase.clickToConnect, style: TextStyle(color: Theme.of(context).colorScheme.outline)))
      );

      return WillPopScope(onWillPop: () => quitDialog().then((value) => value as bool),
          child: Scaffold(
            floatingActionButton: !Store().busy
                ? FloatingActionButton.extended(label: Text('Add App'), icon: Icon(Icons.add), onPressed: () => addAppDialog(), foregroundColor: Theme.of(context).colorScheme.onSurface, backgroundColor: Theme.of(context).colorScheme.onInverseSurface, splashColor: Theme.of(context).colorScheme.inversePrimary, hoverColor: Theme.of(context).colorScheme.surface, focusColor: Theme.of(context).colorScheme.inversePrimary)
                : FloatingActionButton.extended(onPressed: null, foregroundColor: Theme.of(context).colorScheme.onSurface, backgroundColor: Theme.of(context).colorScheme.onInverseSurface, splashColor: Theme.of(context).colorScheme.inversePrimary, hoverColor: Theme.of(context).colorScheme.surface, focusColor: Theme.of(context).colorScheme.inversePrimary, label: Text('Loading Apps'),),
            body: SafeArea(child: Stack(children: [Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomRight, end: Alignment.topLeft, stops: [0.4, 1.0], colors: [/*Theme.of(context).colorScheme.inversePrimary*/Theme.of(context).colorScheme.surfaceVariant, Theme.of(context).colorScheme.surface])),),
            Center(child: Opacity(opacity: 0.03, child: Image(image: AssetImage('assets/images/fml-logo.png')))),
            Center(child: apps.isEmpty ? noAppDisplay : storeDisplay),
            Align(alignment: Alignment.bottomLeft, child: Padding(padding: EdgeInsets.only(left: 5), child: Text(phrase.version + ' ' + version, style: TextStyle(color: Colors.black26))),),
            Center(child: BusyView(BusyModel(Store(), visible: Store().busy, observable: Store().busyObservable, modal: true)))]))
          )
      );
    }

    // Busy
    else {
      return Scaffold(body: Center(child: BusyView(BusyModel(null, visible:true))));
    }
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
            title: Row(children: [Text(phrase.connectAnApplication, style: TextStyle(color: Theme.of(context).colorScheme.primary)), Padding(padding: EdgeInsets.only(left: 20)), BusyView(BusyModel(Store(), visible: Store().busy, observable: Store().busyObservable, size: 14))]),
            content: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: AppForm()),
            contentPadding: EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 2.0),
            insetPadding: EdgeInsets.zero,
          );
        });
      },
    );
  }

  Future<void> removeApp(App app) async
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
              Padding(padding: EdgeInsets.only(bottom: 10), child: Text('($app.url)', style: TextStyle(fontSize: 14))),
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
          title: Text(phrase.close + ' ' + phrase.application + '?'),
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

  _launchApp(String domain) async
  {
    Store().busy = true;

    // set default domain
    await System().setDomain(domain);

    // get config for domain
    var config = await System().getConfigModel(domain);

    // push home page
    String? home = System().homePage;
    NavigationManager().setNewRoutePath(PageConfiguration(url: home, title: "Store"), source: "store");

    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    if (config != null) {
      String brightness = config.get('BRIGHTNESS') ?? 'light';
      String color = config.get('COLOR_SCHEME') ?? 'lightblue';
      themeNotifier.setTheme(brightness, color);
      themeNotifier.mapSystemThemeBindables();
    }
  }
}

class AppForm extends StatefulWidget
{
  AppForm();

  @override
  AppFormState createState()
  {
    return AppFormState();
  }
}

class AppFormState extends State<AppForm>
{
  final   _formKey = GlobalKey<FormState>();
  String  errorText = '';
  String? title;

  String? validateUrl(url)
  {
    if (url == null || url == "") return phrase.missingURL;
    if (S.toDataUri(url) == null) return 'The address in not a valid web address';
    if (Store().find(url: url) != null) return 'You are already connected to this application';
    return null;
  }

  Future tryAdd() async
  {
    // validate the form
    bool errors = _formKey.currentState!.validate();
    if (!errors)
    {
      System.toast('Attempting to Connect Application',duration: 2);
    }
  }

  @override
  Widget build(BuildContext context)
  {
    var name =  TextFormField(onChanged: (v) => title = v, decoration: InputDecoration(labelText: "Application Name", labelStyle: TextStyle(color: Colors.grey, fontSize: 12), fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide())));

    var url = TextFormField(validator: validateUrl, keyboardType: TextInputType.url, decoration: InputDecoration(labelText: "Application Web Address", labelStyle: TextStyle(color: Colors.grey, fontSize: 12),
          fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide())));

    var error = Text(errorText, style: TextStyle(fontSize: 12, color: Colors.red));

    var cancel = TextButton(child: Text(phrase.cancel),  onPressed: () => Navigator.of(context).pop());

    var add =  TextButton(child: Text(phrase.connect), onPressed: tryAdd);

    var fields = <Widget>[Padding(padding: EdgeInsets.only(top: 10)),name,url,error,cancel,add];

    var form = Form(key: _formKey, child: Column(children: fields,mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.start));

    return form;
  }
}
