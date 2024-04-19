// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/viewable/viewable_widget_view.dart';
import 'package:fml/widgets/viewable/viewable_widget_state.dart';
import 'busy_model.dart';

/// Busy View
///
/// Builds the View from [BUSY.Model] properties
/// Acts as an indicator that a page or widget is loading
/// to let the user know its 'busy' working in the background
class BusyView extends StatefulWidget implements ViewableWidgetView {
  @override
  final BusyModel model;

  BusyView(this.model) : super(key: ObjectKey(model));

  @override
  State<BusyView> createState() => _BusyViewState();
}

class _BusyViewState extends ViewableWidgetState<BusyView> {
  @override
  Widget build(BuildContext context) {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return const Offstage();

    // build the child views
    List<Widget> children = widget.model.inflate();

    // view
    var modal = widget.model.modal;
    var size = widget.model.size ?? 32;
    var col = Theme.of(context).colorScheme.inversePrimary;
    var color = widget.model.color ??
        col; // ?? Theme.of(context).colorScheme.inversePrimary ?? Color(0xFF11CDEF).withOpacity(.95);

    if (size < 10) size = 10;
    var stroke = (size / 10.0).ceilToDouble();
    if (stroke < 1.0) stroke = 1.0;

    Widget view = CircularProgressIndicator.adaptive(
        valueColor: AlwaysStoppedAnimation<Color>(color), strokeWidth: stroke);
    var spinner = SizedBox(width: size + 10, height: size + 10, child: view);
    Widget? curtain;
    if (modal) {
      Size s = MediaQuery.of(context).size;
      curtain = SizedBox(
          width: s.width,
          height: s.height,
          child: Opacity(
              opacity: .50,
              child: ModalBarrier(
                  dismissible: false,
                  color: Theme.of(context).colorScheme.background)));
    }
    if (curtain != null) children.add(curtain);

    children.add(spinner);

    if (children.isEmpty) children.add(Container());

    view = Container(
        color: Colors.transparent,
        child: Stack(alignment: const Alignment(0.0, 0.0), children: children));

    // add margins
    view = addMargins(view);

    // apply visual transforms
    view = applyTransforms(view);

    // apply user defined constraints
    view = applyConstraints(view, widget.model.constraints);

    return view;
  }
}
