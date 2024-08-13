import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_eval/flutter_eval.dart';
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/plugin/plugin_widget_model.dart';
import 'package:fml/widgets/viewable/viewable_view.dart';

class PluginWidgetView extends StatefulWidget implements ViewableWidgetView {

  @override
  final PluginWidgetModel model;

  PluginWidgetView(this.model) : super(key: ObjectKey(model));

  @override
  State<PluginWidgetView> createState() => PluginWidgetViewState();
}

class PluginWidgetViewState extends ViewableWidgetState<PluginWidgetView> {

  Runtime? runtime;

  @override
  void initState() {

    super.initState();

    // load the plugin
    _loadPlugin();
  }

  void _loadPlugin() async {

    try {

      // wait for evc code to load
      await widget.model.initialized.future;

      // load the plugin
      var plugin = widget.model.plugin;
      if (plugin != null) {
        runtime = Runtime(ByteData.sublistView(plugin));
        runtime!.addPlugin(flutterEvalPlugin);
      }
    }

    catch(e, stacktrace) {
      widget.model.error = e;
      widget.model.trace = stacktrace;
    }

    setState(() {});
  }

  Widget _errorBuilder(dynamic exception, StackTrace? stackTrace) {

    var msg = "Oops something went wrong loading plugin method ${widget.model.methodSignature} in ${widget.model.library}";
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
      if (widget.model.error != null) return _errorBuilder(widget.model.error, widget.model.trace);

      // not loaded yet?
      if (runtime == null) return Container();

      // build view
      var view = runtime!.executeLib(widget.model.library, widget.model.method, widget.model.arguments);

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