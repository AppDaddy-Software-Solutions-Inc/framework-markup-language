// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/popover/popover_model.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;

class PopoverView extends StatefulWidget {
  final PopoverModel model;
  final Widget? child;

  PopoverView(this.model, {this.child});

  @override
  _PopoverViewState createState() => _PopoverViewState();
}

class _PopoverViewState extends State<PopoverView>
    implements IModelListener {
  @override
  void initState() {
    super.initState();

    
    widget.model.registerListener(this);

    // If the model contains any databrokers we fire them before building so we can bind to the data
    widget.model.initialize();
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(PopoverView oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if ((oldWidget.model != widget.model)) {
      oldWidget.model.removeListener(this);
      widget.model.registerListener(this);
    }

  }

  @override
  void dispose() {
    widget.model.removeListener(this);

    super.dispose();
  }

  /// Callback function for when the model changes, used to force a rebuild with setState()
  onModelChange(WidgetModel model, {String? property, dynamic value}) {
    if (this.mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible || widget.model.items.isEmpty) return Offstage();

    var popover = widget.model.enabled != false
        ? MouseRegion(cursor: SystemMouseCursors.click, child: buildPopover())
        : Opacity(opacity: 0.5, child: buildPopover());
    return popover;
  }

  Widget buildPopover() {
    List<PopupMenuEntry> itemsList = [];
    widget.model.items.forEach((item) {
      itemsList.add(PopupMenuItem(
          child: Text(item.label!, style: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer),), value: item.onclickObservable));
    });
    return SizedBox(
        height: 50,
        child:
            PopupMenuButton(
                enabled: widget.model.enabled != false,
                color: Theme.of(context).colorScheme.surfaceVariant,
                icon: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(widget.model.icon ?? Icons.more_vert,
                    color: widget.model.color ??
                        Theme.of(context).colorScheme.inverseSurface),
                      widget.model.label != null ? Text(widget.model.label!, style: TextStyle(
                        color: widget.model.color ?? Theme.of(context).colorScheme.onBackground,
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.normal,
                      )) : Offstage(),
                    ],
                ),
                padding: EdgeInsets.all(5),
                onSelected: (dynamic res) => widget.model.onClick(context, res),
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry>[...itemsList]),
          );
  }

  onViewModelChange({String? property, dynamic value}) {
    try {
      if (this.mounted) {
        setState(() {});
      }
    } catch(e) {
      Log().exception(e);
    }
  }
}
