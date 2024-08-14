import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/plugin/plugin_mixin.dart';
import 'package:fml/widgets/viewable/viewable_model.dart';
import 'package:fml/widgets/viewable/viewable_view.dart';

class PluginView extends StatefulWidget implements ViewableWidgetView {

  @override
  final ViewableModel model;

  PluginMixin get mixin => model as PluginMixin;

  PluginView(this.model) : super(key: ObjectKey(model)) {
    assert(model is PluginMixin);
  }

  @override
  State<PluginView> createState() => PluginState();
}

class PluginState extends ViewableWidgetState<PluginView> {

  Runtime? runtime;

  @override
  void initState() {

    super.initState();

    // load the plugin
    _loadRuntime();
  }

  void _loadRuntime() async {

    // wait for evc code to load
    await widget.mixin.initialized?.future;

    // set the runtime
    runtime = widget.mixin.runtime;

    // rebuild the widget
    setState(() {});
  }

  Widget _errorBuilder(dynamic exception, StackTrace? stackTrace) {

    var msg = "Oops something went wrong loading plugin ${widget.model.element}";
    msg = "$msg \n\n $exception \n\n $stackTrace";
    var view = Tooltip(message: msg, child: const Icon(Icons.error_outline, color: Colors.red, size: 24));
    return view;
  }

  @override
  Widget build(BuildContext context) {
    try
    {
      // visible?
      if (!widget.model.visible) return const Offstage();

      // error during setup?
      if (widget.mixin.error != null) return _errorBuilder(widget.mixin.error, widget.mixin.trace);

      // not loaded yet?
      if (runtime == null) return Container();

      // build view
      var view = runtime!.executeLib(widget.mixin.library, widget.mixin.method, widget.mixin.arguments);

      // add margins
      view = addMargins(view);

      // apply visual transforms
      view = applyTransforms(view);

      // apply user defined constraints
      view = applyConstraints(view, widget.model.constraints);

      // return the view
      return view;
    }
    catch(e, trace)
    {
      return _errorBuilder(e, trace);
    }
  }
}