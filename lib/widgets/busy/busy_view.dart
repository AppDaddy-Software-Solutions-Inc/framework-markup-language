// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';

import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'busy_model.dart';
import 'package:fml/system.dart'               as SYSTEM;

/// Busy View
///
/// Builds the View from [BUSY.Model] properties
/// Acts as an indicator that a page or widget is loading
/// to let the user know its 'busy' working in the background
class BusyView extends StatefulWidget
{
  final BusyModel model;

  BusyView(this.model) : super(key: ObjectKey(model));

  @override
  _BusyViewState createState() => _BusyViewState();
}

class _BusyViewState extends State<BusyView> implements IModelListener
{

  @override
  void initState()
  {
    super.initState();

    ////////////////////////////
    /* Register the Listeners */
    ////////////////////////////
    widget.model.registerListener(this);

    // If the model contains any databrokers we fire them before building so we can bind to the data
    widget.model.initialize();
  }

  @override
  didChangeDependencies()
  {
    super.didChangeDependencies();
    widget.model.registerListener(this);
  }

  
  @override
  void didUpdateWidget(BusyView oldWidget)
  {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.model != widget.model))
    {
      oldWidget.model.removeListener(this);
      widget.model.registerListener(this);
    }
  }

  @override
  void dispose()
  {
    widget.model.removeListener(this);

    super.dispose();
  }
  /// Callback function for when the model changes, used to force a rebuild with setState()
  onModelChange(WidgetModel model,{String? property, dynamic value})
  {
    if (this.mounted) setState((){});
  }

  @override
  Widget build(BuildContext context)
  {
    return builder(context, null);
  }

  Widget builder(BuildContext context, BoxConstraints? constraints)
  {
    // Set Build Constraints in the [WidgetModel]
      widget.model.minwidth  = constraints?.minWidth;
      widget.model.maxwidth  = constraints?.maxWidth;
      widget.model.minheight = constraints?.minHeight;
      widget.model.maxheight = constraints?.maxHeight;

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
    var col;
    if (SYSTEM.System().config != null) {
      col = Theme.of(context).colorScheme.inversePrimary.withOpacity(0.90);
    }
    var color = widget.model.color ?? col ?? Theme.of(context).colorScheme.inversePrimary ?? Color(0xFF11CDEF).withOpacity(.95);

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

    view = Stack(alignment: Alignment(0.0, 0.0), children: children);
      bool expand = widget.model.expand;
      Map<String, double?> constr = widget.model.constraints;
      view = Container(color: Colors.transparent, child: view);
      if (expand == false) {
        if (widget.model.height != null && widget.model.width != null)
          expand = true;
      }

      if (expand == false) {
        //unsure how to make this work with maxwidth/maxheight, as it should yet constraints always come in. What should it do? same with minwidth/minheight...
        if (widget.model.width != null) {
          view = UnconstrainedBox(
            child: LimitedBox(
              child: view,
              maxWidth: constr['maxwidth']!,
            ),
          );
        } else if (widget.model.height != null) {
          view = UnconstrainedBox(
            child: LimitedBox(
              child: view,
              maxHeight: constr['maxheight']!,
            ),
          );
        } else {
          view = UnconstrainedBox(
            child: view,
          );
        }
      } else {
        //the container blocks user input behind the busy widget so you do not have to use a container.


        view = ConstrainedBox(
            child: view,
            constraints: BoxConstraints(
                minHeight: constr['minheight']!,
                maxHeight: constr['maxheight']!,
                minWidth: constr['minwidth']!,
                maxWidth: constr['maxwidth']!));
      }
      return view;
  }
}

