// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/widgets/widget/iwidget_view.dart';
import 'package:fml/widgets/span/span_model.dart';
import 'package:fml/widgets/text/text_model.dart';

import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class SpanView extends StatefulWidget implements IWidgetView
{
  @override
  final SpanModel model;

  SpanView(this.model) : super(key: ObjectKey(model));

  @override
  State<SpanView> createState() => _SpanViewState();
}

class _SpanViewState extends WidgetState<SpanView>
{
  List<InlineSpan>? _list;

  @override
  Widget build(BuildContext context)
  {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // var style = widget.model.style;
    var decoration = widget.model.decoration;
    var overflow = widget.model.overflow;
    var halign = widget.model.halign;
    var decorationstyle = widget.model.decorationstyle;
    var wordSpace = widget.model.wordspace;
    var letterSpace = widget.model.letterspace;
    var lineSpace = widget.model.lineheight;

    // TextTheme textTheme = Theme.of(context).textTheme;
    // TextStyle textStyle = textTheme.bodyText2;
    TextOverflow textOverflow = TextOverflow.ellipsis;
    TextAlign textAlign = TextAlign.left;
    TextDecoration textDecoration = TextDecoration.none;
    TextDecorationStyle textDecoStyle = TextDecorationStyle.solid;

    switch (overflow.toLowerCase()) {
      case "wrap":
        textOverflow = TextOverflow.visible;
        break;
      case "ellipses":
        textOverflow = TextOverflow.ellipsis;
        break;
      case "fade":
        textOverflow = TextOverflow.fade;
        break;
      case "clip":
        textOverflow = TextOverflow.clip;
        break;
      default:
        textOverflow = TextOverflow.visible;
        break;
    }

    switch (halign.toLowerCase()) {
      case "start":
      case "left":
        textAlign = TextAlign.left;
        break;
      case "end":
      case "right":
        textAlign = TextAlign.right;
        break;
      case "center":
        textAlign = TextAlign.center;
        break;
      case "justify":
        textAlign = TextAlign.justify;
        break;
      default:
        textAlign = TextAlign.left;
        break;
    }

    switch (decoration?.toLowerCase()) {
      case "underline":
        textDecoration = TextDecoration.underline;
        break;
      case "strikethrough":
        textDecoration = TextDecoration.lineThrough;
        break;
      case "overline":
        textDecoration = TextDecoration.overline;
        break;
      default:
        textDecoration = TextDecoration.none;
        break;
    }

    switch (decorationstyle.toLowerCase()) {
      case "dashed":
        textDecoStyle = TextDecorationStyle.dashed;
        break;
      case "dotted":
        textDecoStyle = TextDecorationStyle.dotted;
        break;
      case "double":
        textDecoStyle = TextDecorationStyle.double;
        break;
      case "wavy":
        textDecoStyle = TextDecorationStyle.wavy;
        break;
      default:
        textDecoStyle = TextDecorationStyle.solid;
        break;
    }

    var textShadow = widget.model.elevation != 0
        ? [
            Shadow(
                color: widget.model.shadowcolor ??
                    Theme.of(context).colorScheme.outline.withOpacity(0.4),
                blurRadius: widget.model.elevation,
                offset: Offset(widget.model.shadowx, widget.model.shadowy)),
          ]
        : null;

    _buildSpans();
    Widget view;

    view = SizedBox(
        width: widget.model.width,
        child: RichText(
            text: TextSpan(
              children: _list,
              style: TextStyle(
                  wordSpacing: wordSpace,
                  letterSpacing: letterSpace,
                  height: lineSpace,
                  shadows: textShadow,
                  color: Colors.red,
                  fontWeight: widget.model.bold ? FontWeight.bold : widget.model.weight as FontWeight?,
                  //fontStyle: style,
                  decoration: textDecoration,
                  decorationStyle: textDecoStyle,
                  decorationColor: widget.model.decorationcolor,
                  decorationThickness: widget.model.decorationweight),
            ),
            overflow: textOverflow,
            textAlign: textAlign));

    // apply user defined constraints
    return applyConstraints(view, widget.model.constraints.model);
  }

  _buildSpans()
  {
    var model = widget.model;
    _list = [];
    bool first = true;
    if (model.spanTextValues.isNotEmpty)
    {
      _list!.clear();
      for (TextModel text in model.spanTextValues)
      {
        if(!first) text.addWhitespace = true;
        var o =  WidgetSpan(child: text.getView());
        first = false;
        _list!.add(o);
      }
    }
  }
}
