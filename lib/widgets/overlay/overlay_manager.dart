// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/overlay/overlay_view.dart';

class OverlayManager extends StatefulWidget
{
  final Widget? child;
  final List<OverlayView?> overlays = [];
  final List<OverlayView?> parking  = [];
  late final _OverlayManagerState state;

  OverlayManager({this.child}) : super();

  @override
  _OverlayManagerState createState()
  {
    state = _OverlayManagerState();
    return state;
  }

  refresh()
  {
    state.refresh();
  }

  int? park(OverlayView overlay)
  {
    if (!overlay.minimized) return null;

    ////////////////////
    /* Already Parked */
    ////////////////////
    if (parking.contains(overlay)) return parking.indexOf(overlay);

    ///////////////////////////
    /* Lot Full - Make Space */
    ///////////////////////////
    if (!parking.contains(null)) parking.add(null);

    ///////////////////////
    /* First Empty Space */
    ///////////////////////
    int space = parking.indexOf(null);
    parking[space] = overlay;
    return space;
  }

  void unpark(OverlayView overlay)
  {
    ///////////////////
    /* Free Up Space */
    ///////////////////
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
      overlays.add(widget as OverlayView?);
      refresh();
    }
  }
}

class _OverlayManagerState extends State<OverlayManager>
{
  void refresh()
  {
    setState(() {});
  }

  @override
  void dispose()
  {
    widget.overlays.clear();
    widget.parking.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context)
  {
    List<Widget> children  = [];
    children.add(widget.child!);
    widget.overlays.forEach((overlay)
    {
      Widget view = overlay!;
      if (overlay.modal == true)
      {
        children.add(ModalBarrier(dismissible: false, color: overlay.modalBarrierColor ?? Theme.of(context).colorScheme.inverseSurface.withOpacity(0.25)));
        children.add(GestureDetector(child: UnconstrainedBox(child: SizedBox(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height, child: Container(color: Colors.transparent))), onTap: () => onDismiss(overlay)));
      }
      children.add(view);
    });
    return Stack(children: children, fit: StackFit.passthrough);
  }

  void onDismiss(OverlayView? overlay)
  {
    if (overlay != null) overlay.dismiss();
  }
}