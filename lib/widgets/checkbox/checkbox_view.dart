// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/checkbox/checkbox_model.dart' as CHECKBOX;
import 'package:fml/widgets/option/option_model.dart' as OPTION;
import 'package:fml/widgets/viewable/viewable_widget_model.dart';
import 'package:fml/widgets/widget/widget_state.dart';
import 'package:fml/widgets/alignment/alignment.dart';

/// Checkbox View
///
/// Builds the Checkbox View from [Model] properties
class CheckboxView extends StatefulWidget implements IWidgetView
{
  final CHECKBOX.CheckboxModel model;
  CheckboxView(this.model) : super(key: ObjectKey(model));

  @override
  _CheckboxViewState createState() => _CheckboxViewState();
}

class _CheckboxViewState extends WidgetState<CheckboxView>
{
  List<CheckBox> _list = [];

  /// Builder for each checkbox [OPTION.OptionModel]
  _buildOptions() {
    var model = widget.model;
    _list = [];

    if ((model.options.isNotEmpty)) {
      for (OPTION.OptionModel option in model.options) {
        String? value = option.value;
        bool checked = ((model.value != null) && (model.value.contains(value)));
        var o = CheckBox(
            model: model,
            option: option,
            checked: checked,
            onChecked: onChecked,
            context: context);
        _list.add(o);
      }
    }
  }

  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // save system constraints
    onLayout(constraints);

    //this must go after the children are determined
    var alignment = WidgetAlignment(widget.model.layoutType, widget.model.center, widget.model.halign, widget.model.valign);

    _buildOptions();

    Widget view;
    if (widget.model.layout == 'row') {
      if (widget.model.wrap == true)
        view = Center(
            child: Wrap(
                children: _list,
                direction: Axis.horizontal,
                alignment: alignment.mainWrapAlignment,
                runAlignment: alignment.mainWrapAlignment,
                crossAxisAlignment: alignment.crossWrapAlignment));
      else
        view = Center(
            child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: alignment.crossAlignment,
                mainAxisAlignment: alignment.mainAlignment,
                children: _list));
    } else {
      if (widget.model.wrap == true)
        view = Center(
            child: Wrap(
                children: _list,
                direction: Axis.vertical,
                alignment: alignment.mainWrapAlignment,
                runAlignment: alignment.mainWrapAlignment,
                crossAxisAlignment: alignment.crossWrapAlignment));
      else
        view = Center(
            child: Column(
                crossAxisAlignment: alignment.crossAlignment,
                mainAxisAlignment: alignment.mainAlignment,
                children: _list));
    }

    return view;
  }

  /// Function called when clicking a checkbox
  Future<void> onChecked(OPTION.OptionModel option, bool checked) async {
    await widget.model.onCheck(option, checked);
  }
}

class CheckBox extends StatelessWidget {
  final CHECKBOX.CheckboxModel model;
  final OPTION.OptionModel option;

  final bool checked;
  final void Function(OPTION.OptionModel, bool) onChecked;

  final BuildContext context;

  CheckBox(
      {required this.model,
      required this.option,
      required this.checked,
      required this.onChecked,
      required this.context})
      : super(key: UniqueKey());

  /// Callback function called when clicking a [Check]
  void callOnChecked() {
    onChecked(option, checked);
  }

  @override
  Widget build(BuildContext context) {
    var checkbox = Checkbox(
          value: checked,
          onChanged: (value) =>
              model.enabled != false && model.editable != false
                  ? callOnChecked()
                  : null,
          checkColor: Theme.of(context).colorScheme.onPrimary,
          fillColor: MaterialStateColor.resolveWith(
              (states) => Theme.of(context).colorScheme.primary),
          focusColor: Theme.of(context).colorScheme.onInverseSurface,
          hoverColor: model.enabled != false && model.editable != false
              ? Theme.of(context).colorScheme.onInverseSurface
              : Colors.transparent,
          side: BorderSide(
              width: 2,
              color: model.enabled != false && model.editable != false
                  ? Theme.of(context).colorScheme.surfaceVariant
                  : Theme.of(context).colorScheme.onInverseSurface),
          visualDensity: VisualDensity(horizontal: -2, vertical: -4),
          splashRadius: 20,
          mouseCursor: model.enabled != false && model.editable != false
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
        );
    // child: (widget.checked == true ? checkedIcon : uncheckedIcon));

    // Label
    Widget label = Text('');
    if (option.label is ViewableWidgetModel)
    {
      var view = option.label!.getView();
      if (view != null) label = view;
    }

    // View
    var chk = Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                  padding:
                      EdgeInsets.only(top: 8, bottom: 8, right: 8, left: 4),
                  child: checkbox),
              label
            ]);

    return model.editable != false && model.enabled != false ? chk : Opacity(opacity: 0.7, child: chk);
  }
}
