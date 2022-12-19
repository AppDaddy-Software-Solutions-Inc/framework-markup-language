// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
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
import 'package:fml/config/model.dart' as CONFIG;
import 'package:provider/provider.dart';
import 'package:fml/helper/helper_barrel.dart';

final bool enableTestPlayground = false;

class StoreView extends StatefulWidget
{
  // Enabled app linking for mobile where there is no URL to tell us what app to point to
  final StoreModel model = StoreModel();

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
  Map<String, String?>? linkedApps;
  Map<String, String?> appicons = {};
  Map<String, String?> iconBase64 = {};

  @override
  void initState()
  {
    super.initState();
    appURLInput = InputModel(null, null, hint: phrase.store, value: "", icon: Icons.link, keyboardtype: 'url', keyboardinput: 'done');
    loadLinkedApps();
  }

  @override
  void didUpdateWidget(oldWidget)
  {
    super.didUpdateWidget(oldWidget);
  }

  @override
  didChangeDependencies()
  {
    /////////////////////////////
    /* Listen to Route Changes */
    /////////////////////////////
    NavigationObserver().registerListener(this);

    super.didChangeDependencies();
  }

  @override
  void dispose()
  {
    /////////////////////////////////////
    /* Stop Listening to Route Changes */
    /////////////////////////////////////
    NavigationObserver().removeListener(this);

    // Cleanup
    widget.model.dispose();

    super.dispose();
  }

  BuildContext getNavigatorContext() => context;

  Map<String,String>? onNavigatorPop() => null;
  onNavigatorChange() {}

