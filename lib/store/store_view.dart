// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:collection/collection.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fml/application/application_model.dart';
import 'package:fml/fml.dart';
import 'package:fml/helpers/string.dart';
import 'package:fml/store/store_app_view.dart';
import 'package:fml/system.dart';
import 'package:fml/theme/theme.dart';
import 'package:fml/navigation/navigation_observer.dart';
import 'package:fml/widgets/widget/widget_model_interface.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:flutter/material.dart';
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

const bool enableTestPlayground = false;

class StoreView extends StatefulWidget {
  final MenuModel model = MenuModel(null, 'Applications');
  StoreView({super.key});

  @override
  State createState() => _ViewState();
}

class _ViewState extends State<StoreView>
    with SingleTickerProviderStateMixin
    implements IModelListener, INavigatorObserver {
  late InputModel appURLInput;

  RoundedRectangleBorder rrbShape =
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(8));

  @override
  void initState() {
    super.initState();

    appURLInput = InputModel(null, null,
        hint: phrase.store,
        value: "",
        icon: Icons.link,
        keyboardType: 'url',
        keyboardInput: 'done');

    StoreModel().registerListener(this);
  }

  @override
  didChangeDependencies() {

    // listen to route changes
    NavigationObserver().registerListener(this);

    super.didChangeDependencies();
  }

  @override
  void dispose() {

    // stop listening to model changes
    StoreModel().removeListener(this);

    // stop listening to route changes
    NavigationObserver().removeListener(this);

    // Cleanup
    StoreModel().dispose();

    super.dispose();
  }

  @override
  BuildContext getNavigatorContext() => context;

  @override
  Map<String, String>? onNavigatorPop() => null;

  @override
  onNavigatorChange() {}

  @override
  void onNavigatorPush({Map<String?, String>? parameters}) {
    // reset the theme
    // show tooltip in post frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
      themeNotifier.setTheme(
          brightness: FmlEngine.defaultBrightness,
          color: FmlEngine.defaultColor,
          font: FmlEngine.defaultFont);
    });
  }

  /// Callback to fire the [_ViewState.build] when the [StoreModel] changes
  @override
  onModelChange(WidgetModel model, {String? property, dynamic value}) {

    // application model
    if (model is ApplicationModel) {
      ApplicationModel app = model;
      var item = widget.model.items.firstWhereOrNull((item) => item.id == ObjectKey(app).toString());
      if (item != null) {
        var iconNew = _getThemedIcon(app);
        var iconOld = item.image?.uri.data.toString();
        if (iconNew != iconOld) {
          var image = toDataUri(iconNew);
          if (image != null) {
            item.image = image;
            item.notifyListeners("image", null);
          }
        }
      }
    }

    // other
    if (model is! ApplicationModel) {
      if (mounted) setState(() {});
    }
  }

  Widget addAppDialog(BuildContext context, bool popOnExit) {
    var view = StatefulBuilder(builder: (context, setState) {
      var style = TextStyle(color: Theme.of(context).colorScheme.primary);

      var ttl = Text(phrase.connectAnApplication, style: style);
      var busy = BusyView(BusyModel(StoreModel(),
          visible: StoreModel().busy, observable: StoreModel().busyObservable, size: 14));
      var pad = const Padding(padding: EdgeInsets.only(left: 20));
      var title = Row(children: [ttl, pad, busy]);

      return AlertDialog(
        title: title,
        content: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: StoreApp(popOnExit: popOnExit)),
        contentPadding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 2.0),
        insetPadding: EdgeInsets.zero,
      );
    });

    return view;
  }

  Future<void> showAddAppDialog(bool dismissable) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: dismissable,
        useRootNavigator: false,
        builder: (BuildContext context) => addAppDialog(context, true));
  }

  void removeApp(ApplicationModel app, NavigatorState navigator) async {

    // delete the app
    await StoreModel().deleteApp(app);

    // close the window
    navigator.pop();
  }

  String? _getThemedIcon(ApplicationModel app)
  {
    var icon = app.icon;
    if (icon == null) return null;
    if (Theme.of(context).brightness == Brightness.light) {
      icon = app.iconLight ?? icon;
    }
    if (Theme.of(context).brightness == Brightness.dark) {
      icon = app.iconDark ?? icon;
    }
    return icon;
  }

  Widget? _getIcon(ApplicationModel app) {

    var icon = _getThemedIcon(app);
    var image = toDataUri(icon);
    if (image == null) return null;

    // svg image?
    if (image.mimeType == "image/svg+xml") {
      return Padding(
          padding: const EdgeInsets.all(10),
          child:
              SvgPicture.memory(image.contentAsBytes(), width: 48, height: 48));
    } else {
      return Padding(
          padding: const EdgeInsets.all(10),
          child: Image.memory(image.contentAsBytes(),
              width: 48, height: 48, fit: null));
    }
  }

  Widget removeAppDialog(BuildContext context, ApplicationModel app) {
    var style = TextStyle(color: Theme.of(context).colorScheme.primary);
    var title = Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text(phrase.removeApp, style: style)]);

    style = TextStyle(
        color: Theme.of(context).colorScheme.primary, fontSize: 18);
    var appTitle = Text(app.title ?? "", style: style);

    Widget? appIcon = _getIcon(app);

    style = TextStyle(
        color: Theme.of(context).colorScheme.onBackground, fontSize: 10);
    var appUrl = Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Text(app.url, style: style));

    style = TextStyle(color: Theme.of(context).colorScheme.primary);

    var cancel = TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(phrase.cancel, style: style));

    var remove = TextButton(
        onPressed: () => removeApp(app, Navigator.of(context)),
        child: Text(phrase.remove, style: style));

    var buttons = Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          cancel,
          const Padding(padding: EdgeInsets.only(right: 20)),
          remove
        ]);

    var view = Padding(
        padding: const EdgeInsets.all(50),
        child:
            Column(children: [appIcon ?? const Offstage(), appTitle, appUrl]));

    var color = Theme.of(context).colorScheme.background;
    var shadow = BoxShadow(
      color: Theme.of(context).colorScheme.shadow.withOpacity(.25),
      blurRadius: 7,
      spreadRadius: 0,
      offset: const Offset(5, 5));

    var box = DecoratedBox(
        decoration: BoxDecoration(
            color: color,
            boxShadow: [shadow],
            borderRadius: const BorderRadius.all(Radius.circular(8))),
        child: view);

    var content = Column(mainAxisSize: MainAxisSize.min, children: [
      const Padding(padding: EdgeInsets.only(bottom: 10)),
      box,
      const Padding(padding: EdgeInsets.only(bottom: 25)),
      buttons,
      const Padding(padding: EdgeInsets.only(bottom: 15))
    ]);

    return AlertDialog(
        title: title,
        backgroundColor: color,
        surfaceTintColor: Colors.transparent,
        content: content,
        contentPadding: const EdgeInsets.fromLTRB(4.0, 16.0, 4.0, 2.0),
        insetPadding: EdgeInsets.zero);
  }

  Future<void> showRemoveAppDialog(ApplicationModel app) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        useRootNavigator: false,
        builder: (BuildContext context) => removeAppDialog(context, app));
  }

  Widget _multiAppView(BuildContext context, BoxConstraints constraints) {

    // build menu items
    widget.model.items = [];

    widget.model.maxWidth = constraints.maxWidth;

    // traverse list of apps
    for (var app in System.apps) {

      // build menu item
      var item = MenuItemModel(
          widget.model,
          ObjectKey(app).toString(),
          url: app.url,
          title: app.title,
          image: _getThemedIcon(app),
          onTap: () => System.launchApplication(app),
          onLongPress: () => showRemoveAppDialog(app));

      // register a listener to the app
      app.registerListener(this);

      widget.model.items.add(item);
    }

    var addButton = FloatingActionButton.extended(
        label: Text(phrase.addApp),
        icon: const Icon(Icons.add),
        onPressed: () => showAddAppDialog(true),
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

    var busy = Center(
        child: BusyModel(StoreModel(),
            visible: StoreModel().busy,
            observable: StoreModel().busyObservable,
            modal: true)
            .getView());

    var privacyUri =
    Uri(scheme: 'https', host: 'fml.dev', path: '/privacy.html');
    var privacyText = Text(phrase.privacyPolicy);
    var privacyButton =
    InkWell(child: privacyText, onTap: () => launchUrl(privacyUri));

    var version = Text('${phrase.version} ${FmlEngine.version}');

    var text = Column(
        mainAxisSize: MainAxisSize.min, children: [privacyButton, version]);
    var button = StoreModel().busy ? busyButton : addButton;

    var view = MenuView(widget.model);

    return Scaffold(
        floatingActionButton: button,
        body: SafeArea(
            child: Stack(children: [
              Center(child: view),
              Positioned(left: 10, bottom: 10, child: text),
              busy
            ])));
  }

  Widget _brandedAppView(BuildContext context, BoxConstraints constraints) {

    var privacyUri =
    Uri(scheme: 'https', host: 'fml.dev', path: '/privacy.html');
    var privacyText = Text(phrase.privacyPolicy);
    var privacyButton =
    InkWell(child: privacyText, onTap: () => launchUrl(privacyUri));

    var version = Text('${phrase.version} ${FmlEngine.version}');

    var text = Column(mainAxisSize: MainAxisSize.min, children: [privacyButton, version]);

    var view = addAppDialog(context, false);

    return Scaffold(body: SafeArea(child: Stack(children: [Center(child: view), Positioned(left: 10, bottom: 10, child: text)])));
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    return FmlEngine.type == ApplicationType.branded ? _brandedAppView(context, constraints) : _multiAppView(context, constraints);
  }
}
