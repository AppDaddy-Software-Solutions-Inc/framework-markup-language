import 'dart:ui';

abstract class IScrollable
{
  void scrollUp(int pixels);
  void scrollDown(int pixels);
  Offset? positionOf();
  Size? sizeOf();

  bool moreUp = false;
  bool moreDown = false;
  bool moreLeft = false;
  bool moreRight = false;
}