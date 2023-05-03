// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:collection/collection.dart';
import 'package:fml/system.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/viewable/viewable_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/widgets/typeahead/typeahead_model.dart';
import 'package:fml/widgets/text/text_model.dart';
import 'package:fml/widgets/option/option_model.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fml/helper/common_helpers.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class TypeaheadView extends StatefulWidget implements IWidgetView
{
  final TypeaheadModel model;

  TypeaheadView(this.model) : super(key: ObjectKey(model));

  @override
  _TypeaheadViewState createState() => _TypeaheadViewState();
}

class _TypeaheadViewState extends WidgetState<TypeaheadView>
{
  List<DropdownMenuItem<OptionModel>> _list = [];
  late DropdownMenuItem<OptionModel> _input;
  bool _inputInitialized = false;
  OptionModel? _selected;
  final TextEditingController controller = TextEditingController();
  FocusNode focus = FocusNode();
  String typeaheadText = '';

  @override
  void dispose()
  {
    controller.dispose();
    super.dispose();
  }

  _inputSelection(res)
  {
    if (res != null)
    {
      if (widget.model.inputenabled == true)
      {
        // create a new item in dropdown
        TextModel itemLabel = TextModel(null, null, value: res);
        OptionModel newOption = OptionModel(null, null, label: itemLabel, value: res);
        _input = DropdownMenuItem(value: newOption, child: newOption.label!.getView());
        changedDropDownItem(_input.value);
        _inputInitialized = true;
      } else {
        bool hasMatch = false;
        int listCounter = 0;
        try {
          while (hasMatch == false && listCounter < _list.length) {
            if (_list[listCounter]
                .value!
                .value
                .toString()
                .toLowerCase()
                .contains(res.toString().toLowerCase())) {
              hasMatch = true;
              changedDropDownItem(_list[listCounter].value);
            }
            listCounter++;
          }
        } catch(e) {}
        if (hasMatch == false) {
          changedDropDownItem(_list[1].value ?? _list[0].value);
        }
      }
    }
  }

  _buildOptions()
  {
    var model = widget.model;

    _selected = null;
    _list = [];
    if (widget.model.editable != false && widget.model.enabled && _inputInitialized == true) {
      _list.add(_input); // custom select input
      _selected = _input.value;
      controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
    }

    //////////////////////
    /* Add Empty Option */
    //////////////////////
    if (model.options.isNotEmpty)
    {
      for (OptionModel option in model.options)
      {
        Widget view = Text('');
        if (option.label is ViewableWidgetModel) view = option.label!.getView();

        var o = DropdownMenuItem(value: option, child: view);
        if (model.value == option.value) _selected = option;
        _list.add(o);
      }
      if ((_selected == null) && (_list.isNotEmpty)) _selected = _list[0].value;
    }
  }

  Future<List<OptionModel>> getSuggestions(String pattern) async
  {

    Iterable<OptionModel> suggestions = widget.model.options.where((model) => suggestion(model, pattern));
    Iterable<OptionModel> others = widget.model.options.where((model) => !suggestion(model, pattern));
    List<OptionModel> results = suggestions.toList();
    if (others.isNotEmpty) results.addAll(others);
    return results;
  }


  bool suggestion(OptionModel m, String pat) {
    pat = pat.toLowerCase();
    if (m.tags != null && m.tags!.isNotEmpty) {
      List<String?> s = m.tags!.split(',');
      return s.any((tag) => match(tag!.trim().toLowerCase(), pat));
    }
    else {
      String? str = (m.label is TextModel) ? (m.label as TextModel).value : _extractText(m)!;
      return str == null ? false : match(str.trim().toLowerCase(), pat);
    }

  }

  bool match(String tag, String pat) {
    if (tag == '' || tag == 'null')
      return false;
    else if (S.isNullOrEmpty(widget.model.matchtype) || widget.model.matchtype!.toLowerCase() == 'contains') {
      return tag.contains(pat.toLowerCase());
    }
    else if (widget.model.matchtype!.toLowerCase() == 'startswith') {
      return tag.startsWith(pat.toLowerCase());
    }
    else if (widget.model.matchtype!.toLowerCase() == 'endswith') {
      return tag.endsWith(pat.toLowerCase());
    }
    return false;
  }

  String? _extractText(OptionModel? model)
  {
    String value = "";
    Color? modelColor;
    if ((model == null) || (model.label == null)) return value;
    // Try getting the label string
    value = (model.label is TextModel) ? (model.label as TextModel).value ?? '' : '';
    // Try getting the label from TEXT children
    if (S.isNullOrEmpty(value))
    {
      var models = (model.label as WidgetModel).findDescendantsOfExactType(TextModel);
      if (models != null)
        models.forEach((text)
        {
          if (text is TextModel)
          {
            String v = S.toStr(text.value) ?? "";
            if (!value.contains(v)) value += v;
            modelColor = text.color;
          }
        });
    }
    widget.model.textcolor ??= modelColor;
    return value;
  }

  void changedDropDownItem(OptionModel? selected) async {
    if (selected == null) return;
    bool ok = await widget.model.answer(selected.value);
    if (ok == false) selected = _selected;
    await widget.model.onChange(context);
    setState(() {
      _selected = selected;
    });

  }

