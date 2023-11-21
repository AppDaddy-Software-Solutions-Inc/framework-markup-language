import 'dart:ui';

abstract class IScrollable
{
  void scrollUp(int pixels);
  void scrollDown(int pixels);
  Offset? positionOf();
  Size? sizeOf();
}