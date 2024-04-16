import 'dart:ui';

abstract class IScrollable {

  void scrollTo(String? id, {required bool animate});
  void scroll(double? pixels, {required bool animate});

  Offset? positionOf();
  Size? sizeOf();

  bool moreUp = false;
  bool moreDown = false;
  bool moreLeft = false;
  bool moreRight = false;
}
