// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:convert';
import 'package:fml/phrase.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/scribble/scribble_model.dart';
import 'package:fml/widgets/viewable/viewable_view.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:perfect_freehand/perfect_freehand.dart';

class ScribbleView extends StatefulWidget implements ViewableWidgetView {
  @override
  final ScribbleModel model;
  ScribbleView(this.model) : super(key: ObjectKey(model));

  @override
  State<ScribbleView> createState() => _ScribbleViewState();
}

class _ScribbleViewState extends ViewableWidgetState<ScribbleView> {
  double width = 300;
  double height = 200;

  @override
  void dispose() {
    linesStreamController.close();
    currentLineStreamController.close();
    super.dispose();
  }

  RenderBox? scribbleBox;
  Offset? scribblePosition;

  bool saveVisible = true;
  bool canScribble = true;
  List<Stroke> lines = <Stroke>[];
  Stroke? line;
  StrokeOptions options = StrokeOptions();
  StreamController<Stroke> currentLineStreamController =
      StreamController<Stroke>.broadcast();
  StreamController<List<Stroke>> linesStreamController =
      StreamController<List<Stroke>>.broadcast();

  Future<void> clear() async {
    setState(() {
      lines = [];
      line = null;
      saveVisible = true;
      canScribble = true;
    });
    await widget.model.answer('');
  }

  Future<void> save() async {
    if (lines.isNotEmpty) {
      setState(() {
        saveVisible = false;
        canScribble = false;
      });
      Uint8List? bytes = await exportBytes();
      if (bytes != null) {
        String value = const Base64Codec().encode(bytes);
        await widget.model.answer(value);
      }
    }
  }

  /// Returns collection of 2D points that represents current signature
  List<Stroke> exportLines() {
    return lines;
  }

  // EXPORT DATA AS PNG AND RETURN BYTES
  Future<Uint8List?> exportBytes() async {
    var painter = Sketcher(
        lines: lines,
        options: options,
        color: Colors
            .black // Hardcode color to black for export a there will be no background/theming
        );
    return await painter.export(Size(width, height));
  }

  Future<void> updateSizeOption(double size) async {
    setState(() {
      options.size = size;
    });
  }

  void onPointerDown(PointerDownEvent details) {
    if (canScribble) {
      options = StrokeOptions(
        simulatePressure: details.kind != PointerDeviceKind.stylus,
      );

      final box = context.findRenderObject() as RenderBox;
      final offset = box.globalToLocal(details.position);
      late final PointVector point;
      if (details.kind == PointerDeviceKind.stylus) {
        point = PointVector(
          offset.dx,
          offset.dy,
          (details.pressure - details.pressureMin) /
              (details.pressureMax - details.pressureMin),
        );
      } else {
        point = PointVector(offset.dx, offset.dy);
      }
      final points = [point];
      line = Stroke(points);
      currentLineStreamController.add(line!);
    }
  }

  void onPointerMove(PointerMoveEvent details) {
    if (canScribble) {
      final box = context.findRenderObject() as RenderBox;
      final offset = box.globalToLocal(details.position);
      late final PointVector point;
      if (offset.dx < width &&
          offset.dx > 0 &&
          offset.dy < height &&
          offset.dy > 0) {
        if (details.kind == PointerDeviceKind.stylus) {
          point = PointVector(
            offset.dx,
            offset.dy,
            (details.pressure - details.pressureMin) /
                (details.pressureMax - details.pressureMin),
          );
        } else {
          point = PointVector(offset.dx, offset.dy);
        }
        final points = [...line!.points, point];
        line = Stroke(points);
        currentLineStreamController.add(line!);
      }
    }
  }

  void onPointerUp(PointerUpEvent details) {
    if (canScribble) {
      lines = List.from(lines)..add(line!);
      linesStreamController.add(lines);
    }
  }

  Widget buildCurrentPath(BuildContext context) {
    return Listener(
      onPointerDown: onPointerDown,
      onPointerMove: onPointerMove,
      onPointerUp: onPointerUp,
      child: RepaintBoundary(
        child: Container(
            color: Colors.transparent,
            width: width,
            height: height,
            child: StreamBuilder<Stroke>(
                stream: currentLineStreamController.stream,
                builder: (context, snapshot) {
                  return CustomPaint(
                    painter: Sketcher(
                        lines: line == null ? [] : [line!],
                        options: options,
                        color: Theme.of(context).colorScheme.onSurface),
                  );
                })),
      ),
    );
  }

