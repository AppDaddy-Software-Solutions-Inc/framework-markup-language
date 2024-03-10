import 'package:flutter/material.dart';

/// A clipper that uses [Decoration.getClipPath] to clip.
class DecorationClipper extends CustomClipper<Path>
{
  DecorationClipper({TextDirection? textDirection, required this.decoration,
  }) : textDirection = textDirection ?? TextDirection.ltr;

  final TextDirection textDirection;
  final Decoration decoration;

  @override
  Path getClip(Size size)
  {
    return decoration.getClipPath(Offset.zero & size, textDirection);
  }

  @override
  bool shouldReclip(DecorationClipper oldClipper)
  {
    return oldClipper.decoration != decoration || oldClipper.textDirection != textDirection;
  }
}