import 'package:flutter/material.dart';
import 'package:fml/widgets/plugin/plugin_interface.dart';
import 'package:fml/widgets/viewable/viewable_model.dart';
import 'package:fml/widgets/viewable/viewable_view.dart';

class PluginView extends StatefulWidget implements ViewableWidgetView {

  @override
  final ViewableModel model;
  IPlugin get plugin => model as IPlugin;

  PluginView(this.model) : super(key: ObjectKey(model)) {
    assert(model is IPlugin);
  }

  @override
  State<PluginView> createState() => PluginViewState();
}

class PluginViewState extends ViewableWidgetState<PluginView> {

  Widget? plugin;

  @override
  void initState() {

    super.initState();

    // load the plugin
    _loadRuntime();
  }


  void _loadRuntime() async {

    // build the inner plugin
    plugin = widget.plugin.build();

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