// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/observable/binding.dart';
import 'package:fml/widgets/texteditor/text_editor_model.dart';
import 'package:fml/widgets/widget/widget_view_interface.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:fml/widgets/widget/widget_state.dart';


class TextEditorView extends StatefulWidget implements IWidgetView {
  @override
  final TextEditorModel model;
  TextEditorView(this.model) : super(key: ObjectKey(model));

  @override
  State<TextEditorView> createState() => _TextEditorViewState();
}

class _TextEditorViewState extends WidgetState<TextEditorView> {
  QuillController _controller = QuillController.basic();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Callback to fire the [_TextEditorViewState.build] when the [EditorModel] changes
  @override
  onModelChange(WidgetModel model, {String? property, dynamic value}) {
    if (mounted) {
      // value changes as user edits the text
      // we don't want to do a set state after every keystroke
      if (Binding.fromString(property)?.property == 'value' && _controller?.document == widget.model.value) return;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // reload the controller text

    return
      Column(
    children: [
      QuillToolbar.simple(
      configurations: QuillSimpleToolbarConfigurations(
        controller: _controller,
        sharedConfigurations: const QuillSharedConfigurations(
          locale: Locale('en'),
        ),
      ),
    ),
    Expanded(
    child: QuillEditor.basic(
    configurations: QuillEditorConfigurations(
    controller: _controller,
    readOnly: false,
    sharedConfigurations: const QuillSharedConfigurations(
    locale: Locale('de'),
    ),
    ),
    ),
    )
    ]
    );
  }
}
