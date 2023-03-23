// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/widget/widget_state.dart';
import 'busy_model.dart';

/// Busy View
///
/// Builds the View from [BUSY.Model] properties
/// Acts as an indicator that a page or widget is loading
/// to let the user know its 'busy' working in the background
class BusyView extends StatefulWidget implements IWidgetView
{
  final BusyModel model;

  BusyView(this.model) : super(key: ObjectKey(model));

  @override
  _BusyViewState createState() => _BusyViewState();
}

class _BusyViewState extends WidgetState<BusyView>
{
  @override
  Widget build(BuildContext context)
  {
    return builder(context, null);
  }

  Widget builder(BuildContext context, BoxConstraints? constraints)
  {
    // Set Build Constraints in the [WidgetModel]
      widget.model.minWidth  = constraints?.minWidth;
      widget.model.maxWidth  = constraints?.maxWidth;
      widget.model.minHeight = constraints?.minHeight;
      widget.model.maxHeight = constraints?.maxHeight;

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    //////////////
    /* Children */
    //////////////
    List<Widget> children = [];
    if (widget.model.children != null)
      widget.model.children!.forEach((model)
      {
        if (model is IViewableWidget) {
          children.add((model as IViewableWidget).getView());
        }
      });

    //////////
    /* View */
    //////////
    var modal = widget.model.modal;
    var size  = widget.model.size ?? 100;
    var col   = Theme.of(context).colorScheme.inversePrimary.withOpacity(0.90);
    var color = widget.model.color ?? col;// ?? Theme.of(context).colorScheme.inversePrimary ?? Color(0xFF11CDEF).withOpacity(.95);

    if (size < 10) size = 10;
    double stroke = size / 10.0;
    if (stroke < 1.0) stroke = 1.0;

    Widget view = CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(color), strokeWidth: stroke);
    //Widget view = Image.asset("images/progress.gif");
    var spinner  = SizedBox(width: size + 10, height: size + 10, child: view);
    var curtain;
    if (modal)
    {
      Size s = MediaQuery.of(context).size;
      curtain = SizedBox(width: s.width, height: s.height, child: Opacity(child: ModalBarrier(dismissible: false, color: Theme.of(context).colorScheme.primary), opacity: .25));
    }
    if (curtain != null) children.add(curtain);

    children.add(spinner);

    if (children.isEmpty) children.add(Container());

    view = Container(color: Colors.transparent, child: Stack(alignment: Alignment(0.0, 0.0), children: children));

    // wrap constraints
    return getConstrainedView(widget, view);
  }
}

