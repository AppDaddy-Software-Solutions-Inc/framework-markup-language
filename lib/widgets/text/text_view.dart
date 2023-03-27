// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/helper/string.dart';
import 'package:fml/widgets/expanded/expanded_model.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/text/text_model.dart';
import 'package:fml/widgets/widget/widget_state.dart';
import 'package:google_fonts/google_fonts.dart' deferred as fonts;
import 'package:fml/eval/textParser.dart' as parse;
import 'package:flutter/material.dart';

class TextView extends StatefulWidget implements IWidgetView
{
  final TextModel model;
  TextView(this.model) : super(key: ObjectKey(model));

  @override
  _TextViewState createState() => _TextViewState();
}

class _TextViewState extends WidgetState<TextView>
{
  ThemeData? theme;
  String? text;

  // google fonts
  static Completer? libraryLoader;
  List<parse.TextValue> markupTextValues = [];

  @override
  void initState()
  {
    super.initState();

    // load the library
    if (libraryLoader == null)
    {
      libraryLoader = Completer();
      fonts.loadLibrary().then((value) => libraryLoader!.complete(true));
    }

    // wait for the library to load
    if (!libraryLoader!.isCompleted) libraryLoader!.future.whenComplete(()
    {
      if (mounted) setState(() {});
    });
  }

  @override
  didChangeDependencies()
  {
    text = null;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context)
  {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // get the theme
    theme = Theme.of(context);

    // use this to optimize
    bool textHasChanged = (text != widget.model.value);
    text = widget.model.value;

    // build the view
    Widget view = widget.model.raw ? _getSimpleTextView() : _getRichTextView(rebuild: textHasChanged);

    // is part of a larger span?
    if (widget.model.isSpan) return SizedBox(child: view);

    // check if parent is an expanded widget
    bool isNotExpandedChild = false;
    var c = widget.model.getLocalConstraints();
    if (c.hasNoHorizontalConstraints) isNotExpandedChild = widget.model.findAncestorOfExactType(ExpandedModel) == null;

    // constrained?
    if (isNotExpandedChild || c.hasHorizontalConstraints)
    {
      var constraints = widget.model.getGlobalConstraints();
      view = ConstrainedBox(child: view, constraints: BoxConstraints(minWidth: constraints.minWidth!, maxWidth: constraints.maxWidth!));
    }

    return view;
  }

  void _parseText(String? value)
  {
    String? finalVal = '';
    if (widget.model.raw) return;

    try
    {
      if (value?.contains(':') ?? false) value = S.parseEmojis(value!);
      markupTextValues = [];
      parse.textValues = [];
      parse.matchElements(value ?? '');
      parse.textValues.isNotEmpty
          ? markupTextValues = parse.textValues
          : markupTextValues = [];
      markupTextValues.forEach((element) {
        finalVal = finalVal! + element.text;
      });
    } catch(e) {
      finalVal = value;
    }
  }

  Widget _getRichTextView({required bool rebuild})
  {
    TextStyle? textStyle = _getStyle();
    TextOverflow textOverflow = _getOverflow();
    TextAlign textAlign = _getAlign();
    TextDecoration textDecoration = _getDecoration();
    TextDecorationStyle? textDecoStyle = _getDecorationStyle();
    Shadow? textShadow = _getShadow();

    // re-parse the text
    if (rebuild) _parseText(widget.model.value);

    // build text spans
    List<InlineSpan> textSpans = _buildTextSpans(textShadow, textDecoStyle);

    var style = TextStyle(
        fontSize: widget.model.size ?? textStyle!.fontSize,
        color: widget.model.color ?? theme?.colorScheme.onBackground,
        fontWeight: widget.model.bold ? FontWeight.bold : textStyle!.fontWeight,
        fontStyle: widget.model.italic ? FontStyle.italic : textStyle!.fontStyle,
        decoration: textDecoration);

    return RichText(text: TextSpan(children: textSpans, style: style), overflow: textOverflow, textAlign: textAlign);
  }

  Widget _getSimpleTextView()
  {
    TextDecoration textDecoration = _getDecoration();
    TextDecorationStyle? textDecoStyle = _getDecorationStyle();
    Shadow? textShadow = _getShadow();

    TextStyle? textstyle;
    String? font = widget.model.font;
    if (font != null && (libraryLoader?.isCompleted ?? false))
    {
      TextStyle? textStyle = _getStyle();
      textstyle = fonts.GoogleFonts.getFont(
          font,
          fontSize: widget.model.size ?? textStyle?.fontSize,
          wordSpacing: widget.model.wordspace,
          letterSpacing: widget.model.letterspace,
          height: widget.model.lineheight,
          shadows: textShadow != null ? [textShadow] : null,
          fontWeight: widget.model.bold  ? FontWeight.bold : FontWeight.normal,
          fontStyle: widget.model.italic ? FontStyle.italic : FontStyle.normal,
          decoration: textDecoration,
          decorationStyle: textDecoStyle,
          decorationColor: widget.model.decorationcolor,
          decorationThickness: widget.model.decorationweight);
    }
    else
    {
      textstyle = TextStyle(
          wordSpacing: widget.model.wordspace,
          letterSpacing: widget.model.letterspace,
          height: widget.model.lineheight,
          shadows: textShadow != null ? [textShadow] : null,
          fontWeight: widget.model.bold ? FontWeight.bold : FontWeight.normal,
          fontStyle: widget.model.italic ? FontStyle.italic : FontStyle.normal,
          decoration: textDecoration,
          decorationStyle: textDecoStyle,
          decorationColor: widget.model.decorationcolor,
          decorationThickness: widget.model.decorationweight);
    }

    //SizedBox is used to make the text fit the size of the widget.
    return SizedBox(width: widget.model.width, child: Text(widget.model.value ?? '', style: textstyle));
  }

