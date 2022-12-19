// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:fml/widgets/trigger/trigger_model.dart';

class TriggerView extends StatefulWidget
{
  final List<Widget> children = [];
  final TriggerModel model;
  TriggerView(this.model) : super(key: ObjectKey(model));

  @override
  _TriggerViewState createState() => _TriggerViewState();
}

class _TriggerViewState extends State<TriggerView> implements IModelListener
{
  @override
  void initState()
  {
    super.initState();

    

      widget.model.registerListener(this);
      widget.model.initialize();
  }

  @override
  didChangeDependencies()
  {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(TriggerView oldWidget)
  {
    super.didUpdateWidget(oldWidget);
    
    if ((oldWidget.model != widget.model))
    {
      oldWidget.model.removeListener(this);
      widget.model.registerListener(this);
    }

  }

  @override
  void dispose()
  {
    widget.model.removeListener(this);

    super.dispose();
  }

  /// Callback to fire the [_TriggerViewState.build] when the [TriggerModel] changes
  onModelChange(WidgetModel model, {String? property, dynamic value})
  {
  }

  @override
  Widget build(BuildContext context)
  {
    return Offstage();
  }
}