  onFocusChange() async {

    var editable = (widget.model.editable != false);
    if (!editable) return;

    /////////////////////////////////////
    /* Commit Changes on Loss of Focus */
    /////////////////////////////////////
    bool focused = focus.hasFocus;
    if (focused) {
      controller.selection = TextSelection(baseOffset: 0, extentOffset: controller.text.length);
    }
    try {
      if (focused)
        System().commit = _commit;
      if (!focused) await _commit();
    } catch(e) {}
  }

  Future<bool> _commit() async
  {
    controller.text = controller.text.trim();
    // if the value does not match the option value, clear only when input is disabled.
    if (!widget.model.inputenabled) controller.text = _extractText(_selected)!;

    return true;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // build options
    _buildOptions();

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // save system constraints
    onLayout(constraints);

    // set text style
    TextStyle ts = TextStyle(fontSize: 14,
        color: widget.model.color != null
            ? (widget.model.color?.computeLuminance() ?? 1) < 0.4
            ? Colors.white.withOpacity(0.5)
            : Colors.black.withOpacity(0.5)
            : Theme.of(context).colorScheme.onSurfaceVariant
    );

    // set color
    bool enabled = (widget.model.enabled != false) && (widget.model.busy != true);
    Color selcol = enabled
        ? (widget.model.color ?? Colors.transparent)
        : ((widget.model.color)
        ?.withOpacity(0.95)
        .withRed((widget.model.color!.red*0.95).toInt())
        .withGreen((widget.model.color!.green*0.95).toInt())
        .withBlue((widget.model.color!.blue*0.95).toInt())
        ?? Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2));

    // view
    Widget view;

    controller.text = _extractText(_selected)!;

    //Set the selection to the front of the text when entering for typeahead.
    controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));

    List<OptionModel>? suggestions;
    view = SizedBox(
        width: widget.model.calculatedMaxWidthOrDefault,
        child: TypeAheadField(
          textFieldConfiguration: TextFieldConfiguration(
              enabled: widget.model.enabled != false,
              focusNode: focus,
              controller: controller,
              textAlignVertical: TextAlignVertical.center,
              onSubmitted: _inputSelection,
              onChanged: widget.model.inputenabled ? _inputSelection : null,
              style: TextStyle(
                  color: widget.model.enabled != false ? widget.model.textcolor ?? Theme
                      .of(context)
                      .colorScheme
                      .onBackground : Theme.of(context).colorScheme.surfaceVariant,
                  fontSize: widget.model.size ?? 14),
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(bottom:2),
                  isDense: true,

                  hintText: widget.model.hint ?? '',
                  hintStyle: ts,
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  suffixIcon: Icon(Icons.arrow_drop_down, size: 25,))),
          suggestionsCallback: (pattern) async {
            suggestions = await getSuggestions(pattern);
            return suggestions!;
          },
          itemBuilder: (context, dynamic suggestion) {
            Widget? item;
            if (suggestion is OptionModel) {
              var option = _list.firstWhereOrNull(
                      (option) => (option.value == suggestion));
              item = option?.child;
            }
            item ??= Container(height: 12);
            return Padding(
                padding: EdgeInsets.only(
                    left: 12, right: 1, top: 12, bottom: 12),
                child: item);
          },
          autoFlipDirection: true,
          suggestionsBoxDecoration:
          SuggestionsBoxDecoration(
            elevation: 20,
          ),
          suggestionsBoxVerticalOffset: 0,
          onSuggestionSelected: (dynamic suggestion) {
            if (suggestion is OptionModel)
              changedDropDownItem(suggestion);
          },
          transitionBuilder: (context, suggestionsBox, animationController) =>
              FadeTransition(
                child: suggestionsBox,
                opacity: CurvedAnimation(
                    parent: animationController!, curve: Curves.fastOutSlowIn),
              ),
        )
    );
    focus.addListener(onFocusChange);
    if (widget.model.border == 'all') {
      view = Container(
        padding: const EdgeInsets.fromLTRB(15, 0, 5, 0),
        decoration: BoxDecoration(
          color: selcol,
          border: Border.all(
              width: widget.model.borderwidth?.toDouble() ?? 1,
              color: widget.model.enabled
                  ? (widget.model.bordercolor ?? Theme.of(context).colorScheme.outline)
                  : Theme.of(context).colorScheme.surfaceVariant),
          borderRadius: BorderRadius.circular(widget.model.radius?.toDouble() ?? 4),
        ),
        child: view,
      );
    }

    // display busy
    //var busy;
    //if (busy != null) view = Stack(children: [view, Positioned(top: 0, bottom: 0, left: 0, right: 0, child: busy)]);

    // get the model constraints
    var modelConstraints = widget.model.constraints.model;

    // constrain the input to 200 pixels if not constrained by the model
    if (!modelConstraints.hasHorizontalExpansionConstraints) modelConstraints.width  = 200;
    if (!modelConstraints.hasVerticalExpansionConstraints)   modelConstraints.height = 48;

    // add margins
    view = addMargins(view);

    // apply constraints
    view = applyConstraints(view, modelConstraints);

    return view;
  }
}
