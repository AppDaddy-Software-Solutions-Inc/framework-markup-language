// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/window/window_manager_view.dart';
import 'package:fml/widgets/window/window_view.dart';

class WindowManagerModel {
  final List<WindowView?> windows = [];
  final List<WindowView?> parking = [];
  final Widget child;

  WindowManagerViewState? state;

  WindowManagerModel(this.child);

  void refresh() => state?.refresh();

  void dispose() {
    windows.clear();
    parking.clear();
    state = null;
  }

  int? park(WindowView modal) {
    if (!modal.model.minimized) return null;

    // Already Parked
    if (parking.contains(modal)) return parking.indexOf(modal);

    // Lot Full - Make Space
    if (!parking.contains(null)) parking.add(null);

    // First Empty Space
    int space = parking.indexOf(null);
    parking[space] = modal;
    return space;
  }

  void unpark(WindowView modal) {
    // Free Up Space
    if ((parking.contains(modal))) {
      parking[parking.indexOf(modal)] = null;
    }
  }

  void bringToFront(Widget widget) {
    if ((windows.contains(widget)) && (widget != windows.last)) {
      windows.remove(widget);
      windows.add(widget as WindowView);
      refresh();
    }
  }
}