  Widget buildAllPaths(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: width,
        height: height,
        child: StreamBuilder<List<Stroke>>(
          stream: linesStreamController.stream,
          builder: (context, snapshot) {
            return CustomPaint(
              painter: Sketcher(
                  lines: lines,
                  options: options,
                  color: Theme.of(context).colorScheme.onSurface),
            );
          },
        ),
      ),
    );
  }

  Widget buildToolbar({bool showControls = false}) {
    return showControls == true
        ? Positioned(
            top: 40.0,
            right: 10.0,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    'Size',
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  Slider(
                      value: options.size,
                      min: 1,
                      max: 50,
                      divisions: 100,
                      label: options.size.round().toString(),
                      onChanged: (double value) => {
                            setState(() {
                              options.size = value;
                            })
                          }),
                  const Text(
                    'Thinning',
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  Slider(
                      value: options.thinning,
                      min: -1,
                      max: 1,
                      divisions: 100,
                      label: options.thinning.toStringAsFixed(2),
                      onChanged: (double value) => {
                            setState(() {
                              options.thinning = value;
                            })
                          }),
                  const Text(
                    'Streamline',
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  Slider(
                      value: options.streamline,
                      min: 0,
                      max: 1,
                      divisions: 100,
                      label: options.streamline.toStringAsFixed(2),
                      onChanged: (double value) => {
                            setState(() {
                              options.streamline = value;
                            })
                          }),
                  const Text(
                    'Smoothing',
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  Slider(
                      value: options.smoothing,
                      min: 0,
                      max: 1,
                      divisions: 100,
                      label: options.smoothing.toStringAsFixed(2),
                      onChanged: (double value) => {
                            setState(() {
                              options.smoothing = value;
                            })
                          }),
                  buildClearButton(),
                  buildSaveButton(),
                ]))
        : Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                Center(
                    child: Container(
                        decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.onInverseSurface,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10.0),
                              topRight: Radius.circular(10.0),
                            )),
                        child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              buildClearButton(),
                              saveVisible
                                  ? buildSaveButton()
                                  : Container(),
                            ])))
              ]);
  }

  Widget buildClearButton() {
    return TextButton(
      style: ButtonStyle(
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(10.0),
          topRight:
              saveVisible ? Radius.zero : const Radius.circular(10.0),
        )),
      )),
      onPressed: clear,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: saveVisible ? Text(phrase.clear) : Text(phrase.reset),
      ),
    );
  }

  Widget buildSaveButton() {
    return TextButton(
      style: ButtonStyle(
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topRight: Radius.circular(10.0),
        )),
      )),
      onPressed: save,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: Text(phrase.save),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return const Offstage();

    Widget icon = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.gesture,
            size: 64,
            color:
                Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5)),
        Icon(Icons.mode_edit_outlined,
            size: 64,
            color:
                Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5))
      ],
    );

    BorderSide borderSide = BorderSide(
        width: 2, color: Theme.of(context).colorScheme.surfaceContainerHighest);

    // view width & height are set by
    // the box layout
    width = widget.model.viewWidth ?? width;
    height = widget.model.viewHeight ?? height;

    Widget view = Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            spreadRadius: -15,
            blurRadius: 7,
            offset: Offset(0, 0), // changes position of shadow
          ),
        ],
      ),
      child: Stack(children: [
        Center(child: icon),
        buildAllPaths(context),
        buildCurrentPath(context),
        buildToolbar(),
        Positioned(
            top: 1,
            left: 1,
            child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    border: Border(top: borderSide, left: borderSide)))),
        Positioned(
            top: 1,
            right: 1,
            child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    border: Border(top: borderSide, right: borderSide)))),
        Positioned(
            bottom: 1,
            left: 1,
            child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    border: Border(bottom: borderSide, left: borderSide)))),
        Positioned(
            bottom: 1,
            right: 1,
            child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    border: Border(bottom: borderSide, right: borderSide)))),
      ]),
    );

    // apply user defined constraints
    view = applyConstraints(view, widget.model.constraints);

    // apply visual transforms
    view = applyTransforms(view);

    return view;
  }
}

// Supplamentary Sketching Classes

class Stroke {
  final List<PointVector> points;

  const Stroke(this.points);
}

class Sketcher extends CustomPainter {
  final List<Stroke> lines;
  final StrokeOptions? options;
  final Color color;

  Sketcher({required this.lines, required this.options, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = color;

    for (int i = 0; i < lines.length; ++i) {
      final outlinePoints = getStroke(lines[i].points, options: options);

      final path = Path();

      if (outlinePoints.isEmpty) {
        return;
      } else if (outlinePoints.length < 2) {
        // If the path only has one line, draw a dot.
        path.addOval(Rect.fromCircle(
            center: Offset(outlinePoints[0].dx, outlinePoints[0].dy),
            radius: 1));
      } else {
        // Otherwise, draw a line that connects each point with a curve.
        path.moveTo(outlinePoints[0].dx, outlinePoints[0].dy);

        for (int i = 1; i < outlinePoints.length - 1; ++i) {
          final p0 = outlinePoints[i];
          final p1 = outlinePoints[i + 1];
          path.quadraticBezierTo(
              p0.dx, p0.dy, (p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
        }
      }

      canvas.drawPath(path, paint);
    }
  }

  Future<Uint8List?> export(Size canvasSize) async {
    var recorder = PictureRecorder();
    var origin = const Offset(0.0, 0.0);
    var paintBounds = Rect.fromPoints(
      canvasSize.topLeft(origin),
      canvasSize.bottomRight(origin),
    );
    var canvas = Canvas(recorder, paintBounds);
    paint(canvas, canvasSize);
    var picture = recorder.endRecording();
    var image = await Future.value(picture.toImage(
      canvasSize.width.round(),
      canvasSize.height.round(),
    ));
    ByteData? bytes = await image.toByteData(format: ImageByteFormat.png);
    return bytes?.buffer.asUint8List();
  }

  @override
  bool shouldRepaint(Sketcher oldDelegate) {
    return true;
  }
}