  void onNavigatorPush({Map<String?, String>? parameters}) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    themeNotifier.setTheme('light', 'lightblue');
  }

  /// Callback to fire the [_ViewState.build] when the [StoreModel] changes
  onModelChange(WidgetModel model, {String? property, dynamic value})
  {
    if (this.mounted) setState((){});
  }

  loadLinkedApps() async
  {
    var apps = await widget.model.store();

    for (var entry in apps.entries)
    {
      try
      {
        ////////////////////////////
        /* Get Configuration File */
        ////////////////////////////
        CONFIG.ConfigModel? config = await System().getConfigModel(entry.key, refresh: true);
        if (config != null)
        {
          appicons[entry.key] = config.get('APP_ICON') ?? null;
          apps[entry.key]     = S.isNullOrEmpty(apps[entry.key]) ? config.get('APPLICATION_NAME') ?? entry.key : apps[entry.key];
          String iconUrl = entry.key + '/' + appicons[entry.key]!;
          await widget.model.setBase64IconImage(iconUrl);
          iconBase64[entry.key] = await widget.model.getBase64IconImage(iconUrl);
        }
      } catch(e) {
        Log().exception(e, caller: 'store.view loadLinkedApps()');
      }
    }

    setState(()
    {
      linkedApps = apps;
      _visible = true;
    });
  }

  bool linkButtonEnabled(String? appURL)
  {
    return !(S.isNullOrEmpty(appURL));
  }

  @override
  Widget build(BuildContext context)
  {
    if (!isWeb)
    {
      storeButton = ButtonModel(null, null, enabled: linkButtonEnabled(appURLInput.value), label: phrase.loadApp, buttontype: "raised", color: Theme.of(context).colorScheme.secondary);
      if (linkedApps != null) {
        menuModel.items = [];
        linkedApps!.forEach((key, value) {
          if (appicons[key] != null) { // application has custom icon
            String imageurl = key + '/' + appicons[key]!;
            if (!S.isNullOrEmpty(iconBase64[key])) {// custom icon is saved in hive
              menuModel.items.add(MenuItemModel(menuModel, value, url: key, title: value, subtitle: '', icon: 'appdaddy', iconBase64: iconBase64[key], onTap: () => start(key), onLongPress: () => removeAppDialog(key, value)));
            }
            else { // custom icon from network
              menuModel.items.add(MenuItemModel(menuModel, value, url: key, title: value, subtitle: '', icon: 'appdaddy', iconImage: imageurl, onTap: () => start(key), onLongPress: () => removeAppDialog(key, value)));
            }
          }
          else {
            menuModel.items.add(MenuItemModel(menuModel, value, url: key, title: value, subtitle: '', icon: 'appdaddy', iconcolor: 'orange', onTap: () => start(key), onLongPress: () => removeAppDialog(key, value)));
          }
        });
      }

      // Widget storeDisplay = Container(
      //     child: Padding(padding: const EdgeInsets.only(left: 10.0, right: 10.0),
      //           child: Column(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center,
      //               children: [ // Test Playground  / Version Indicator
      //                 Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic,
      //                   children: [
      //                     enableTestPlayground ? InkWell(onTap: widget.test,
      //                         child: Row(children: [ Icon(Icons.build, color: Theme.of(context).errorColor),
      //                           Text('', style: TextStyle(color: Colors.deepOrange, fontSize: 13)),
      //                         ])
      //                     ) : Text('Applications', style: TextStyle(color: Colors.black26, fontSize: 22)),
      //
      //                     Text(phrase.version + ' ' + SYSTEM.version, style: TextStyle(color: Colors.black26)),
      //                     // Tooltip(child: Icon(Icons.info, size: isMobile ? 24 : 18, color: Colors.black12), message: phrase.version + ' : ' + SYSTEM.version),
      //                   ],
      //                 ),
      //                 Padding(padding: EdgeInsets.only(top: 10)),
      //                 // Container(width: MediaQuery.of(context).size.width, height: 1, color: Colors.white12),
      //                 Padding(padding: EdgeInsets.only(top: 10)),
      //                 MENU.View(menuModel),
      //               ]
      //           ),
      //     )
      // );
      Widget storeDisplay = MenuView(menuModel);

      Widget noAppDisplay = Center(
        child: AnimatedOpacity(
          opacity: _visible ? 1.0 : 0.0,
          duration: Duration(milliseconds: 200),
          child: Text(phrase.clickToConnect, style: TextStyle(color: Theme.of(context).colorScheme.outline)))
      );

      return WillPopScope(onWillPop: () => quitDialog().then((value) => value as bool),
          child: Scaffold(
            floatingActionButton: linkedApps != null
                ? FloatingActionButton.extended(label: Text('Add App'), icon: Icon(Icons.add), onPressed: () => addAppDialog(), foregroundColor: Theme.of(context).colorScheme.onSurface, backgroundColor: Theme.of(context).colorScheme.onInverseSurface, splashColor: Theme.of(context).colorScheme.inversePrimary, hoverColor: Theme.of(context).colorScheme.surface, focusColor: Theme.of(context).colorScheme.inversePrimary)
                : FloatingActionButton.extended(onPressed: null, foregroundColor: Theme.of(context).colorScheme.onSurface, backgroundColor: Theme.of(context).colorScheme.onInverseSurface, splashColor: Theme.of(context).colorScheme.inversePrimary, hoverColor: Theme.of(context).colorScheme.surface, focusColor: Theme.of(context).colorScheme.inversePrimary, label: Text('Loading Apps'),),
            body: SafeArea(child: Stack(children: [
              Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomRight, end: Alignment.topLeft, stops: [0.4, 1.0], colors: [/*Theme.of(context).colorScheme.inversePrimary*/Theme.of(context).colorScheme.surfaceVariant, Theme.of(context).colorScheme.surface])),
                // child: Padding(padding: EdgeInsets.only(top: 16.0, bottom: 16.0, left: isMobile ? 4 : 16.0, right: isMobile ? 4 : 16.0),
                // )
            ),
            Center(child: Opacity(opacity: 0.03, child: Image(image: AssetImage('assets/images/fml-logo.png')))),
            Center(
                child: linkedApps == null || linkedApps!.isEmpty ? noAppDisplay : storeDisplay
            ),
            Align(alignment: Alignment.bottomLeft,
              child: Padding(padding: EdgeInsets.only(left: 5), child: Text(phrase.version + ' ' + version, style: TextStyle(color: Colors.black26))),
            ),
            Center(child: BusyView(BusyModel(widget.model, visible: widget.model.busy, observable: widget.model.busyObservable, modal: true)))]))
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
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Row(children: [Text(phrase.connectAnApplication, style: TextStyle(color: Theme.of(context).colorScheme.primary)), Padding(padding: EdgeInsets.only(left: 20)), BusyView(BusyModel(widget.model, visible: widget.model.busy, observable: widget.model.busyObservable, size: 14))]),
            content: Padding(padding: EdgeInsets.symmetric(horizontal: 8),
              child: AppLinkForm(linkApp, linkedApps),
            ),
            contentPadding: EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 2.0),
            insetPadding: EdgeInsets.zero,
          );
        });
      },
    );
  }

  Future<String?> linkApp(String url, {String? friendlyName}) async
  {
    widget.model.busy = true;
    try
    {
      String? appLink = await widget.model.link(url); // Get the config from the app link
      if (appLink != null)
      {

        Map<String, String?> linkedApps = await widget.model.store();
        if (linkedApps.containsValue(appLink)) {
          // pop dialog showing app already linked
          widget.model.busy = false;
          return "already connected to this application";
        }
        else {
          await widget.model.addApp(appLink, friendlyName: friendlyName);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Connected $friendlyName'), duration: Duration(milliseconds: 1000)));
          loadLinkedApps();
        }
        // start(url);
        widget.model.busy = false;
        return null;
      }
      else {
        if (appLink == null) {
          // Navigator.of(context).pop();
          widget.model.busy = false;
          return 'Unable to connect, ensure the address is correct';
        }
      }
    }
    catch (e) {}
    widget.model.busy = false;
    return "Unable to connect, check the address is correct and that you connected to the internet";
  }

  Future<void> removeAppDialog(String key, String? value) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      useRootNavigator: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove Application?'),
          content: Container(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Padding(padding: EdgeInsets.only(top: 20), child: Text(value!, style: TextStyle(fontSize: 18),),),
              Padding(padding: EdgeInsets.only(bottom: 10), child: value != key ? Text('($key)', style: TextStyle(fontSize: 14)) : Container()),
              Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
                TextButton(
                  onPressed: () async {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Removing $value'), duration: Duration(milliseconds: 1000)));
                    await widget.model.removeApp(key);
                    loadLinkedApps();
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

  start(String domain) async
  {
    widget.model.busy = true;

    // set default domain
    await System().setDomain(domain);

    // push home page
    String? home = System().homePage;
    NavigationManager().setNewRoutePath(PageConfiguration(url: home, title: "Store"), source: "store");

    widget.model.busy = false;
  }
}

class AppLinkForm extends StatefulWidget
{
  final Future<String?> Function(String url, {String? friendlyName}) linkApp;
  final Map<String, String?>? linkedApps;

  AppLinkForm(this.linkApp, this.linkedApps);

  @override
  AppLinkFormState createState() {
    return AppLinkFormState();
  }

}

class AppLinkFormState extends State<AppLinkForm> {
  final _formKey = GlobalKey<FormState>();
  String errorText = '';

  @override
  Widget build(BuildContext context)
  {
    String fn = "";
    double rad = 10.0;
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(padding: EdgeInsets.only(top: 10)),
          TextFormField(keyboardType: TextInputType.url,
            decoration: InputDecoration(
              labelText: "Application Web Address",
              labelStyle: TextStyle(color: Colors.grey, fontSize: 12),
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(rad),
                borderSide: BorderSide(),
              ),
              //fillColor: Colors.green
            ),
            validator: (value) {
                if (value == null || value == "")
                  return phrase.missingURL;
                else if ((widget.linkedApps?.containsKey(value) ?? false) || (widget.linkedApps?.containsKey('http://' + value) ?? false) || (widget.linkedApps?.containsKey('https://' + value) ?? false))
                  return 'You are already connected to this application'; // value + ' ' + phrase.alreadyLinked;
                else {
                  widget.linkApp(value, friendlyName: fn).then((err) {
                    setState((){errorText = err ?? '';});
                    if (err == null) Navigator.of(context).pop();
                  });
                  return null;
                }
            },
          ),
          Padding(padding: EdgeInsets.all(10)),
          TextFormField(onChanged: (v) => fn = v,
            decoration: InputDecoration(
              labelText: "Application Name",
              labelStyle: TextStyle(color: Colors.grey, fontSize: 12),
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(rad),
                borderSide: BorderSide(),
              ),
              //fillColor: Colors.green
            ),
            // validator: (value) {
            //   if (value != "" && widget.linkedApps.containsValue(value))
            //     return value + ' ' + phrase.alreadyInUse;
            //   return null;
            // },
          ),
          Padding(padding: EdgeInsets.only(top: 10),
            child: Text(errorText, style: TextStyle(fontSize: 12, color: Colors.red)),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 0.0),
            child: Align(alignment: Alignment.bottomCenter,
              child: Row(mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.of(context).pop(),
                      child: Text(phrase.cancel),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Attempting to Connect Application',), duration: Duration(milliseconds: 2000)));
                      }
                    },
                    child: Text(phrase.connect),
                  )
                ],
              ),
            )
          ),
        ],
      ),
    );
  }
}
