// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:collection/collection.dart';
import 'package:fml/log/manager.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/iwidget_view.dart';
import 'package:fml/widgets/viewable/viewable_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/widgets/typeahead/typeahead_model.dart';
import 'package:fml/widgets/text/text_model.dart';
import 'package:fml/widgets/option/option_model.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fml/helpers/helpers.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class TypeaheadView extends StatefulWidget implements IWidgetView
{
  @override
  final TypeaheadModel model;

  TypeaheadView(this.model) : super(key: ObjectKey(model));

  @override
  State<TypeaheadView> createState() => _TypeaheadViewState();
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
  Timer? _debounce;

  @override
  void dispose()
  {
    controller.dispose();
    _debounce?.cancel();
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

        var child = newOption.label!.getView() ?? Container();
        _input = DropdownMenuItem(value: newOption, child: child);

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
        } catch(e) {
          Log().debug('$e');
        }
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
        if (option.label is ViewableWidgetModel)
        {
          var myView = option.label!.getView();
          if (myView != null) view = myView;
        }

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
    if (tag == '' || tag == 'null') {
      return false;
    } else if (isNullOrEmpty(widget.model.matchtype) || widget.model.matchtype!.toLowerCase() == 'contains') {
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
    if (isNullOrEmpty(value))
    {
      var models = (model.label as WidgetModel).findDescendantsOfExactType(TextModel);
      for (var text in models) {
        if (text is TextModel)
        {
          String v = toStr(text.value) ?? "";
          if (!value.contains(v)) value += v;
          modelColor = text.color;
        }
      }
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

    // select all
    if (focus.hasFocus) controller.selection = TextSelection(baseOffset: 0, extentOffset: controller.text.length);

    // commit changes on loss of focus
    if (!focus.hasFocus) await _commit();
  }

  Future<bool> _commit() async
  {
    controller.text = controller.text.trim();

    // if the value does not match the option value, clear only when input is disabled.
    if (!widget.model.inputenabled) controller.text = _extractText(_selected)!;

    return true;
  }

  //debounce for inputenabled so it does not autocommit onchange.
  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _inputSelection(query);
    });
  }

  @override
  Widget build(BuildContext context)
  {
    // build options
    _buildOptions();

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // set text style
    TextStyle ts = TextStyle(fontSize: 14,
        color: widget.model.color != null
            ? (widget.model.color?.computeLuminance() ?? 1) < 0.4
            ? Colors.white.withOpacity(0.5)
            : Colors.black.withOpacity(0.5)
            : Theme.of(context).colorScheme.onSurfaceVariant
    );

    // view
    Widget view;

    controller.text = _extractText(_selected)!;

    //Set the selection to the front of the text when entering for typeahead.
    controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));

    List<OptionModel>? suggestions;
    view = SizedBox(
        width: widget.model.myMaxWidthOrDefault,
        child: TypeAheadField(
          textFieldConfiguration: TextFieldConfiguration(
              enabled: widget.model.enabled != false,
              focusNode: focus,
              controller: controller,
              textAlignVertical: TextAlignVertical.center,
              onSubmitted: _inputSelection,
              onChanged: widget.model.inputenabled ? _onSearchChanged : null,
              style: TextStyle(
                  color: widget.model.enabled != false ? widget.model.textcolor ?? Theme
                      .of(context)
                      .colorScheme
                      .onBackground : Theme.of(context).colorScheme.surfaceVariant,
                  fontSize: widget.model.size),
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
            if (suggestion is OptionModel) {
              changedDropDownItem(suggestion);
            }
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
    if (widget.model.border == 'none') {
      view = Container(
        padding: const EdgeInsets.fromLTRB(12, 6, 0, 6),
        decoration: BoxDecoration(
          color: widget.model.getFieldColor(context),
          borderRadius: BorderRadius.circular(widget.model.radius.toDouble()),
        ),
        child: view,
      );
    } else if (widget.model.border == 'bottom' || widget.model.border == 'underline') {
      view = Container(
        padding: const EdgeInsets.fromLTRB(12, 5, 0, 6),
        decoration: BoxDecoration(
          color: widget.model.getFieldColor(context),
          border: Border(
            bottom: BorderSide(
                width: widget.model.borderwidth.toDouble(),
                color: widget.model.setErrorBorderColor(context, widget.model.bordercolor)),
          ),),
        child: view,
      );
    } else {
      view = Container(
        padding: const EdgeInsets.fromLTRB(12, 5, 0, 4),
        decoration: BoxDecoration(
          color: widget.model.getFieldColor(context),
          border: Border.all(
              width: widget.model.borderwidth.toDouble(),
              color: widget.model.setErrorBorderColor(context, widget.model.bordercolor)),
          borderRadius: BorderRadius.circular(widget.model.radius.toDouble()),
        ),
        child: view,
      );
    }

    if(!isNullOrEmpty(widget.model.alarmText))
    {
      Widget? errorText = Padding(padding: EdgeInsets.only(top: 6.0 , bottom: 2.0),
        child: Text("${widget.model.alarmText}", style: TextStyle(color: Theme.of(context).colorScheme.error),),);

      view = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [view, errorText],
      );
    }

    // get the model constraints
    var modelConstraints = widget.model.constraints;

    // constrain the input to 200 pixels if not constrained by the model
    if (!modelConstraints.hasHorizontalExpansionConstraints) modelConstraints.width  = 200;

    // add margins
    view = addMargins(view);

    // apply constraints
    view = applyConstraints(view, modelConstraints);

    return view;
  }


}
