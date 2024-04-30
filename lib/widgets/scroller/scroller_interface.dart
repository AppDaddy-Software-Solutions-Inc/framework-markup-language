import 'dart:ui';

abstract class IScrollable {

  void scrollTo(String? id, String? value, {bool animate = true});
  void scroll(double? pixels, {bool animate = true});

  Offset? positionOf();
  Size? sizeOf();

  bool moreUp = false;
  bool moreDown = false;
  bool moreLeft = false;
  bool moreRight = false;
}
