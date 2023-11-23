// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fml/widgets/busy/busy_model.dart';
import 'package:fml/widgets/widget/widget_view_interface.dart';
import 'package:fml/widgets/viewable/viewable_widget_model.dart';
import 'package:fml/widgets/select/select_model.dart';
import 'package:fml/widgets/option/option_model.dart';
import 'package:fml/helpers/helpers.dart';
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

    // add options
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

      if (_selected == null && _list.isNotEmpty)
      {
        _selected = _list[0].value;
      }
    }
  }

  @override
  Widget build(BuildContext context)
  {
    // build options
    _buildOptions();

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // busy?
    Widget? busy;
    if (widget.model.busy == true)
    {
      busy = BusyModel(widget.model,
          visible: true,
          size: 24,
          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
          modal: false).getView();
    }

    bool enabled = (widget.model.enabled != false) && (widget.model.busy != true);

    TextStyle ts = TextStyle(fontSize: widget.model.size,
        color: widget.model.color != null
            ? (widget.model.color?.computeLuminance() ?? 1) < 0.4
              ? Colors.white.withOpacity(0.5)
              : Colors.black.withOpacity(0.5)
            : Theme.of(context).colorScheme.onSurfaceVariant
    );

    // view
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
              underline: Container(),
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

    if (widget.model.border == 'none')
    {
      view = Container(
        padding: const EdgeInsets.fromLTRB(12, 2, 8, 2),
        decoration: BoxDecoration(
          color: widget.model.getFieldColor(context),
          borderRadius: BorderRadius.circular(widget.model.radius.toDouble()),
        ),
        child: view,
      );
    }
    else if (widget.model.border == 'bottom' || widget.model.border == 'underline')
    {
      view = Container(
        padding: const EdgeInsets.fromLTRB(12, 0, 8, 3),
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
        padding: const EdgeInsets.fromLTRB(12, 1, 9, 0),
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

    // display busy
    if (busy != null) view = Stack(children: [view, Positioned(top: 0, bottom: 0, left: 0, right: 0, child: busy)]);

    if(!isNullOrEmpty(widget.model.alarmText))
    {
      Widget? errorText = Padding(padding: EdgeInsets.only(top: 6.0 , bottom: 2.0), child: Text("${widget.model.alarmText}", style: TextStyle(color: Theme.of(context).colorScheme.error)));
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
    if (!modelConstraints.hasHorizontalExpansionConstraints) modelConstraints.width = 200;

    // add margins
    view = addMargins(view);

    // apply constraints
    view = applyConstraints(view, modelConstraints);

    return view;
  }

  void changedDropDownItem(OptionModel? selected) async
  {
    // added this in to remove focus from input
    FocusScope.of(context).requestFocus(FocusNode()); // added this in to remove focus from input

    // removed this as it prevents reloading after a user submits a value
    if (selected == null) return;

    // set the answer
    bool ok = await widget.model.answer(selected.value);
    if (ok == false) selected = _selected;

    // fire onchange
    await widget.model.onChange(context);
    setState(()
    {
      _selected = selected;
    });
  }

  onFocusChange() async
  {
    var editable = (widget.model.editable != false);
    if (!editable) return;

    // commit changes on loss of focus
    if (!focus.hasFocus) await _commit();
  }

  Future<bool> _commit() async => true;
}
