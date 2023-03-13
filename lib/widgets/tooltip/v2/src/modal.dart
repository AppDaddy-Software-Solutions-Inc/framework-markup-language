// MIT License
//
// Copyright (c) 2022 Marcelo Gil
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import 'package:flutter/material.dart';
import 'package:fml/widgets/tooltip/v2/src/element_box.dart';

/// Modal is the fullscreen window displayed behind the tooltip.
/// It's used to focus the user attention to the tooltip.
class Modal extends StatelessWidget {
  final bool visible;
  final void Function()? onTap;

  const Modal({
    required this.onTap,
    this.visible = true,
    super.key,
  });

  @override
  Widget build(BuildContext context)
  {
    if (visible)
    {
      var color = Theme.of(context).brightness == Brightness.light ? Colors.black38 : Colors.black54;
      return GestureDetector(onTap: onTap, child: Container(color: color));
    }
    else return Container();
  }
}

class OverlayWithCutout extends StatelessWidget
{
  final ElementBox cutout;
  final Color color;
  final double opacity;

  OverlayWithCutout(this.cutout, this.color, this.opacity);

  @override
  Widget build(BuildContext context)
  {
    return _getCustomPaintOverlay(context);
  }
  //CustomPainter that helps us in doing this
  CustomPaint _getCustomPaintOverlay(BuildContext context)
  {
    return CustomPaint(size: MediaQuery.of(context).size, painter: OverlayPainter(cutout, color, opacity));
  }
}


class OverlayPainter extends CustomPainter
{
  final ElementBox cutout;
  final Color color;
  final double opacity;

  OverlayPainter(this.cutout, this.color, this.opacity);

  @override
  void paint(Canvas canvas, Size size)
  {
    final paint = Paint();
    paint.color = Colors.red.withOpacity(.5);

    // top
    var t = Path();
    t.addRect(Rect.fromLTWH(0, 0, size.width, cutout.y));

    // bottom
    var b = Path();
    b.addRect(Rect.fromLTWH(0, cutout.y + cutout.h, size.width, size.height - cutout.y - cutout.h));

    // left
    var l = Path();
    l.addRect(Rect.fromLTWH(0, cutout.y, cutout.x, cutout.h));

    // right
    var r = Path();
    r.addRect(Rect.fromLTWH(cutout.x + cutout.w, cutout.y, size.width - cutout.x, cutout.h));

    canvas.drawPath(t,paint);
    canvas.drawPath(l,paint);
    canvas.drawPath(b,paint);
    canvas.drawPath(r,paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
