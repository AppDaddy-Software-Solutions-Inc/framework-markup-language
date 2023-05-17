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
    super.performLayout();

    Size newSize = child!.size;
    if (oldSize == newSize) return;

    oldSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_)
    {
      onChange(newSize, data: data);
    });
  }
}

class MeasuredView extends SingleChildRenderObjectWidget
{
  final OnWidgetSizeChange onChange;
  final dynamic data;

  const MeasuredView(Widget widget,this.onChange,{Key? key, this.data}) : super(key: key, child: widget);

  @override
  RenderObject createRenderObject(BuildContext context)
  {
    return MeasureObject(onChange, data: data);
  }
}
