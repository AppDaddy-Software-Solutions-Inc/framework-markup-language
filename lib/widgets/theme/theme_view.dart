// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';

import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart'   ;
import 'package:fml/widgets/theme/theme_model.dart';
import 'package:fml/theme/theme.dart';

class ThemeView extends StatefulWidget
{
  final ThemeModel model;
  final List<Widget> children = [];

  ThemeView(this.model) : super(key: ObjectKey(model));

  @override
  _ThemeViewState createState() => _ThemeViewState();
}

class _ThemeViewState extends State<ThemeView> implements IModelListener
{

  @override
  void initState() {
    super.initState();
    widget.model.registerListener(this);

    // If the model contains any databrokers we fire them before building so we can bind to the data
    widget.model.initialize();
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(ThemeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.model != widget.model)
    {
      oldWidget.model.removeListener(this);
      widget.model.registerListener(this);
    }
  }

  @override
  void dispose() {
    widget.model.removeListener(this);
    super.dispose();
  }

  /// Callback to fire the [_ThemeViewState.build] when the [THEME.ThemeModel] changes
  onModelChange(WidgetModel model, {String? property, dynamic value})
  {
    if (this.mounted) setState((){});
  }

  @override
  Widget build(BuildContext context)
  {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    //////////////////
    /* Add Children */
    //////////////////
    widget.children.clear();
    if (widget.model.children != null)
      widget.model.children!.forEach((model)
      {
        if (model is IViewableWidget) {
          widget.children.add((model as IViewableWidget).getView());
        }
      });
    if (widget.children.isEmpty) widget.children.add(Container());

    var m = widget.model;
    ThemeData themeData = applyCustomizations(Theme.of(context).colorScheme, m);

    ///////////
    /* Theme */
    ///////////
    return Theme(data: themeData, child: widget.children.length == 1 ? widget.children[0] : Stack(children: widget.children));
  }
}
