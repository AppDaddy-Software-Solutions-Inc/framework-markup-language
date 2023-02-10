// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/widgets/input/input_formatters.dart';
import 'package:flutter_multi_formatter/formatters/credit_card_cvc_input_formatter.dart';
import 'package:flutter_multi_formatter/formatters/credit_card_expiration_input_formatter.dart';
import 'package:flutter_multi_formatter/formatters/credit_card_number_input_formatter.dart';
import 'package:flutter_multi_formatter/formatters/masked_input_formatter.dart';
import 'package:flutter_multi_formatter/formatters/money_input_formatter.dart';
import 'package:flutter_multi_formatter/formatters/phone_input_formatter.dart';
import 'package:fml/system.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/input/input_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class InputView extends StatefulWidget {
  final InputModel model;
  final dynamic onChangeCallback;
  final dynamic onSubmitted;

  InputView(this.model, {this.onChangeCallback, this.onSubmitted}) : super(key: ObjectKey(model));

  @override
  _InputViewState createState() => _InputViewState();
}

class _InputViewState extends State<InputView> with WidgetsBindingObserver implements IModelListener
{
  final focus = FocusNode();
  bool hasSetObscure = false;
  RenderBox? box;
  Offset? position;
  Timer? debounce;
  Function? validator;
  bool? obscure = false;
  String? errorText;
  bool userSetErrorText = false;
  String? overrideErrorText;
  String? oldValue = "";

  static const Map<String, TextInputAction> keyboardInputs = {
    'next': TextInputAction.next,
    'done': TextInputAction.done,
    'go': TextInputAction.go,
    'search': TextInputAction.search,
    'send': TextInputAction.send,
  };

  static const Map<String, TextInputType> keyboardTypes = {
    'text': TextInputType.text,
    'url': TextInputType.url,
    'name': TextInputType.name,

    'number': TextInputType.numberWithOptions(decimal: true),
    'numeric': TextInputType.numberWithOptions(decimal: true),

    'datetime': TextInputType.datetime,
    'date': TextInputType.datetime,
    'time': TextInputType.datetime,

    'emailaddress': TextInputType.emailAddress,
    'email': TextInputType.emailAddress,

    'password': TextInputType.visiblePassword,
    'phone': TextInputType.phone,

    'streetaddress': TextInputType.streetAddress,
    'address': TextInputType.streetAddress,

    'multiline': TextInputType.multiline,
    'none' : TextInputType.none
  };

