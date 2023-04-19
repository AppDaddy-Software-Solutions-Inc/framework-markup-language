import 'package:flutter/material.dart';
import 'package:fml/widgets/layout/layout_model.dart';
abstract class ILayout
{
  LayoutType get layoutType;
  MainAxisSize get verticalAxisSize;
  MainAxisSize get horizontalAxisSize;
  bool get expandsVertically;
  bool get expandsHorizontally;
}
