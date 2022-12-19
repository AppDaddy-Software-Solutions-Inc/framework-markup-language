// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/widgets/radio/radio_model.dart';
import 'package:fml/widgets/option/option_model.dart';
import 'package:fml/helper/helper_barrel.dart';

class RadioView extends StatefulWidget
{
  final RadioModel model;
  RadioView(this.model) : super(key: ObjectKey(model));

  @override
  _RadioViewState createState() => _RadioViewState();
}

class _RadioViewState extends State<RadioView> implements IModelListener {
  List<Widget>? options;
  RenderBox? box;
  Offset? position;

  @override
  void initState()
  {
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
  void didUpdateWidget(RadioView oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (
        (oldWidget.model != widget.model)) {
      oldWidget.model.removeListener(this);
      widget.model.registerListener(this);
    }

  }

  @override
  void dispose() {
    widget.model.removeListener(this);

    super.dispose();
  }

  /// Callback to fire the [_RadioViewState.build] when the [RadioModel] changes
  onModelChange(WidgetModel model, {String? property, dynamic value}) {
    if (this.mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
return LayoutBuilder(builder: builder);
  }

  Widget builder(BuildContext context, BoxConstraints constraints) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _afterBuild(context);
    });

    // Set Build Constraints in the [WidgetModel]
 widget.model.minwidth = constraints.minWidth;
      widget.model.maxwidth = constraints.maxWidth;
      widget.model.minheight = constraints.minHeight;
      widget.model.maxheight = constraints.maxHeight;

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    /////////////
    /* Options */
    /////////////
    if (widget.model.options.isNotEmpty)
    {
      if (options == null) options = [];
      options!.clear();
      for (OptionModel option in widget.model.options) {
        var checked = Icon(Icons.radio_button_checked,
            size: widget.model.size,
            color: widget.model.enabled != false
                ? widget.model.color ?? Theme.of(context).colorScheme.primary
                : widget.model.color!.withOpacity(0.5));
        var unchecked = Icon(Icons.radio_button_unchecked,
            size: widget.model.size,
            color: widget.model.enabled != false
                ? widget.model.color ?? Theme.of(context).colorScheme.surfaceVariant
                : widget.model.color!.withOpacity(0.5));
        var radio = GestureDetector(
            onTap: () => {
                  if (widget.model.enabled != false &&
                      widget.model.editable != false)
                    _onCheck(option)
                },
            child: (widget.model.value == option.value) ? checked : unchecked);

        ///////////
        /* Label */
        ///////////
        Widget label = Text('');
        if (option.label is IViewableWidget) label = option.label!.getView();

        ////////////
        /* Option */
        ////////////
        options!.add(Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(padding: EdgeInsets.only(top: 8, bottom: 8, right: 8, left: 4), child: radio),
              label
            ]));
      }
    }

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
    //Alignment aligned = align['aligned'];

    //////////
    /* View */
    //////////
    Widget view;
    if (widget.model.layout == 'row') {
      if (widget.model.wrap == true)
        view = Wrap(
                children: options!,
                direction: Axis.horizontal,
                alignment: mainWrapAlignment!,
                runAlignment: mainWrapAlignment,
                crossAxisAlignment: crossWrapAlignment!);
      else
        view = Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: crossAlignment!,
                mainAxisAlignment: mainAlignment!,
                children: options!);
    } else {
      if (widget.model.wrap == true)
        view = Wrap(
                children: options!,
                direction: Axis.vertical,
                alignment: mainWrapAlignment!,
                runAlignment: mainWrapAlignment,
                crossAxisAlignment: crossWrapAlignment!);
      else
        view = Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: crossAlignment!,
                mainAxisAlignment: mainAlignment!,
                children: options!);
    }

    //////////////////
    /* Constrained? */
    //////////////////
    // if (widget.model.constrained)
    // {
    //   Map<String,double> constraints = widget.model.constraints;
    //   view = ConstrainedBox(child: view, constraints: BoxConstraints(minHeight: constraints['minheight'], maxHeight: constraints['maxheight'], minWidth: constraints['minwidth'], maxWidth: constraints['maxwidth']));
    // }

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

  void _onCheck(OptionModel option) async
  {
    await widget.model.onCheck(option);
    setState(() {});
  }
}