  TextOverflow _getOverflow()
  {
    TextOverflow textOverflow = TextOverflow.visible;
    switch (widget.model.overflow?.toLowerCase())
    {
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

  TextAlign _getAlign()
  {
    TextAlign? textAlign = TextAlign.start;
    switch (widget.model.halign?.toLowerCase())
    {
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

  TextDecoration _getDecoration()
  {
    TextDecoration textDecoration = TextDecoration.none;
    switch (widget.model.decoration?.toLowerCase())
    {
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

  TextDecorationStyle? _getDecorationStyle()
  {
    TextDecorationStyle? textDecoStyle;
    switch (widget.model.decorationstyle?.toLowerCase())
    {
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

  TextStyle? _getStyle()
  {
    if (theme == null) return null;

    // get theme
    var textTheme = theme!.textTheme;

    TextStyle? textStyle = textTheme.bodyMedium;
    switch (widget.model.style?.toLowerCase())
    {
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
      case"headlinesmall":
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

  Shadow? _getShadow()
  {
    if (widget.model.elevation <= 0) return null;
    var color = widget.model.shadowcolor ?? theme?.colorScheme.outline.withOpacity(0.4) ?? Colors.black45;
    return Shadow(color: color, blurRadius: widget.model.elevation, offset: Offset(widget.model.shadowx!,widget.model.shadowy!));
  }

  List<InlineSpan> _buildTextSpans(Shadow? shadow, TextDecorationStyle? textDecoStyle)
  {
    List<InlineSpan> textSpans = [];

    if (markupTextValues.isNotEmpty)
    markupTextValues.forEach((element)
    {
      InlineSpan textSpan;
      FontWeight? weight;
      FontStyle? style;
      String? script;
      TextDecoration? deco;
      Color? codeBlockBG;
      String? codeBlockFont;

      element.styles.forEach((element)
      {
        switch (element)
        {
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
            codeBlockBG = theme?.colorScheme.surfaceVariant;
            codeBlockFont = 'Cutive Mono';
            weight = FontWeight.w600;
            break;
          default:
            codeBlockBG = theme?.colorScheme.surfaceVariant;
            codeBlockFont = null;
            weight = FontWeight.normal;
            style = FontStyle.normal;
            deco = TextDecoration.none;
            script = "normal";
            break;
        }
      });

      String text = element.text.replaceAll('\\n', '\n').replaceAll('\\t','\t\t\t\t');

      if (widget.model.addWhitespace) text = ' ' + text;

      //4 ts here as dart interprets the tab character as a single space.
      if (script == "sub")
      {
        WidgetSpan widgetSpan = WidgetSpan(child: Transform.translate(
          offset: const Offset(2, 4),
          child: Text(text, textScaleFactor: 0.7,
            style: TextStyle(
                wordSpacing: widget.model.wordspace,
                letterSpacing: widget.model.letterspace,
                height: widget.model.lineheight,
                shadows: shadow != null ? [shadow] : null,
                fontWeight: weight,
                fontStyle: style,
                decoration: deco,
                decorationStyle: textDecoStyle,
                decorationColor: widget.model.decorationcolor,
                decorationThickness: widget.model.decorationweight),),),);
        textSpans.add(widgetSpan);
      }
      else if (script == "sup")
      {
        WidgetSpan widgetSpan = WidgetSpan(child: Transform.translate(
          offset: const Offset(2, -4),
          child: Text(text, textScaleFactor: 0.7,
            style: TextStyle(
                wordSpacing: widget.model.wordspace,
                letterSpacing: widget.model.letterspace,
                height: widget.model.lineheight,
                shadows: shadow != null ? [shadow] : null,
                fontWeight: weight,
                fontStyle: style,
                decoration: deco,
                decorationStyle: textDecoStyle,
                decorationColor: widget.model.decorationcolor,
                decorationThickness: widget.model.decorationweight),),),);
        textSpans.add(widgetSpan);
      }
      else
      {
        TextStyle? textstyle;
        String? font = codeBlockFont ?? widget.model.font;
        if (font != null && (libraryLoader?.isCompleted ?? false))
        {
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
        }
        else
        {
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
    });

    return textSpans;
  }
}