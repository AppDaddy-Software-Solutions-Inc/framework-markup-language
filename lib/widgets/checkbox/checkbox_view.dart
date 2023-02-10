// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';

import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/widgets/checkbox/checkbox_model.dart' as CHECKBOX;
import 'package:fml/widgets/option/option_model.dart' as OPTION;
import 'package:fml/helper/common_helpers.dart';

/// Checkbox View
///
/// Builds the Checkbox View from [Model] properties
class CheckboxView extends StatefulWidget {
  final CHECKBOX.CheckboxModel model;
  CheckboxView(this.model) : super(key: ObjectKey(model));

  @override
  _CheckboxViewState createState() => _CheckboxViewState();
}

class _CheckboxViewState extends State<CheckboxView> implements IModelListener {
  List<CheckBox> _list = [];
  RenderBox? box;
  Offset? position;

  @override
  void initState() {
    super.initState();

    widget.model.registerListener(this);

    // If the model contains any databrokers we fire them before building so we can bind to the data
    widget.model.initialize();
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(CheckboxView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.model != widget.model)) {
      oldWidget.model.removeListener(this);
      widget.model.registerListener(this);
    }
  }

  @override
  void dispose() {
    widget.model.removeListener(this);

    super.dispose();
    widget.model.removeListener(this);
  }

  /// Callback to fire the [_CheckboxViewState.build] when the [CheckboxModel] changes
  onModelChange(WidgetModel model, {String? property, dynamic value}) {
    if (this.mounted) setState(() {});
  }

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

  Widget build(BuildContext context) {
    return LayoutBuilder(builder: builder);
  }

  Widget builder(BuildContext context, BoxConstraints constraints) {
    // Set Build Constraints in the [WidgetModel]
    widget.model.minWidth = constraints.minWidth;
    widget.model.maxWidth = constraints.maxWidth;
    widget.model.minHeight = constraints.minHeight;
    widget.model.maxHeight = constraints.maxHeight;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _afterBuild(context);
    });

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    //this must go after the children are determined
    Map<String, dynamic> align = AlignmentHelper.alignWidgetAxis(
        2,
        widget.model.layout,
        widget.model.center,
        widget.model.halign,
        widget.model.valign);
    CrossAxisAlignment? crossAlignment = align['crossAlignment'];
    MainAxisAlignment? mainAlignment = align['mainAlignment'];
    WrapAlignment? mainWrapAlignment = align['mainWrapAlignment'];
    WrapCrossAlignment? crossWrapAlignment = align['crossWrapAlignment'];

    _buildOptions();

    Widget view;
    if (widget.model.layout == 'row') {
      if (widget.model.wrap == true)
        view = Center(
            child: Wrap(
                children: _list,
                direction: Axis.horizontal,
                alignment: mainWrapAlignment!,
                runAlignment: mainWrapAlignment,
                crossAxisAlignment: crossWrapAlignment!));
      else
        view = Center(
            child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: crossAlignment!,
                mainAxisAlignment: mainAlignment!,
                children: _list));
    } else {
      if (widget.model.wrap == true)
        view = Center(
            child: Wrap(
                children: _list,
                direction: Axis.vertical,
                alignment: mainWrapAlignment!,
                runAlignment: mainWrapAlignment,
                crossAxisAlignment: crossWrapAlignment!));
      else
        view = Center(
            child: Column(
                crossAxisAlignment: crossAlignment!,
                mainAxisAlignment: mainAlignment!,
                children: _list));
    }

    return view;
  }

  /// After [iFormFields] are drawn we get the global offset for scrollTo functionality
  _afterBuild(BuildContext context) {
    // Set the global offset position of each input
    box = context.findRenderObject() as RenderBox?;
    if (box != null) position = box!.localToGlobal(Offset.zero);
    if (position != null) widget.model.offset = position;
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

    ///////////
    /* Label */
    ///////////
    Widget label = Text('');
    if (option.label is IViewableWidget) label = option.label!.getView();

    //////////
    /* View */
    //////////
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
