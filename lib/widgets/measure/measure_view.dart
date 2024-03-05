// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef OnWidgetSizeChange = void Function(Size size, {dynamic data});

class MeasureObject extends RenderProxyBox
{
  Size? oldSize;

  final OnWidgetSizeChange onChange;
  final dynamic data;

  MeasureObject(this.onChange, {this.data});

  @override
  void performLayout()
  {
    Size size = Size(0,0);
    if (child != null)
    {
      child!.layout(constraints, parentUsesSize: true);
      size = child!.size;
    }
    this.size = constraints.smallest;

    if (oldSize == size) return;
    oldSize = size;
    WidgetsBinding.instance.addPostFrameCallback((_)
    {
      onChange(size, data: data);
    });
  }

  @override
  void paint(PaintingContext context, Offset offset)
  {
    // do nothing
    return;
  }
}

class MeasureView extends SingleChildRenderObjectWidget
{
  final OnWidgetSizeChange onChange;
  final dynamic data;

  const MeasureView(Widget widget,this.onChange,{super.key, this.data}) : super(child: widget);

  @override
  RenderObject createRenderObject(BuildContext context)
  {
    return MeasureObject(onChange, data: data);
  }
}
