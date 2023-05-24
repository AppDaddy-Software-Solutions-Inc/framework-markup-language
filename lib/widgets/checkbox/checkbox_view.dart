// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/helper/string.dart';
import 'package:fml/widgets/widget/iwidget_view.dart';
import 'package:fml/widgets/checkbox/checkbox_model.dart';
import 'package:fml/widgets/option/option_model.dart';
import 'package:fml/widgets/viewable/viewable_widget_model.dart';
import 'package:fml/widgets/widget/widget_state.dart';
import 'package:fml/widgets/alignment/alignment.dart';

/// Checkbox View
///
/// Builds the Checkbox View from [Model] properties
class CheckboxView extends StatefulWidget implements IWidgetView
{
  @override
  final CheckboxModel model;
  CheckboxView(this.model) : super(key: ObjectKey(model));

  @override
  State<CheckboxView> createState() => _CheckboxViewState();
}

class _CheckboxViewState extends WidgetState<CheckboxView>
{
  List<CheckBox> _list = [];

  /// Builder for each checkbox [OPTION.OptionModel]
  _buildOptions() {
    var model = widget.model;
    _list = [];

    if ((model.options.isNotEmpty)) {
      for (OptionModel option in model.options) {
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

  @override
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
      if (widget.model.wrap == true) {
        view = Wrap(
                children: _list,
                direction: Axis.horizontal,
                alignment: WrapAlignment.start,
                runAlignment: alignment.mainWrapAlignment,
                crossAxisAlignment: alignment.crossWrapAlignment);
      } else {
        view = Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: alignment.crossAlignment,
                mainAxisAlignment: MainAxisAlignment.start,
                children: _list);
      }
    } else {
      if (widget.model.wrap == true) {
        view = Wrap(
                children: _list,
                direction: Axis.vertical,
                alignment: WrapAlignment.start,
                runAlignment: alignment.mainWrapAlignment,
                crossAxisAlignment: alignment.crossWrapAlignment);
      } else {
        view = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: alignment.mainAlignment,
                children: _list);
      }
    }

    String? errorTextValue = widget.model.returnErrorText();

    if(!S.isNullOrEmpty(errorTextValue)) {
      Widget? errorText = Text(
        "     $errorTextValue", style: TextStyle(color: Theme
          .of(context)
          .colorScheme
          .error),);

      view = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [view, errorText],
      );
    }

    view = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [view],
    );

    // get the model constraints
    var modelConstraints = widget.model.constraints;

    // constrain the input to 200 pixels if not constrained by the model
    //if (!modelConstraints.hasHorizontalExpansionConstraints) modelConstraints.width  = 200;

    // add margins
    view = addMargins(view);

    // apply constraints
    view = applyConstraints(view, modelConstraints);



    return view;
  }

  /// Function called when clicking a checkbox
  Future<void> onChecked(OptionModel option, bool checked) async {
    await widget.model.onCheck(option, checked);
  }
}

class CheckBox extends StatelessWidget {
  final CheckboxModel model;
  final OptionModel option;

  final bool checked;
  final void Function(OptionModel, bool) onChecked;

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
              color: model.setErrorBorderColor(context, model.color)),
          visualDensity: VisualDensity(horizontal: -2, vertical: -4),
          splashRadius: 18,
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

      label  = MouseRegion(
          cursor:
          model.enabled != false && model.editable != false
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: GestureDetector(
              onTap: () => {
                model.enabled != false &&
                    model.editable != false
                    ? callOnChecked()
                    : () => {}
              },
              child: label));
    }

    // View
    var chk = Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                  padding:
                      EdgeInsets.only(top: 8, bottom: 8, right: 4, left: 0),
                  child: checkbox),
              label
            ]);




    return model.editable != false && model.enabled != false ? chk : Opacity(opacity: 0.7, child: chk);






  }
}
