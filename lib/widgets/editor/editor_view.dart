// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/widgets/editor/editor_model.dart';
import 'package:fml/widgets/viewable/viewable_view.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/theme_map.dart';
import 'package:highlight/languages/http.dart';
import 'package:highlight/languages/dart.dart';
import 'package:highlight/languages/xml.dart';

class EditorView extends StatefulWidget implements ViewableWidgetView {
  @override
  final EditorModel model;
  EditorView(this.model) : super(key: ObjectKey(model));

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends ViewableWidgetState<EditorView> {
  CodeController? _controller;

  @override
  void dispose() {
    if (_controller != null) _controller!.dispose();
    super.dispose();
  }

  /// Callback to fire the [_EditorViewState.build] when the [EditorModel] changes
  @override
  onModelChange(Model model, {String? property, dynamic value}) {
    if (mounted) {
      // value changes as user edits the text
      // we don't want to do a set state after every keystroke
      if (Binding.fromString(property)?.property == 'value' &&
          _controller?.fullText == widget.model.value) return;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return const Offstage();

    var language = xml;
    switch (widget.model.language) {
      case "xml":
        language = xml;
        break;

      case "dart":
        language = dart;
        break;

      case "http":
        language = http;
        break;
    }

    // build the controller
    if (_controller == null || _controller?.language != language) {
      if (_controller != null) _controller!.dispose();
      _controller =
          CodeController(text: widget.model.value, language: language);
      _controller!.readOnlySectionNames = {'readonly'};
    }

    // reload the controller text
    if (_controller?.fullText != widget.model.value) {
      _controller!.fullText = widget.model.value ?? "";
    }

    // set the editor text theme
    var theme = CodeThemeData(
        styles: themeMap.containsKey(widget.model.theme)
            ? themeMap[widget.model.theme]
            : themeMap.values.first);
    return CodeTheme(
        data: theme,
        child: CodeField(
          controller: _controller!,
          onChanged: (_) {
            widget.model.value = _controller?.fullText;
          },
          background: Colors.transparent,
          maxLines: null,
          textStyle: const TextStyle(fontSize: 14),
          gutterStyle: const GutterStyle(width: 80, margin: 0),
        ));
  }
}
