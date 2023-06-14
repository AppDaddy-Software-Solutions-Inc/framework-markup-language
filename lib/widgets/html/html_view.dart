// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/iwidget_view.dart';
import 'package:fml/widgets/html/html_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class HtmlView extends StatefulWidget implements IWidgetView
{
  @override
  final HtmlModel model;

  HtmlView(this.model) : super(key: ObjectKey(model));

  @override
  State<HtmlView> createState() => _HtmlViewState();
}

class _HtmlViewState extends WidgetState<HtmlView>
{
  @override
  Widget build(BuildContext context)
  {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible || widget.model.value == null) return Offstage();

    Widget view;

    view = SizedBox(
        width: widget.model.width,
        height: widget.model.height,
        child: Html(
          shrinkWrap: true,
          data: widget.model.value,
          onLinkTap: (url, _, __) {
            Log().debug("Html: Opening $url...", caller: 'Html_view');
          },
          onCssParseError: (css, messages) {
            Log().debug("css that errored: $css", caller: 'Html_view');
            Log().debug("error messages:", caller: 'Html_view');
            for (var element in messages) {
              Log().debug('$element', caller: 'Html_view');
            }
            return null;
            },
        ));


    // apply user defined constraints
    return applyConstraints(view, widget.model.constraints);
  }
}