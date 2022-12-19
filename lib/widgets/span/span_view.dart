// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/widgets/span/span_model.dart';
import 'package:fml/widgets/text/text_model.dart';

import 'package:flutter/material.dart';

class SpanView extends StatefulWidget
{
  final SpanModel model;

  SpanView(this.model) : super(key: ObjectKey(model));

  @override
  _SpanViewState createState() => _SpanViewState();
}

class _SpanViewState extends State<SpanView> implements IModelListener {
  List<InlineSpan>? _list;

  @override
  void initState() {
    super.initState();

    
    widget.model.registerListener(this);

    // If the model contains any databrokers we fire them before building so we can bind to the data
    widget.model.initialize();
  }

  @override
  void didUpdateWidget(SpanView oldWidget) {
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

  /// Callback to fire the [_SpanViewState.build] when the [TextModel] changes
  onModelChange(WidgetModel model, {String? property, dynamic value}) {
    if (this.mounted) setState(() {});
  }

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
    //
    // switch (style?.toLowerCase()) {
    //   case "h1":
    //   case "headline1":
    //     textStyle = textTheme.headline1;
    //     break;
    //   case "h2":
    //   case "headline2":
    //     textStyle = textTheme.headline2;
    //     break;
    //   case "h3":
    //   case "headline3":
    //     textStyle = textTheme.headline3;
    //     break;
    //   case "h4":
    //   case "headline4":
    //     textStyle = textTheme.headline4;
    //     break;
    //   case "h5":
    //   case "headline5":
    //     textStyle = textTheme.headline5;
    //     break;
    //   case "h6":
    //   case "headline6":
    //     textStyle = textTheme.headline6;
    //     break;
    //   case "s1":
    //   case "sub1":
    //   case "subtitle1":
    //     textStyle = textTheme.subtitle1;
    //     break;
    //   case "s2":
    //   case "sub2":
    //   case "subtitle2":
    //     textStyle = textTheme.subtitle2;
    //     break;
    //   case "b1":
    //   case "body1":
    //   case "bodytext1":
    //     textStyle = textTheme.bodyText1;
    //     break;
    //   case "b2":
    //   case "body2":
    //   case "bodytext2":
    //     textStyle = textTheme.bodyText2;
    //     break;
    //   case "caption":
    //     textStyle = textTheme.caption;
    //     break;
    //   case "button":
    //     textStyle = textTheme.button;
    //     break;
    //   case "overline":
    //     textStyle = textTheme.overline;
    //     break;
    //   default:
    //     textStyle = textTheme.bodyText2;
    //     break;
    // }

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

    //////////////////
    /* Constrained? */
    //////////////////
    if (widget.model.constrained) {
      Map<String, double?> constraints = widget.model.constraints;
      view = ConstrainedBox(
          child: view,
          constraints: BoxConstraints(
              minHeight: constraints['minheight']!,
              maxHeight: constraints['maxheight']!,
              minWidth: constraints['minwidth']!,
              maxWidth: constraints['maxwidth']!));
    }
    return view;
  }

  _buildSpans() {
    var model = widget.model;
    _list = [];
    bool first = true;

    //////////////////////
    /* Add Empty Option */
    //////////////////////
    if ((model.spanTextValues.isNotEmpty)) {
      _list!.clear();
      for (TextModel text in model.spanTextValues) {

        text.spanRequestBuild = true;
        if(!first) text.addWhitespace = true;

        var o =  WidgetSpan(child: text.getView());
        first = false;
            _list!.add(o);
      }
    }
  }
}
