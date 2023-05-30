// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/modal/modal_manager_view.dart';
import 'package:fml/widgets/modal/modal_view.dart';

class ModalManagerModel
{
  final List<ModalView?> modals = [];
  final List<ModalView?> parking  = [];
  final Widget child;

  ModalManagerViewState? state;

  ModalManagerModel(this.child);

  void refresh() => state?.refresh();

  void dispose()
  {
   modals.clear();
   parking.clear();
   state = null;
  }

  int? park(ModalView modal)
  {
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

  void unpark(ModalView modal)
  {
    // Free Up Space
    if ((parking.contains(modal)))
    {
      parking[parking.indexOf(modal)] = null;
    }
  }

  void bringToFront(Widget widget)
  {
    if ((modals.contains(widget)) && (widget != modals.last))
    {
      modals.remove(widget);
      modals.add(widget as ModalView);
      refresh();
    }
  }
}
