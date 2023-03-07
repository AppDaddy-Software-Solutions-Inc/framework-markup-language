// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/eval/textParser.dart';
import 'package:fml/helper/string.dart';
import 'package:fml/widgets/expanded/expanded_model.dart';
import 'package:fml/widgets/scroller/scroller_model.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/text/text_model.dart';
import 'package:fml/widgets/widget/widget_state.dart';
import 'package:google_fonts/google_fonts.dart' deferred as gf;
import 'package:fml/eval/textParser.dart' as PARSE;
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
  bool gfloaded = false;
  List<TextValue> markupTextValues = [];

  @override
  void initState()
  {
    super.initState();

    // load google fonts library
    gf.loadLibrary().then((value)
    {
      // rebuild the view
      if (mounted) setState(()
      {
        gfloaded = true;
      });
    });
  }

  String? parseValue(String? value) {
    String? finalVal = '';

    if (widget.model.raw) return value;

    try {
      if (value!.contains(':')) value = S.parseEmojis(value);
      markupTextValues = [];
      PARSE.textValues = [];
      PARSE.matchElements(widget.model.value ?? '');
      PARSE.textValues.isNotEmpty
          ? markupTextValues = PARSE.textValues
          : markupTextValues = [];
      markupTextValues.forEach((element) {
        finalVal = finalVal! + element.text;
      });
    } catch(e) {
      finalVal = value;
    }

    return finalVal;
  }

  @override
  Widget build(BuildContext context)
  {

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    parseValue(widget.model.value);

    String? style = widget.model.style;
    double? size = widget.model.size;
    Color? color = widget.model.color;
    String? decoration = widget.model.decoration;
    bool bold = widget.model.bold ?? false;
    bool italic = widget.model.italic ?? false;
    String overflow = widget.model.overflow;
    String halign = widget.model.halign;
    String decorationstyle = widget.model.decorationstyle;
    double? wordSpace = widget.model.wordspace;
    double? letterSpace = widget.model.letterspace;
    double? lineSpace = widget.model.lineheight;

    TextTheme textTheme = Theme
        .of(context)
        .textTheme;
    TextStyle? textStyle = textTheme.bodyMedium;
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


    switch (style?.toLowerCase()) {
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
    var textShadow = widget.model.elevation != 0
        ? [
      Shadow(
          color: widget.model.shadowcolor ?? Theme
              .of(context)
              .colorScheme
              .outline
              .withOpacity(0.4),
          blurRadius: widget.model.elevation,
          offset: Offset(
              widget.model.shadowx!,
              widget.model
                  .shadowy!)),
    ]
        : null;


    Color? fontColor = color;
    List<InlineSpan> textSpans = [];
    //**bold** *italic* ***bold+italic***  _underline_  __strikethrough__  ___overline___ ^^subscript^^ ^superscript^

    if (markupTextValues.isNotEmpty && !widget.model.raw) {
      markupTextValues.forEach((element) {
        InlineSpan textSpan;
        FontWeight? weight;
        FontStyle? style;
        String? script;
        TextDecoration? deco;
        Color? codeBlockBG;
        String? codeBlockFont;

        element.styles.forEach((element) {
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
              codeBlockBG = Theme.of(context).colorScheme.surfaceVariant;
              codeBlockFont = 'Cutive Mono';
              weight = FontWeight.w600;
              break;
            default:
              codeBlockBG = Theme.of(context).colorScheme.surfaceVariant;
              codeBlockFont = null;
              weight = FontWeight.normal;
              style = FontStyle.normal;
              deco = TextDecoration.none;
              script = "normal";
              break;
          }
        });

        String text = element.text.replaceAll('\\n', '\n').replaceAll('\\t',
            '\t\t\t\t');

        if (widget.model.addWhitespace) text = ' ' + text;

        //4 ts here as dart interprets the tab character as a single space.
        if (script == "sub")
        {
          WidgetSpan widgetSpan = WidgetSpan(child: Transform.translate(
            offset: const Offset(2, 4),
            child: Text(text, textScaleFactor: 0.7,
              style: TextStyle(
                  wordSpacing: wordSpace,
                  letterSpacing: letterSpace,
                  height: lineSpace,
                  shadows: textShadow,
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
                  wordSpacing: wordSpace,
                  letterSpacing: letterSpace,
                  height: lineSpace,
                  shadows: textShadow,
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
          if (font != null && gfloaded)
          {
            textstyle = gf.GoogleFonts.getFont(font,
                backgroundColor: codeBlockBG,
                wordSpacing: wordSpace,
                letterSpacing: letterSpace,
                height: lineSpace,
                shadows: textShadow,
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
                wordSpacing: wordSpace,
                letterSpacing: letterSpace,
                height: lineSpace,
                shadows: textShadow,
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
    }

    if(widget.model.spanRequestBuild) return RichText(
        text: TextSpan(children: textSpans, style: TextStyle(
            fontSize: size ?? textStyle!.fontSize,
            color: fontColor ?? Theme
                .of(context)
                .colorScheme
                .onBackground,
            fontWeight: bold == true ? FontWeight.bold : textStyle!
                .fontWeight,
            fontStyle: italic == true ? FontStyle.italic : textStyle!
                .fontStyle,
            decoration: textDecoration)),
        overflow: textOverflow,
        textAlign: textAlign);



    Widget view;



    if (widget.model.raw)
    {
      TextStyle? textstyle;
      String? font = widget.model.font;
      if (font != null && gfloaded)
      {
         textstyle = gf.GoogleFonts.getFont(
            font,
            fontSize: size ?? textStyle!.fontSize,
            wordSpacing: wordSpace,
            letterSpacing: letterSpace,
            height: lineSpace,
            shadows: textShadow,
            fontWeight: widget.model.bold ?? false ? FontWeight.bold : FontWeight.normal,
            fontStyle: widget.model.italic ?? false ? FontStyle.italic : FontStyle.normal,
            decoration: textDecoration,
            decorationStyle: textDecoStyle,
            decorationColor: widget.model.decorationcolor,
            decorationThickness: widget.model.decorationweight);
      }
      else
      {
        textstyle = TextStyle(
            wordSpacing: wordSpace,
            letterSpacing: letterSpace,
            height: lineSpace,
            shadows: textShadow,
            fontWeight: widget.model.bold ?? false ? FontWeight.bold : FontWeight.normal,
            fontStyle: widget.model.italic ?? false ? FontStyle.italic : FontStyle.normal,
            decoration: textDecoration,
            decorationStyle: textDecoStyle,
            decorationColor: widget.model.decorationcolor,
            decorationThickness: widget.model.decorationweight);
      }

      //SizedBox is used to make the text fit the size of the widget.
      view = SizedBox(width: widget.model.width, child: Text(widget.model.value ?? '', style: textstyle));
    }
    else
    {
      view = SizedBox( child: RichText(
          text: TextSpan(children: textSpans, style: TextStyle(
              fontSize: size ?? textStyle!.fontSize,
              color: fontColor ?? Theme
                  .of(context)
                  .colorScheme
                  .onBackground,
              fontWeight: bold == true ? FontWeight.bold : textStyle!
                  .fontWeight,
              fontStyle: italic == true ? FontStyle.italic : textStyle!
                  .fontStyle,
              decoration: textDecoration)),
          overflow: textOverflow,
          textAlign: textAlign));
    }

    //////////////////
    /* Constrained? */
    //////////////////
    bool isNotExpandedChild = false;
    if(!widget.model.hasSizing) {
      ScrollerModel? parentScroll = widget.model.findAncestorOfExactType(
          ScrollerModel);
      if (parentScroll != null &&
          parentScroll.layout.toLowerCase() == "row") return view;
      isNotExpandedChild = widget.model.findAncestorOfExactType(ExpandedModel) == null;
    }

    if( isNotExpandedChild || widget.model.hasSizing) {
      var constr = widget.model.getConstraints();
      view = ConstrainedBox(
          child: view,
          constraints: BoxConstraints(
              minWidth: constr.minWidth!,
              maxWidth: constr.maxWidth!,
          )
      );
    }

    return view;
  }
}