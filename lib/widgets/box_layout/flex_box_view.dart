// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fml/widgets/alignment/alignment.dart';
import 'package:fml/widgets/box_layout/box_layout.dart';
import 'package:fml/widgets/box_layout/flex_box.dart';
import 'package:fml/widgets/column/column_model.dart';
import 'package:fml/widgets/widget/iwidget_view.dart';
import 'package:fml/widgets/widget/widget_state.dart';
import 'package:fml/widgets/layout/layout_model.dart';

class BoxLayoutView extends StatefulWidget implements IWidgetView
{
  @override
  final LayoutModel model;

  BoxLayoutView(this.model) : super(key: ObjectKey(model));

  @override
  State<BoxLayoutView> createState() => _BoxLayoutViewState();
}

class _BoxLayoutViewState extends WidgetState<BoxLayoutView>
{
  @override
  void initState()
  {
    super.initState();

    // remove listener to the model if the model
    // is not a column model. The BoxModel will share the same model
    // and rebuild this view on model change
    if (widget.model is! ColumnModel) widget.model.removeListener(this);
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    var children = widget.model.inflate();

    // this must go after the children are determined
    var alignment = WidgetAlignment(widget.model.layoutType, widget.model.center, widget.model.halign, widget.model.valign);

    return FlexBox(model: widget.model,
      direction: widget.model.layoutType == LayoutType.row ? Axis.horizontal : Axis.vertical,
      mainAxisAlignment: alignment.mainAlignment,
      crossAxisAlignment: alignment.crossAlignment,
      clipBehavior: Clip.hardEdge,
      children: children,);

    // required this.direction,
    // required this.model,
    // this.mainAxisAlignment = MainAxisAlignment.start,
    // this.mainAxisSize = MainAxisSize.max,
    // this.crossAxisAlignment = CrossAxisAlignment.center,
    // this.textDirection,
    // this.verticalDirection = VerticalDirection.down,
    // this.textBaseline, // NO DEFAULT: we don't know what the text's baseline should be
    // this.clipBehavior = Clip.none,
    // super.children,

    Container();

    var child = BoxLayout(
      child: _buildImage(),
      overlay: Text("Hello World"),
    );

    var view =  Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Slider(value: _size, onChanged: (value) => setState(() => _size = value)),
        Center(child: child),
      ],
    );

    return view;
  }

  var _size = 1.0;



  Widget _buildImage()
  {
    return LayoutBuilder(builder: (_, constraints)
    {
      return ColoredBox(
        color: Colors.amber,
        child: Icon(
          Icons.image,
          color: Colors.yellow,
          size: min(constraints.maxWidth, constraints.maxHeight) * _size,
        ),
      );
    });
  }

  Widget _buildOverlay() {
    return const Align(
      alignment: Alignment.bottomRight,
      child: Text(
        'cccccccccccccc',
        style: TextStyle(color: Colors.black),
      ),
    );
  }

}