  @override
  void initState()
  {
    super.initState();

    // create the controller if its not already created in the model.
    // This allows us to get around having to use GlobalKey() on the Input to preserve the controller state
    if (widget.model.controller == null) widget.model.controller = TextEditingController();

    // Set Controller Text
    if (widget.model.errortext != null) userSetErrorText = true;

    // set controller value
    widget.model.controller!.value = TextEditingValue(text: widget.model.value ?? "", selection: TextSelection.fromPosition(TextPosition(offset: widget.model.controller!.text.characters.length)));

    //////////////////////
    /* On Loss of Focus */
    //////////////////////
    focus.addListener(onFocusChange);

    
    widget.model.registerListener(this);

    // If the model contains any databrokers we fire them before building so we can bind to the data
    widget.model.initialize();

    // Debounce
    widget.model.controller!.addListener(_onInputChange);

    //////////////////////////////////////
    /* Add WidgetsBindingObserver mixin */
    //////////////////////////////////////
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  didChangeDependencies()
  {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(InputView oldWidget)
  {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.model != widget.model)
    {
      oldWidget.model.removeListener(this);
      widget.model.registerListener(this);
    }

    var oldcursorPos = widget.model.controller!.selection.base.offset;
    widget.model.controller!.value = TextEditingValue(text: widget.model.value ?? "", selection: TextSelection.fromPosition(TextPosition(offset: oldcursorPos)));

  }

  @override
  void dispose()
  {
    // cleanup the controller.
    // its important to set the controller to null so that it gets recreated
    // when the input rebuilds.
    widget.model.controller?.removeListener(_onInputChange);
    widget.model.controller?.dispose();
    widget.model.controller = null;

    focus.dispose();

    widget.model.removeListener(this);

    // Remove WidgetsBindingObserver mixin
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  /// Callback to fire the [_InputViewState.build] when the [InputModel] changes
  onModelChange(WidgetModel model, {String? property, dynamic value})
  {
    // ensure we don't call setstate if the model update was entered via
    // keyboard by comparing the controller to the callback's value
    var b = Binding.fromString(property);
    if (this.mounted && ((widget.model.controller!.text != value && b?.property == 'value') || b?.property != 'value'))
    {
      setState(() {
        // This places the cursor at the end of the selection when focussed.
        // This must be after the text is set to the models value. - 7eaae252 - IO
        // *edit* I have moved this back above as it was resetting the cursor to
        // * the start every commit originally there was an issue with clear +
        // * form that we can't reproduce, causing a loop on selection and this
        // * line fixed it, likely a coincidence but somewhere lies a bug. - BF
        var oldcursorPos = widget.model.controller!.selection.base.offset;
        widget.model.controller!.value = TextEditingValue(text: widget.model.value ?? "", selection: TextSelection.fromPosition(TextPosition(offset: oldcursorPos)));
      });
    }
  }

  _onInputChange() {
      _commit(passDebounce: false);
  }

  @override
  void didChangeMetrics() {
    if (focus.hasFocus) {
      _ensureVisible();
    }
  }

  Future<Null> _keyboardToggled() async {
    if (mounted) {
      EdgeInsets edgeInsets = MediaQuery.of(context).viewInsets;
      while (mounted && MediaQuery.of(context).viewInsets == edgeInsets) {
        await new Future.delayed(const Duration(milliseconds: 10));
      }
    }
    return;
  }

  Future<Null> _ensureVisible() async {
    // Wait for the keyboard to come into view
    await Future.any([
      new Future.delayed(const Duration(milliseconds: 50)),
      _keyboardToggled()
    ]);

    // No need to go any further if the node has not the focus
    if (!focus.hasFocus) {
      return;
    }

    // Find the object which has the focus
    final RenderObject? object = context.findRenderObject();
    final RenderAbstractViewport? viewport = RenderAbstractViewport.of(object);

    // If we are not working in a Scrollable, skip this routine
    if (viewport == null) {
      return;
    }

    // Get the Scrollable state (in order to retrieve its offset)
    ScrollableState scrollableState = Scrollable.of(context);

    // Get its offset
    ScrollPosition position = scrollableState.position;
    double alignment;

    if (position.pixels > viewport.getOffsetToReveal(object!, 0.0).offset) {
      // Move down to the top of the viewport
      alignment = 1.0;
    } else if (position.pixels <
        (viewport.getOffsetToReveal(object, 1.0).offset +
            MediaQuery.of(context).viewInsets.bottom)) {
      // Move up to the bottom of the viewport
      alignment = 0.0;
    } else {
      // No scrolling is necessary to reveal the child
      return;
    }

    position.ensureVisible(
      object,
      alignment: alignment,
      duration: Duration(milliseconds: 100),
      curve: Curves.linearToEaseOut,
    );
  }

  _handleSubmit(String _) {
    try {
      if (S.isNullOrEmpty(widget.model.keyboardinput) ||
          widget.model.keyboardinput!.toLowerCase() == 'done' ||
          widget.model.keyboardinput!.toLowerCase() == 'go' ||
          widget.model.keyboardinput!.toLowerCase() == 'search' ||
          widget.model.keyboardinput!.toLowerCase() == 'send') {
        focus.unfocus();
        return;
      } else if (widget.model.keyboardinput!.toLowerCase() == 'next') {
        try {
          FocusScope.of(context).nextFocus();
        } catch(e) {
          focus.unfocus();
        }
        return;
      } else
        return;
    } catch(e) {
      return;
    }
  }

  @override
  Widget build(BuildContext context)
  {
    return LayoutBuilder(builder: builder);
  }

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _afterBuild(context);
    });

