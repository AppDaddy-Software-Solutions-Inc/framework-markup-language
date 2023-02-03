// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/widgets/editor/editor_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:highlight/languages/http.dart';
import 'package:highlight/languages/dart.dart';
import 'package:highlight/languages/xml.dart';

class EditorView extends StatefulWidget
{
  final EditorModel model;
  EditorView(this.model) : super(key: ObjectKey(model));

  @override
  _EditorViewState createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> implements IModelListener
{
  CodeController? _controller;

  @override
  void initState()
  {
    super.initState();

    widget.model.registerListener(this);

    // If the model contains any databrokers we fire them before building so we can bind to the data
    widget.model.initialize();
  }

  @override
  void didUpdateWidget(EditorView oldWidget)
  {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.model != widget.model)
    {
      oldWidget.model.removeListener(this);
      widget.model.registerListener(this);
    }
  }

  @override
  void dispose()
  {
    widget.model.removeListener(this);
    if (_controller != null) _controller!.dispose();
    super.dispose();
  }

  /// Callback to fire the [_EditorViewState.build] when the [EditorModel] changes
  onModelChange(WidgetModel model, {String? property, dynamic value})
  {
    if (this.mounted)
    {
      // value changes as user edits the text
      // we don't want to do a set state after every keystroke
      if (Binding.fromString(property)?.property == 'value' && _controller?.fullText == widget.model.value) return;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context)
  {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    var language = xml;
    switch (widget.model.language)
    {
      case "xml" :
        language = xml;
        break;

      case "dart" :
        language = dart;
        break;

      case "http" :
        language = http;
        break;
    }

    // build the controller
    if (_controller == null || _controller?.language != language)
    {
      if (_controller != null) _controller!.dispose();
      _controller = CodeController(text: widget.model.value, language: language);
    }

    // reload the controller text
    if (_controller?.fullText != widget.model.value) _controller!.fullText = widget.model.value ?? "";

    // set the editor text theme
    var theme = CodeThemeData(styles: monokaiSublimeTheme);

    return CodeTheme(data: theme, child: SingleChildScrollView(child: CodeField(controller: _controller!, onChanged: (_) {widget.model.value = _controller?.fullText;}, background: Colors.transparent, maxLines: null)));
    }
  }