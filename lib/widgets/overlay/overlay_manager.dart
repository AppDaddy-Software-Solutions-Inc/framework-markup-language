// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/overlay/overlay_manager_model.dart';
import 'package:fml/widgets/overlay/overlay_view.dart';

class OverlayManager extends StatefulWidget
{
  final OverlayManagerModel model;

  OverlayManager(this.model) : super();

  @override
  OverlayManagerState createState() => OverlayManagerState();
}

class OverlayManagerState extends State<OverlayManager>
{
  void refresh()
  {
    setState(() {});
  }

  @override
  void initState()
  {
    super.initState();
    widget.model.state = this;
  }

  @override
  void didUpdateWidget(OverlayManager oldWidget)
  {
    super.didUpdateWidget(oldWidget);
    widget.model.state = this;
  }

  @override
  void didChangeDependencies()
  {
    super.didChangeDependencies();
    widget.model.state = this;
  }

  @override
  void dispose()
  {
    super.dispose();
    widget.model.dispose();
  }

  @override
  Widget build(BuildContext context)
  {
    List<Widget> children  = [];
    children.add(widget.model.child);
    widget.model.overlays.forEach((overlay)
    {
      if (overlay != null)
      {
        Widget view = overlay;
        if (overlay.model.modal == true)
        {
          children.add(ModalBarrier(dismissible: false, color: overlay.model.modalBarrierColor ?? Theme.of(context).colorScheme.inverseSurface.withOpacity(0.25)));
          children.add(GestureDetector(child: UnconstrainedBox(child: SizedBox(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height, child: Container(color: Colors.transparent))), onTap: () => onDismiss(overlay)));
        }
        children.add(view);
      }
    });
    return Stack(children: children, fit: StackFit.passthrough);
  }

  void onDismiss(OverlayView? overlay)
  {
    if (overlay != null) overlay.model.dismiss();
  }
}