    // Set Build Constraints in the [WidgetModel]
    widget.model.minWidth = constraints.minWidth;
    widget.model.maxWidth = constraints.maxWidth;
    widget.model.minHeight = constraints.minHeight;
    widget.model.maxHeight = constraints.maxHeight;

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // set the border color arrays
    Color? enabledBorderColor;
    Color? disabledBorderColor;
    Color? focusBorderColor;
    Color? errorBorderColor;
    List? bordercolors = [];
    if (widget.model.bordercolor != null) {
      bordercolors = widget.model.bordercolor?.split(',');
      enabledBorderColor = ColorObservable.toColor(bordercolors![0]?.trim());
      if (bordercolors.length > 1)
        disabledBorderColor = ColorObservable.toColor(bordercolors[1]?.trim());
      if (bordercolors.length > 2)
        focusBorderColor = ColorObservable.toColor(bordercolors[2]?.trim());
       if (bordercolors.length > 3)
         errorBorderColor = ColorObservable.toColor(bordercolors[3]?.trim());
    }

    var formatter;
    List? formatterTypes = [];
    if (widget.model.format != null) {
      formatterTypes = widget.model.format.split(',');
      formatter = formatterTypes![0].trim();
    }

    // set the text color arrays
    Color? enabledTextColor;
    Color? disabledTextColor;
    Color? hintTextColor;
    Color? errorTextColor;
    List? textColors = [];
    if (widget.model.textcolor != null) {
      textColors = widget.model.textcolor?.split(',');
      enabledTextColor = ColorObservable.toColor(textColors![0]?.trim());
      if (textColors.length > 1)
        disabledTextColor = ColorObservable.toColor(textColors[1]?.trim());
      if (textColors.length > 2)
        hintTextColor = ColorObservable.toColor(textColors[2]?.trim());
      if (textColors.length > 3)
         errorTextColor = ColorObservable.toColor(textColors[3]?.trim());
    }

    // get colors
    Color? enabledColor  = widget.model.color;
    Color? disabledColor = widget.model.color2;
    Color? errorColor    = widget.model.color3;

    double? fontsize = widget.model.size;
    String? hint = widget.model.hint;
    int? length = widget.model.length;
    int? lines = widget.model.lines;


    if(!S.isNullOrEmpty(widget.model.obscure)) obscure = widget.model.obscure;
    if (obscure == true) lines = 1;

    ////////////////
    /* Formatters */
    ////////////////
    List<TextInputFormatter> formatters = [];

    ////////////////////
    /* Capitalization */
    ////////////////////
    if (widget.model.capitalization == CapitalizationTypes.upper)
      formatters.add(UpperCaseTextFormatter());
    if (widget.model.capitalization == CapitalizationTypes.lower)
      formatters.add(LowerCaseTextFormatter());
    if (length != null)
      formatters.add(LengthLimitingTextInputFormatter(length));

    /////////////////
    /* Format type */
    /////////////////
    String? keyboardtype = widget.model.keyboardtype;

    switch (formatter?.toLowerCase()) {
      // not 100% sure what the purpose of the first 3 formatters are.
      case 'numeric':
        formatters.add(TextToNumericFormatter());
        keyboardtype = "numeric";
        overrideErrorText = "Value is not a number";
        break;

      case 'int':
        formatters.add(TextToIntegerFormatter());
        keyboardtype = "numeric";
        overrideErrorText = "Value is not an integer";
        break;

      case 'bool':
        formatters.add(TextToBooleanFormatter());
        overrideErrorText = "Value must be a boolean";
        break;

      case 'credit':
        formatters.add(CreditCardNumberInputFormatter());
        keyboardtype = "numeric";
        overrideErrorText = "Invalid card number";
        validator = isCardValidNumber;
        break;

      case 'cvc':
        formatters.add(CreditCardCvcInputFormatter());
        keyboardtype = "numeric";
        overrideErrorText = "Invalid CVC code";
        break;

      case 'expire':
        formatters.add(CreditCardExpirationDateFormatter());
        keyboardtype = "numeric";
        overrideErrorText = "Invalid expiry date";
        validator = TextInputValidators().isExpiryValid;
        break;

      case 'currency':
        formatters.add(MoneyInputFormatter());
        keyboardtype = "numeric";
        overrideErrorText = "Invalid Currency";
        break;

      case 'phone':
        formatters.add(PhoneInputFormatter());
        // isPhoneValid(widget.model.value);
        keyboardtype = "phone";
        overrideErrorText = "Invalid phone number";
        validator = isPhoneValid;
        break;

      case 'password':
        if(!hasSetObscure) {
          obscure = true;
          hasSetObscure = true;
        }
        keyboardtype = "password";
        overrideErrorText = "The password must be a minumum of 8 characters, including 1 upper and 1 lowercase.";
        validator = TextInputValidators().isPasswordValid;
        break;

      case 'email':
        keyboardtype = "email";
        overrideErrorText = "Invalid email";
        validator = TextInputValidators().isEmailValid;
        break;


      default:
        break;

    }
    if(userSetErrorText) errorText = widget.model.errortext;


