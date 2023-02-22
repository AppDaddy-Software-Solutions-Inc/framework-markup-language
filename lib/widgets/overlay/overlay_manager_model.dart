// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/overlay/overlay_manager_view.dart';
import 'package:fml/widgets/overlay/overlay_view.dart';

class OverlayManagerModel
{
  final List<OverlayView?> overlays = [];
  final List<OverlayView?> parking  = [];
  final Widget child;

  OverlayManagerViewState? state;

  OverlayManagerModel(this.child);

  void refresh() => state?.refresh();

  void dispose()
  {
   overlays.clear();
   parking.clear();
   state = null;
  }

  int? park(OverlayView overlay)
  {
    if (!overlay.model.minimized) return null;

    // Already Parked
    if (parking.contains(overlay)) return parking.indexOf(overlay);

    // Lot Full - Make Space
    if (!parking.contains(null)) parking.add(null);

    // First Empty Space
    int space = parking.indexOf(null);
    parking[space] = overlay;
    return space;
  }

  void unpark(OverlayView overlay)
  {
    // Free Up Space
    if ((parking.contains(overlay)))
    {
      parking[parking.indexOf(overlay)] = null;
    }
  }

  void bringToFront(Widget widget)
  {
    if ((overlays.contains(widget)) && (widget != overlays.last))
    {
      overlays.remove(widget);
      overlays.add(widget as OverlayView);
      refresh();
    }
  }
}
