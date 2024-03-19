// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/modal/modal_manager_model.dart';
import 'package:fml/widgets/modal/modal_view.dart';

class ModalManagerView extends StatefulWidget
{
  final ModalManagerModel model;

  ModalManagerView(this.model) : super(key: ObjectKey(model));

  @override
  ModalManagerViewState createState() => ModalManagerViewState();
}

class ModalManagerViewState extends State<ModalManagerView>
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
  void didUpdateWidget(ModalManagerView oldWidget)
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
    for (var modal in widget.model.modals) {
      if (modal != null)
      {
        Widget view = modal;
        if (modal.model.modal)
        {
          children.add(ModalBarrier(dismissible: false, color: Theme.of(context).colorScheme.inverseSurface.withOpacity(0.25)));
          children.add(GestureDetector(child: UnconstrainedBox(child: SizedBox(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height, child: Container(color: Colors.transparent))), onTap: () => onDismiss(modal)));
        }
        children.add(view);
      }
    }
    return Stack(fit: StackFit.passthrough, children: children);
  }

  void onDismiss(ModalView? modal)
  {
    if (modal != null) modal.model.dismiss();
  }
}