// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:fml/widgets/trigger/trigger_model.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class TriggerView extends StatefulWidget
{
  final List<Widget> children = [];
  final TriggerModel model;
  TriggerView(this.model) : super(key: ObjectKey(model));

  @override
  _TriggerViewState createState() => _TriggerViewState();
}

class _TriggerViewState extends WidgetState<TriggerView>
{
  /// Callback to fire the [_TriggerViewState.build] when the [TriggerModel] changes
  @override
  onModelChange(WidgetModel model, {String? property, dynamic value})
  {
  }

  @override
  Widget build(BuildContext context)
  {
    return Offstage();
  }
}