    //using allow must not use a mask for filteringtextformatter, causes issues.
    if (widget.model.allow != null && widget.model.mask == null)
      formatters.add(
          FilteringTextInputFormatter.allow(RegExp(r'[' + widget.model.allow! + ']')));
    if (widget.model.deny != null)
      formatters.add(
          FilteringTextInputFormatter.deny(RegExp(r'[' + widget.model.deny! + ']')));


    // The mask formatter with allow
    if (widget.model.mask != null){
      if(widget.model.allow != null) formatters.add( MaskedInputFormatter(
      widget.model.mask,
      allowedCharMatcher: RegExp(r'[' + widget.model.allow! + ']+'),
    ));
      else formatters.add( MaskedInputFormatter(
        widget.model.mask,
      ));
    }


    ///////////////////////
    /* Custom Formatters */
    ///////////////////////
    //if (!S.isNullOrEmpty(model.formatter)) formatters.add(CustomFormatter(model.formatter));

    Widget view = TextField(
        controller: widget.model.controller,
        focusNode: focus,
        autofocus: false,
        autocorrect: false,
        expands: widget.model.expand == true,
        obscureText: obscure!,
        keyboardType: (keyboardtype != null)
            ? (keyboardTypes[keyboardtype.toLowerCase()] ??
                TextInputType.text)
            : TextInputType.text,
        textInputAction: (widget.model.keyboardinput != null)
            ? (keyboardInputs[widget.model.keyboardinput?.toLowerCase()] ??
                TextInputAction.next)
            : TextInputAction.next,
        inputFormatters: formatters,
        enabled:  (widget.model.enabled == false) ? false : true,
        style: TextStyle(
            color: widget.model.enabled != false
                ? enabledTextColor ?? Theme.of(context).colorScheme.onBackground
                : disabledTextColor ?? Theme.of(context).colorScheme.surfaceVariant,
            fontSize: fontsize),
        onChanged: (text) => onValue(text),
        onEditingComplete: _commit,
        onSubmitted: (s)
        {
          if (widget.onSubmitted != null) widget.onSubmitted();
          _handleSubmit(s);
        }

        ,
        textAlignVertical: widget.model.expand == true ? TextAlignVertical.top : TextAlignVertical.center,
        maxLength: length,
        maxLines: widget.model.expand == true ? null : obscure! ? 1 : widget.model.maxlines != null ?  widget.model.maxlines : widget.model.wrap == true ? null : lines != null ? lines : 1,
        minLines: widget.model.expand == true ? null : lines ?? 1,
        maxLengthEnforcement: length != null
            ? MaxLengthEnforcement.enforced
            : MaxLengthEnforcement.none,
        decoration: InputDecoration(
          isDense: (widget.model.dense == true),
          errorMaxLines: 8,
          hintMaxLines: 8,
          fillColor: widget.model.enabled == false
              ? disabledColor ?? Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2)
              : widget.model.error == true
                ? errorColor ?? Colors.transparent
                : enabledColor ?? Colors.transparent,
          filled: true,
          contentPadding: ((widget.model.dense == true)
              ? EdgeInsets.only(
                  left: widget.model.padding,
                  top: widget.model.padding + 10,
                  right: widget.model.padding,
                  bottom: widget.model.padding,
                )
              : EdgeInsets.only(
                  left: widget.model.padding + 10,
                  top: widget.model.padding + 4,
                  right: widget.model.padding,
                  bottom: widget.model.padding + 4,
                )),
          alignLabelWithHint: true,
          labelText: widget.model.dense! ? null : hint,
          labelStyle: TextStyle(
            fontSize: fontsize != null ? fontsize - 2 : 14,
            color: widget.model.enabled != false
                ? hintTextColor ?? Theme.of(context).colorScheme.outline
                : disabledTextColor ?? Theme.of(context).colorScheme.surfaceVariant,
          ),
          counterText: "",
          // widget.model.error is getting set to null somewhere.
          errorText: widget.model.error == true && widget.model.errortext != 'null' && widget.model.errortext != 'none' ? errorText ?? "" : null,
          errorStyle: TextStyle(
            fontSize: fontsize ?? 12,
            fontWeight: FontWeight.w300,
            color: errorTextColor ?? Theme.of(context).colorScheme.error,
          ),
          errorBorder: (widget.model.border == "outline" ||
              widget.model.border == "all")
              ? OutlineInputBorder(
            borderRadius: BorderRadius.all(
                Radius.circular(widget.model.radius ?? 4)),
            borderSide: BorderSide(
                color: errorBorderColor ?? (Theme.of(context).brightness == Brightness.light ? Theme.of(context).colorScheme.error.withOpacity(0.70) : Theme.of(context).colorScheme.onError),
                width: widget.model.borderwidth ?? 1.0),
          )
              : widget.model.border == "none"
              ? InputBorder.none
              : (widget.model.border == "bottom" ||
              widget.model.border == "underline")
              ? UnderlineInputBorder(
            borderRadius: BorderRadius.all(
                Radius.circular(widget.model.radius ?? 0)),
            borderSide: BorderSide(
                color: errorBorderColor ?? Theme.of(context).colorScheme.error,
                width: widget.model.borderwidth ?? 1.0),
          )
              : InputBorder.none,
          focusedErrorBorder: (widget.model.border == "outline" ||
              widget.model.border == "all")
              ? OutlineInputBorder(
            borderRadius: BorderRadius.all(
                Radius.circular(widget.model.radius ?? 4)),
            borderSide: BorderSide(
                color: errorBorderColor ?? (Theme.of(context).brightness == Brightness.light ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.errorContainer),
                width: widget.model.borderwidth ?? 1.0),
          )
              : widget.model.border == "none"
              ? InputBorder.none
              : (widget.model.border == "bottom" ||
              widget.model.border == "underline")
              ? UnderlineInputBorder(
            borderRadius: BorderRadius.all(
                Radius.circular(widget.model.radius ?? 0)),
            borderSide: BorderSide(
                color: errorBorderColor ?? Theme.of(context).colorScheme.error,
                width: widget.model.borderwidth ?? 1.0),
          )
              : InputBorder.none,
          hintText: widget.model.dense! ? hint : null,
          hintStyle: TextStyle(
            fontSize: fontsize ?? 14,
            fontWeight: FontWeight.w300,
            color: widget.model.enabled != false
                ? hintTextColor ?? Theme.of(context).colorScheme.outline
                : disabledTextColor ?? Theme.of(context).colorScheme.surfaceVariant,
          ),
          prefixIcon: (widget.model.icon != null)
              ? Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Icon(widget.model.icon))
              : null,
          prefixIconConstraints: (widget.model.icon != null)
              ? BoxConstraints(maxHeight: 14, minWidth: 30)
              : null,
          suffixIcon: (formatter?.toLowerCase() == "password" && widget.model.clear == false) ?
          IconButton(

            icon: Icon(
              obscure!
                  ? Icons.visibility
                  : Icons.visibility_off,
              size: 17,
              color: hintTextColor ?? Theme.of(context).colorScheme.outline,
            ),
            onPressed: () {
              widget.model.obscure = !obscure!;
            },) : (widget.model.enabled != false &&
                  widget.model.editable != false &&
                  widget.model.clear!)
              ?
          IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(

              Icons.clear_rounded,
              size: 17,
              color: hintTextColor ?? Theme.of(context).colorScheme.outline,
            ),
            onPressed: () {
              onClear();
               },)

              : null,
          suffixIconConstraints: (widget.model.enabled != false &&
                  widget.model.editable != false &&
                  widget.model.clear!)
              ? BoxConstraints(maxHeight: 20)
              : null,
          border: (widget.model.border == "outline" ||
                  widget.model.border == "all")
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                      Radius.circular(widget.model.radius ?? 4)),
                  borderSide: BorderSide(
                      color: enabledBorderColor ?? Theme.of(context).colorScheme.outline,
                      width: widget.model.borderwidth ?? 1.0),
                )
              : widget.model.border == "none"
                  ? InputBorder.none
                  : (widget.model.border == "bottom" ||
                          widget.model.border == "underline")
                      ? UnderlineInputBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(widget.model.radius ?? 0)),
                          borderSide: BorderSide(
                              color: enabledBorderColor ?? Theme.of(context).colorScheme.outline,
                              width: widget.model.borderwidth ?? 1.0),
                        )
                      : InputBorder.none,
          focusedBorder:
              (widget.model.border == "outline" || widget.model.border == "all")
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                          Radius.circular(widget.model.radius ?? 4)),
                      borderSide: BorderSide(
                          color: focusBorderColor ??
                              Theme.of(context).colorScheme.primary,
                          width: widget.model.borderwidth ?? 1.0),
                    )
                  : (widget.model.border == "bottom" ||
                          widget.model.border == "underline")
                      ? UnderlineInputBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(widget.model.radius ?? 0)),
                          borderSide: BorderSide(
                              color: focusBorderColor ?? Theme.of(context).colorScheme.primary,
                              width: widget.model.borderwidth ?? 1.0),
                        )
                      : widget.model.border == "none"
                          ? InputBorder.none
                          : InputBorder.none,
          enabledBorder: (widget.model.border == "outline" ||
                  widget.model.border == "all")
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                      Radius.circular(widget.model.radius ?? 4)),
                  borderSide: BorderSide(
                      color: enabledBorderColor ?? Theme.of(context).colorScheme.outline,
                      width: widget.model.borderwidth ?? 1.0),
                )
              : widget.model.border == "none"
                  ? InputBorder.none
                  : (widget.model.border == "bottom" ||
                          widget.model.border == "underline")
                      ? UnderlineInputBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(widget.model.radius ?? 0)),
                          borderSide: BorderSide(
                              color: enabledBorderColor ?? Theme.of(context).colorScheme.outline,
                              width: widget.model.borderwidth ?? 1.0),
                        )
                      : InputBorder.none,
          disabledBorder:
              (widget.model.border == "outline" || widget.model.border == "all")
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                          Radius.circular(widget.model.radius ?? 4)),
                      borderSide: BorderSide(

                          color: disabledBorderColor ?? Theme.of(context).colorScheme.surfaceVariant,
                          width: widget.model.borderwidth ?? 1.0),
                    )
                  : widget.model.border == "none"
                      ? InputBorder.none
                      : (widget.model.border == "bottom" ||
                              widget.model.border == "underline")
                          ? UnderlineInputBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(widget.model.radius ?? 0)),
                              borderSide: BorderSide(
                                  color: widget.model.editable == false ? enabledBorderColor ?? Theme.of(context).colorScheme.surfaceVariant
                                      : disabledBorderColor ?? Theme.of(context).colorScheme.surfaceVariant,
                                  width: widget.model.borderwidth ?? 1.0),
                            )
                          : InputBorder.none,
        ));

        view = Padding(padding: EdgeInsets.symmetric(vertical: widget.model.dense! ? 0 : 4), child: view);

    ///////////
    /* Width */
    ///////////
    var width = widget.model.expand == true ? double.infinity : widget.model.width ?? 200;

    ////////////////////
    /* Constrain Size */
    ////////////////////
    view = SizedBox(child: view, width: width);

    return view;
  }

  /// After [iFormFields] are drawn we get the global offset for scrollTo functionality
  _afterBuild(BuildContext context)
  {
    // Set the global offset position of each input
    box = context.findRenderObject() as RenderBox?;
    if (box != null) position = box!.localToGlobal(Offset.zero);
    if (position != null) widget.model.offset = position;
  }

  String validate(String text) {
    return 'field must be supplied';
  }

  onFocusChange() async {
    var editable = (widget.model.editable != false);
    if (!editable) return;

    /////////////////////////////////////
    /* Commit Changes on Loss of Focus */
    /////////////////////////////////////
    bool focused = focus.hasFocus;

    if (focused) {
      if (widget.model.touched == false) // set touched to true on focus
        widget.model.touched = true;
      System().commit = _commit;
    }
    else {
      // Makes sure that if a button is clicked the _commit is fired similar to onfocusloss
      System().commit = null;
      await widget.model.onFocusLost(context);
    }

    if (!focused) await _commit();
  }

  Future<bool> _commit({bool passDebounce = true}) async {

      if(widget.model.editable == false) {
        oldValue = widget.model.value;
        return true;
      }

      ////////////////////
      /* Trim the Value */
      ////////////////////
      String? trimmed = (widget.model.controller != null) ? widget.model.controller!.text : null;

      // Flex- I removed the trim here because we want to keep the full state of a user typing
      // we should trim the text later or on the backend service.

      ////////////////////
      /* Value Changed? */
      ////////////////////
      if (widget.model.value != trimmed) {

        ///////////////////////////
        /* Retain Rollback Value */
        ///////////////////////////
        dynamic old = widget.model.value;

        ////////////////
        /* Set Answer */
        ////////////////
        await widget.model.answer(trimmed); // should this be done only on focus change

        // this should only trigger with the oninputchange

        if(!passDebounce) {
          if (debounce?.isActive ?? false) debounce!.cancel();

          // should check for alarms here as well.
          // allow debounce to be altered
          debounce = Timer(Duration(milliseconds: 1000), () async {

            if(S.isNullOrEmpty(widget.model.value) && widget.model.mandatory == true)
            {
              widget.model.error = "true";
              if (!userSetErrorText) errorText = "Field required";
            }

            else  if (validator != null && !S.isNullOrEmpty(widget.model.value))
            {
              widget.model.error = (!validator!(widget.model.value)).toString();
              if (!userSetErrorText) errorText = overrideErrorText;
            }
            else if (S.isNullOrEmpty(widget.model.value))
            {
              widget.model.error = "false";
            }
            widget.model.errortext = errorText;

            //////////////////////////
            /* Fire on Change Event */
            //////////////////////////
            if (trimmed != old) await widget.model.onChange(context);
          });

        }

        // this will always trigger unless the oninputchange is called
        if (passDebounce) {

          if(S.isNullOrEmpty(widget.model.value) && widget.model.mandatory == true)
          {
            widget.model.error = "true";
            if (!userSetErrorText) errorText = "Field required";
          }

          else  if (validator != null && !S.isNullOrEmpty(widget.model.value))
          {
            widget.model.error = (!validator!(widget.model.value)).toString();
            if (!userSetErrorText) errorText = overrideErrorText;
          }
          else if (S.isNullOrEmpty(widget.model.value))
          {
            widget.model.error = "false";
          }
          widget.model.errortext = errorText;

          //////////////////////////
          /* Fire on Change Event */
          //////////////////////////
          if (trimmed != old) await widget.model.onChange(context);
        }
      }
    return true;
  }

  onValue(String text) {
    if(widget.model.editable == false) {
      widget.model.controller!.value = TextEditingValue(text: oldValue ?? "", selection: TextSelection(baseOffset: 0, extentOffset: oldValue!.characters.length));
      return;
    }
    oldValue = text;
      if (widget.onChangeCallback != null)
        widget.onChangeCallback(widget.model, text);
      var editable = (widget.model.editable != false);
      if (!editable) {
        setState(()
        {
          var oldcursorPos = widget.model.controller!.selection.base.offset;
          widget.model.controller!.value = TextEditingValue(text: widget.model.value ?? "", selection: TextSelection.fromPosition(TextPosition(offset: oldcursorPos)));
        });
        return;
      }
    }


  void onClear() {
    if (widget.onChangeCallback != null)
      widget.onChangeCallback(widget.model, '');
    widget.model.controller!.text = '';
    _commit();
  }
}

