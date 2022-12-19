// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'scroll_shadow_model.dart';

class ScrollShadowView extends StatefulWidget
{
  final ScrollShadowModel model;

  ScrollShadowView(this.model) : super(key: ObjectKey(model));

  @override
  _ScrollShadowViewState createState() => _ScrollShadowViewState();
}

class _ScrollShadowViewState extends State<ScrollShadowView> implements IModelListener
{
  @override
  void initState()
  {
    super.initState();

    ////////////////////////////
    /* Register the Listeners */
    ////////////////////////////
    widget.model.registerListener(this);
  }

  @override
  didChangeDependencies()
  {
    super.didChangeDependencies();
    widget.model.registerListener(this);
  }

  @override
  void didUpdateWidget(ScrollShadowView oldWidget)
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
    //////////
    /* View */
    //////////

    var col = Theme.of(context).brightness == Brightness.light ? Theme.of(context).colorScheme.shadow.withOpacity(0.35) : Theme.of(context).colorScheme.shadow;

    List<Widget> moreShadows = [];
    // TODO - Create a better gui, ie: a rounded shadow with indicator icon
    Widget left = widget.model.left ? Positioned(left: 0, child: Container(decoration: BoxDecoration(boxShadow: [BoxShadow(blurRadius: 20, spreadRadius: 8, color: col)]), width: 1, height: MediaQuery.of(context).size.height)) : Container();
    Widget right = widget.model.right ? Positioned(right: 0, child: Container(decoration: BoxDecoration(boxShadow: [BoxShadow(blurRadius: 20, spreadRadius: 8, color: col)]), width: 1, height: MediaQuery.of(context).size.height)) : Container();
    Widget top = widget.model.up ? Positioned(top: 0, child: Container(decoration: BoxDecoration(boxShadow: [BoxShadow(blurRadius: 20, spreadRadius: 8, color: col)]), height: 1, width: MediaQuery.of(context).size.width)) : Container();
    Widget bottom = widget.model.down ? Positioned(bottom: 0, child: Container(decoration: BoxDecoration(boxShadow: [BoxShadow(blurRadius: 20, spreadRadius: 8, color: col)]), height: 1, width: MediaQuery.of(context).size.width)) : Container();

    moreShadows.addAll([top, bottom, left, right]);

    return Stack(children: moreShadows);
  }
}

