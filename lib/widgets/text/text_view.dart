// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/helpers/string.dart';
import 'package:fml/widgets/widget/viewable_widget_view.dart';
import 'package:fml/widgets/text/text_model.dart';
import 'package:fml/widgets/widget/viewable_widget_state.dart';
import 'package:google_fonts/google_fonts.dart' deferred as fonts;
import 'package:fml/eval/text_parser.dart' as parse;
import 'package:flutter/material.dart';

class TextView extends StatefulWidget implements ViewableWidgetView {
  @override
  final TextModel model;
  TextView(this.model) : super(key: ObjectKey(model));

  @override
  State<TextView> createState() => _TextViewState();
}

class _TextViewState extends ViewableWidgetState<TextView> {
  String? text;

  // google fonts
  static Completer? libraryLoader;
  List<parse.TextValue> markupTextValues = [];

  @override
  void initState() {
    super.initState();

    // load the library
    if (libraryLoader == null) {
      libraryLoader = Completer();
      fonts.loadLibrary().then((value) => libraryLoader!.complete(true));
    }

    // wait for the library to load
    if (!libraryLoader!.isCompleted) {
      libraryLoader!.future.whenComplete(() {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  didChangeDependencies() {
    text = null;
    super.didChangeDependencies();
  }

  void _parseText(String? value) {
    String? finalVal = '';
    if (widget.model.raw) return;

    try {
      if (value?.contains(':') ?? false) value = parseEmojis(value!);
      markupTextValues = [];
      parse.textValues = [];
      parse.matchElements(value ?? '');
      parse.textValues.isNotEmpty
          ? markupTextValues = parse.textValues
          : markupTextValues = [];
      for (var element in markupTextValues) {
        finalVal = finalVal! + element.text;
      }
    } catch (e) {
      finalVal = value;
    }
  }

  Widget _getRichTextView({required bool rebuild}) {
    // re-parse the text
    if (rebuild) _parseText(widget.model.value);

    // build text spans
    List<InlineSpan> textSpans =
        _buildTextSpans(_getTextShadow(), _getTextDecorationStyle());

    var style = TextStyle(
        fontSize: widget.model.size ?? _getTextStyle()!.fontSize,
        color: widget.model.color ?? Theme.of(context).colorScheme.onSurface,
        fontWeight: getTextWeight(),
        fontStyle:
            widget.model.italic ? FontStyle.italic : _getTextStyle()!.fontStyle,
        decoration: _getTextDecoration());

    return (widget.model.selectable)
        ? SelectableText.rich(TextSpan(children: textSpans, style: style),
            textAlign: _getTextAlignment())
        : RichText(
            text: TextSpan(children: textSpans, style: style),
            overflow: _getTextOverflow(),
            textAlign: _getTextAlignment());
  }

  Widget _getSimpleTextView() {
    TextDecoration textDecoration = _getTextDecoration();
    TextDecorationStyle? textDecoStyle = _getTextDecorationStyle();
    Shadow? textShadow = _getTextShadow();

    // text style
    TextStyle? textStyle;
    if (widget.model.font != null && (libraryLoader?.isCompleted ?? false)) {
      textStyle = fonts.GoogleFonts.getFont(
          color: widget.model.color ?? Theme.of(context).colorScheme.onSurface,
          widget.model.font!,
          fontSize: widget.model.size ?? _getTextStyle()?.fontSize,
          wordSpacing: widget.model.wordspace,
          letterSpacing: widget.model.letterspace,
          height: widget.model.lineheight,
          shadows: textShadow != null ? [textShadow] : null,
          fontWeight: getTextWeight(),
          fontStyle: widget.model.italic ? FontStyle.italic : FontStyle.normal,
          decoration: textDecoration,
          decorationStyle: textDecoStyle,
          decorationColor: widget.model.decorationcolor,
          decorationThickness: widget.model.decorationweight);
    } else {
      textStyle = TextStyle(
          color: widget.model.color ?? Theme.of(context).colorScheme.onSurface,
          wordSpacing: widget.model.wordspace,
          letterSpacing: widget.model.letterspace,
          height: widget.model.lineheight,
          shadows: textShadow != null ? [textShadow] : null,
          fontWeight: getTextWeight(),
          fontStyle: widget.model.italic ? FontStyle.italic : FontStyle.normal,
          decoration: textDecoration,
          decorationStyle: textDecoStyle,
          decorationColor: widget.model.decorationcolor,
          decorationThickness: widget.model.decorationweight);
    }

    // selectable text?
    var text = widget.model.selectable
        ? SelectableText(widget.model.value ?? '', style: textStyle)
        : Text(widget.model.value ?? '', style: textStyle);

    // SizedBox is used to make the text fit the size of the widget.
    return SizedBox(width: widget.model.width, child: text);
  }

  TextOverflow _getTextOverflow() {
    TextOverflow textOverflow = TextOverflow.visible;
    switch (widget.model.overflow?.toLowerCase()) {
      case "wrap":
        textOverflow = TextOverflow.visible;
        break;
      case "ellipsis":
      case "ellipses":
        textOverflow = TextOverflow.ellipsis;
        break;
      case "fade":
        textOverflow = TextOverflow.fade;
        break;
      case "clip":
        textOverflow = TextOverflow.clip;
        break;
    }
    return textOverflow;
  }

  TextAlign _getTextAlignment() {
    TextAlign? textAlign = TextAlign.start;
    switch (widget.model.halign?.toLowerCase()) {
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
    }
    return textAlign;
  }

  TextDecoration _getTextDecoration() {
    TextDecoration textDecoration = TextDecoration.none;
    switch (widget.model.decoration?.toLowerCase()) {
      case "underline":
        textDecoration = TextDecoration.underline;
        break;
      case "strikethrough":
        textDecoration = TextDecoration.lineThrough;
        break;
      case "overline":
        textDecoration = TextDecoration.overline;
        break;
    }
    return textDecoration;
  }

  FontWeight getTextWeight() {
    if (widget.model.bold) return FontWeight.bold;
    switch (widget.model.weight) {
      case 100:
        return FontWeight.w100;
      case 200:
        return FontWeight.w200;
      case 300:
        return FontWeight.w300;
      case 400:
        return FontWeight.w400;
      case 500:
        return FontWeight.w500;
      case 600:
        return FontWeight.w600;
      case 700:
        return FontWeight.w700;
      case 800:
        return FontWeight.w800;
      case 900:
        return FontWeight.w900;
      default:
        return FontWeight.normal;
    }
  }

  TextDecorationStyle? _getTextDecorationStyle() {
    TextDecorationStyle? textDecoStyle;
    switch (widget.model.decorationstyle?.toLowerCase()) {
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
    return textDecoStyle;
  }

  TextStyle? _getTextStyle() {
    // get theme
    var textTheme = Theme.of(context).textTheme;

    TextStyle? textStyle = textTheme.bodyMedium;
    switch (widget.model.style?.toLowerCase()) {
      case "h1":
      case "headline1":
      case "displaylarge":
        textStyle = textTheme.displayLarge;
        break;
      case "h2":
      case "headline2":
      case "displaymedium":
        textStyle = textTheme.displayMedium;
        break;
      case "h3":
      case "headline3":
      case "displaysmall":
        textStyle = textTheme.displaySmall;
        break;
      case "h4":
      case "headline4":
      case "headlinemedium":
        textStyle = textTheme.headlineMedium;
        break;
      case "h5":
      case "headline5":
      case "headlinesmall":
        textStyle = textTheme.headlineSmall;
        break;
      case "h6":
      case "headline6":
      case "titlelarge":
        textStyle = textTheme.titleLarge;
        break;
      case "s1":
      case "sub1":
      case "subtitle1":
      case "titlemedium":
        textStyle = textTheme.titleMedium;
        break;
      case "s2":
      case "sub2":
      case "subtitle2":
      case "titlesmall":
        textStyle = textTheme.titleSmall;
        break;
      case "b1":
      case "body1":
      case "bodytext1":
      case "bodylarge":
        textStyle = textTheme.bodyLarge;
        break;
      case "b2":
      case "body2":
      case "bodytext2":
      case "bodymedium":
        textStyle = textTheme.bodyMedium;
        break;
      case "caption":
      case "bodysmall":
        textStyle = textTheme.bodySmall;
        break;
      case "button":
      case "labellarge":
        textStyle = textTheme.labelLarge;
        break;
      case "overline":
      case "labelsmall":
        textStyle = textTheme.labelSmall;
        break;
      default:
        textStyle = textTheme.bodyMedium;
        break;
    }
    return textStyle;
  }

  Shadow? _getTextShadow() {
    if (widget.model.elevation <= 0) return null;
    var color = widget.model.shadowcolor ??
        Theme.of(context).colorScheme.outline.withOpacity(0.4);
    return Shadow(
        color: color,
        blurRadius: widget.model.elevation,
        offset: Offset(widget.model.shadowx!, widget.model.shadowy!));
  }

  List<InlineSpan> _buildTextSpans(
      Shadow? shadow, TextDecorationStyle? textDecoStyle) {
    List<InlineSpan> textSpans = [];

    if (markupTextValues.isNotEmpty) {
      for (var element in markupTextValues) {
        InlineSpan textSpan;
        FontWeight? weight;
        FontStyle? style;
        String? script;
        TextDecoration? deco;
        Color? codeBlockBG;
        String? codeBlockFont;

        for (var element in element.styles) {
          switch (element) {
            case "underline":
              deco = TextDecoration.underline;
              break;
            case "strikethrough":
              deco = TextDecoration.lineThrough;
              break;
            case "overline":
              deco = TextDecoration.overline;
              break;
            case "bold":
              weight = FontWeight.bold;
              break;
            case "italic":
              style = FontStyle.italic;
              break;
            case "subscript":
              script = "sub";
              break;
            case "superscript":
              script = "sup";
              break;
            case "code":
              codeBlockBG =
                  Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.7);
              codeBlockFont = 'Inconsolata';
              weight = FontWeight.w400;
              break;
            default:
              codeBlockBG = Theme.of(context).colorScheme.surfaceVariant;
              codeBlockFont = null;
              weight = getTextWeight();
              style = FontStyle.normal;
              deco = TextDecoration.none;
              script = "normal";
              break;
          }
        }

        String text =
            element.text.replaceAll('\\n', '\n').replaceAll('\\t', '\t\t\t\t');

        if (widget.model.addWhitespace) text = ' $text';

        //4 ts here as dart interprets the tab character as a single space.
        if (script == "sub") {
          WidgetSpan widgetSpan = WidgetSpan(
            child: Transform.translate(
              offset: const Offset(2, 4),
              child: Text(
                text,
                textScaler: const TextScaler.linear(0.7),
                style: TextStyle(
                    color: widget.model.color ??
                        Theme.of(context).colorScheme.onSurface,
                    wordSpacing: widget.model.wordspace,
                    letterSpacing: widget.model.letterspace,
                    height: widget.model.lineheight,
                    shadows: shadow != null ? [shadow] : null,
                    fontWeight: weight,
                    fontStyle: style,
                    decoration: deco,
                    decorationStyle: textDecoStyle,
                    decorationColor: widget.model.decorationcolor,
                    decorationThickness: widget.model.decorationweight),
              ),
            ),
          );
          textSpans.add(widgetSpan);
        } else if (script == "sup") {
          WidgetSpan widgetSpan = WidgetSpan(
            child: Transform.translate(
              offset: const Offset(2, -4),
              child: Text(
                text,
                textScaler: const TextScaler.linear(0.7),
                style: TextStyle(
                    color: widget.model.color ??
                        Theme.of(context).colorScheme.onSurface,
                    wordSpacing: widget.model.wordspace,
                    letterSpacing: widget.model.letterspace,
                    height: widget.model.lineheight,
                    shadows: shadow != null ? [shadow] : null,
                    fontWeight: weight,
                    fontStyle: style,
                    decoration: deco,
                    decorationStyle: textDecoStyle,
                    decorationColor: widget.model.decorationcolor,
                    decorationThickness: widget.model.decorationweight),
              ),
            ),
          );
          textSpans.add(widgetSpan);
        } else {
          TextStyle? textstyle;
          String? font = codeBlockFont ?? widget.model.font;
          if (font != null && (libraryLoader?.isCompleted ?? false)) {
            textstyle = fonts.GoogleFonts.getFont(font,
                backgroundColor: codeBlockBG,
                wordSpacing: widget.model.wordspace,
                letterSpacing: widget.model.letterspace,
                height: widget.model.lineheight,
                shadows: shadow != null ? [shadow] : null,
                fontWeight: weight,
                fontStyle: style,
                decoration: deco,
                decorationStyle: textDecoStyle,
                decorationColor: widget.model.decorationcolor,
                decorationThickness: widget.model.decorationweight);
          } else {
            textstyle = TextStyle(
                wordSpacing: widget.model.wordspace,
                letterSpacing: widget.model.letterspace,
                height: widget.model.lineheight,
                shadows: shadow != null ? [shadow] : null,
                fontWeight: weight,
                fontStyle: style,
                decoration: deco,
                decorationStyle: textDecoStyle,
                decorationColor: widget.model.decorationcolor,
                decorationThickness: widget.model.decorationweight);
          }
          textSpan = TextSpan(text: text, style: textstyle);
          textSpans.add(textSpan);
        }
      }
    }

    return textSpans;
  }

  @override
  Widget build(BuildContext context) {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return const Offstage();

    // use this to optimize
    bool textHasChanged = (text != widget.model.value);
    text = widget.model.value;

    // build the view
    Widget view = widget.model.raw
        ? _getSimpleTextView()
        : _getRichTextView(rebuild: textHasChanged);

    // is part of a larger span?
    if (widget.model.isSpan) return SizedBox(child: view);

    // add margins
    view = addMargins(view);

    // apply visual transforms
    view = applyTransforms(view);

    // apply user defined constraints
    view = applyConstraints(view, widget.model.constraints);

    return view;
  }
}
