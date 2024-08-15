import 'package:flutter/material.dart';
import 'package:fml/widgets/field/field_model.dart';
import 'package:fml/widgets/viewable/viewable_view.dart';

class FieldView extends StatefulWidget implements ViewableWidgetView {

  @override
  final FieldModel model;

  FieldView(this.model) : super(key: ObjectKey(model));

  @override
  State<FieldView> createState() => PluginState();
}

class PluginState extends ViewableWidgetState<FieldView> {

  Widget? plugin;

  @override
  void initState() {

    super.initState();

    // load the plugin
    _loadRuntime();
  }

  void _loadRuntime() async {

    // wait for evc code to load
    plugin = await widget.model.plugin();

    // rebuild the widget
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    // visible?
    if (!widget.model.visible) return const Offstage();

    var view = plugin;

    // not loaded yet?
    if (view == null) return Container();

    // no need to continue
    if (view is Offstage) return view;

    // add margins
    view = addMargins(view);

    // apply visual transforms
    view = applyTransforms(view);

    // apply user defined constraints
    view = applyConstraints(view, widget.model.constraints);

    // return the view
    return view;
  }
}