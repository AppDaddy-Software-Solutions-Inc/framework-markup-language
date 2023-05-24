import 'package:flutter/material.dart';
class LocalBoxConstraints extends BoxConstraints
{
  const LocalBoxConstraints({
    super.minWidth = 0.0,
    super.maxWidth = double.infinity,
    super.minHeight = 0.0,
    super.maxHeight = double.infinity,
  });

  static LocalBoxConstraints from(BoxConstraints constraints)
  {
    return LocalBoxConstraints(minWidth: constraints.minWidth, maxWidth: constraints.maxWidth, minHeight: constraints.minHeight, maxHeight: constraints.maxHeight);
  }

  @override
  bool get isTight
  {
    return false;
  }
}