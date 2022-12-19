// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/widget_model.dart';
abstract class IViewableWidget
{
  late final String id;
  Widget getView();
  WidgetModel get model;
}