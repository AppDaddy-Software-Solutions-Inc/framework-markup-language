// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/theme/themenotifier.dart';
import 'package:fml/navigation/navigation_observer.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:flutter/material.dart';
import 'package:fml/phrase.dart';
import 'package:fml/store/store_model.dart';
import 'package:fml/widgets/button/button_model.dart';
import 'package:fml/widgets/input/input_model.dart';
import 'package:fml/widgets/menu/menu_model.dart';
import 'package:provider/provider.dart';

final bool enableTestPlayground = false;

class DartPadView extends StatefulWidget
{
  DartPadView();

  @override
  State createState() => _ViewState();
}

class _ViewState extends State<DartPadView> with SingleTickerProviderStateMixin implements IModelListener, INavigatorObserver
{
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
    var busy = Store().busy;
    return  Container();
  }
}