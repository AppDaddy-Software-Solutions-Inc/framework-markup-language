// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/overlay/overlay_view.dart';

class OverlayModel
{
  final String? id;
  final Widget child;

  final double? width;
  final double? height;

  final bool closeable;
  final bool resizeable;
  final bool draggable;
  final bool dismissable;
  final bool modal;
  final bool? pad;
  final bool? decorate;

  final double? dx;
  final double? dy;

  final Color? color;
  final Color? modalBarrierColor;

  OverlayViewState? state;

  OverlayModel({required this.child, this.id, this.width, this.height, this.dx, this.color, this.dy, this.resizeable = true, this.draggable = true, this.modal = false, this.closeable = true, this.dismissable = true, this.modalBarrierColor, this.pad, this.decorate});

  void close()
  {
    if (state != null) state!.onClose();
  }

  void dismiss()
  {
    if (state != null) state!.onDismiss();
  }

  bool get minimized
  {
    if (state != null) return state!.minimized;
    return false;
  }
}
