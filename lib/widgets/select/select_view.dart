// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/log/manager.dart';
import 'package:fml/system.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/busy/busy_model.dart';
import 'package:fml/widgets/busy/busy_view.dart';
import 'package:fml/widgets/widget/iwidget_view.dart';
import 'package:fml/widgets/viewable/viewable_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/widgets/select/select_model.dart';
import 'package:fml/widgets/text/text_model.dart';
import 'package:fml/widgets/option/option_model.dart';
import 'package:fml/helper/common_helpers.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class SelectView extends StatefulWidget implements IWidgetView
{
  @override
  final SelectModel model;

  SelectView(this.model) : super(key: ObjectKey(model));

  @override
  State<SelectView> createState() => _SelectViewState();
}

class _SelectViewState extends WidgetState<SelectView>
{
  List<DropdownMenuItem<OptionModel>> _list = [];
  OptionModel? _selected;
  FocusNode focus = FocusNode();


  _buildOptions()
  {
    var model = widget.model;

      _selected = null;
      _list = [];

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
      if ((_selected == null) && (_list.isNotEmpty)) {
        _selected = _list[0].value;
        widget.model.hasDefaulted = true;
      }
    }
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

    // busy?
    BusyView? busy;
    if (widget.model.busy == true) {
      busy = BusyView(BusyModel(widget.model,
          visible: true,
          size: 24,
          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
          modal: false));
    }

    bool enabled = (widget.model.enabled != false) && (widget.model.busy != true);

    TextStyle ts = TextStyle(fontSize: widget.model.size,
        color: widget.model.color != null
            ? (widget.model.color?.computeLuminance() ?? 1) < 0.4
              ? Colors.white.withOpacity(0.5)
              : Colors.black.withOpacity(0.5)
            : Theme.of(context).colorScheme.onSurfaceVariant
    );

    Color selcol = widget.model.setFieldColor(context);

    //////////
    /* View */
    //////////
    Widget view;

      OptionModel? dValue = (_selected != null && _selected?.value != null && _selected?.value == '') ? null : _selected;

      Widget child = Text('');
      if (_selected != null && _selected!.label != null)
      {
        var myView = _selected!.label!.getView();
        if (myView != null) child = myView;
      }

      view = widget.model.editable != false
          ? MouseRegion(
              cursor: SystemMouseCursors.click,
              child: DropdownButton<OptionModel>(
                itemHeight: 48,
                value: dValue,
                // value must be null for the hint to show
                hint: Text(
                  widget.model.hint ?? '',
                  style: ts,
                ),
                items: _list, // if this is set to null it disables the dropdown but also hides any value
                onChanged: enabled ? changedDropDownItem : null, // set this to null to disable dropdown
                dropdownColor: Theme.of(context).colorScheme.onInverseSurface,
                isExpanded: true,
                borderRadius: BorderRadius.circular(widget.model.radius.toDouble() <= 24
                            ? widget.model.radius.toDouble()
                            : 24),
                underline: widget.model.border == 'underline'
                    ? Container(height: 2, color: selcol)
                    : Container(),
                disabledHint: widget.model.hint == null
                    ? Container(height: 10,)
                    : Text(
                        widget.model.hint ?? '',
                        style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withOpacity(0.50)),
                      ),
                focusColor: Theme.of(context)
                    .colorScheme
                    .surfaceVariant
                    .withOpacity(0.15),
              ))
          : child;
    if (widget.model.border == 'all') {
      view = Container(
        padding: const EdgeInsets.fromLTRB(12, 0, 8, 0),
        decoration: BoxDecoration(
          color: selcol,
          border: Border.all(
              width: widget.model.borderwidth.toDouble(),
              color: widget.model.enabled
                  ? (widget.model.bordercolor ?? Theme.of(context).colorScheme.outline)
                  : Theme.of(context).colorScheme.surfaceVariant),
          borderRadius: BorderRadius.circular(widget.model.radius.toDouble()),
        ),
        child: view,
      );
    }

    // display busy
    if (busy != null) view = Stack(children: [view, Positioned(top: 0, bottom: 0, left: 0, right: 0, child: busy)]);

    String? errorTextValue = widget.model.returnErrorText();

    if(!S.isNullOrEmpty(errorTextValue)) {
      Text? errorText = Text(errorTextValue, style: TextStyle(color: Theme.of(context)
          .colorScheme.error),);

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
    } else if (S.isNullOrEmpty(widget.model.matchtype) || widget.model.matchtype!.toLowerCase() == 'contains') {
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

  static String? _extractText(OptionModel? model)
  {
    String value = "";
    if ((model == null) || (model.label == null)) return value;
    // Try getting the label string
    value = (model.label is TextModel) ? (model.label as TextModel).value ?? '' : '';
    // Try getting the label from TEXT children
    if (S.isNullOrEmpty(value))
    {
      var models = (model.label as WidgetModel).findDescendantsOfExactType(TextModel);
      if (models != null) {
        for (var text in models) {
          if (text is TextModel)
          {
            String v = S.toStr(text.value) ?? "";
            if (!value.contains(v)) value += v;
          }
        }
      }
    }
    return value;
  }

  void changedDropDownItem(OptionModel? selected) async {

      FocusScope.of(context).requestFocus(
          FocusNode()); // added this in to remove focus from input

    // removed this as it prevents reloading after a user submits a value
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
    try {
      if (focused) {
        System().commit = _commit;
      } else {
        System().commit = null;
      }

      if (!focused) await _commit();
    } catch(e) {
      Log().debug('$e');
    }
  }

  Future<bool> _commit() async
  {
  return true;
  }
}
