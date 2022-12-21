// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/widgets/html/html_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class HtmlView extends StatefulWidget {
  final HtmlModel model;

  HtmlView(this.model) : super(key: ObjectKey(model));

  @override
  _HtmlViewState createState() => _HtmlViewState();
}

class _HtmlViewState extends State<HtmlView> implements IModelListener {
  @override
  void initState() {
    super.initState();

    
    widget.model.registerListener(this);

    // If the model contains any databrokers we fire them before building so we can bind to the data
    widget.model.initialize();
  }

  @override
  void didUpdateWidget(HtmlView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (
        (oldWidget.model != widget.model)) {
      oldWidget.model.removeListener(this);
      widget.model.registerListener(this);
    }

  }

  @override
  void dispose() {
     widget.model.removeListener(this);

    super.dispose();
  }

  /// Callback to fire the [_HtmlViewState.build] when the [Model] changes
  onModelChange(WidgetModel model, {String? property, dynamic value}) {
    if (this.mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible || widget.model.value == null) return Offstage();

    Widget view;

    view = SizedBox(
        width: widget.model.width,
        height: widget.model.height,
        child: Html(
          shrinkWrap: true,
          data: widget.model.value,
          onLinkTap: (url, _, __, ___) {
            Log().debug("Opening $url...");
          },
          onImageTap: (src, _, __, ___) {
            Log().debug(src ?? "");
          },
          onImageError: (exception, stackTrace) {
            Log().exception(exception);
          },
          onCssParseError: (css, messages) {
            Log().debug("css that errored: $css");
            Log().debug("error messages:");
            messages.forEach((element) {
              Log().debug('$element');
            });
            return null;
            },
        ));


    //////////////////
    /* Constrained? */
    //////////////////
    if (widget.model.constrained) {
      var constraints = widget.model.getConstraints();
      view = ConstrainedBox(
          child: view,
          constraints: BoxConstraints(
              minHeight: constraints.minHeight!,
              maxHeight: constraints.maxHeight!,
              minWidth: constraints.minWidth!,
              maxWidth: constraints.maxWidth!));
    }

    return view;
  }
}