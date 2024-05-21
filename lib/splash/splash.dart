// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'dart:math';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fml/fml.dart';
import 'package:fml/helpers/string.dart';
import 'package:fml/system.dart';
import 'package:flutter/material.dart';

// platform
import 'package:fml/platform/platform.vm.dart'
if (dart.library.io) 'package:fml/platform/platform.vm.dart'
if (dart.library.html) 'package:fml/platform/platform.web.dart';


class Splash extends StatefulWidget {
  final VoidCallback onInitializationComplete;

  // maximum time (seconds) a splash logo will be shown
  static int maxDelay = 10;
  static int defaultDelay = 2;

  late final int delay;

  // await on image
  final Completer<bool> initialized = Completer<bool>();

  Splash({super.key, required this.onInitializationComplete}) {
    initialize();
  }

  @override
  State<Splash> createState() => _SplashState();

  Future<void> initialize() async {

    // wait for system apps to load
    await System.appsLoaded.future;

    // get splash delay
    delay = System.currentApp?.splashDuration ?? (System.currentApp?.splash == null ? 0 : defaultDelay);

    // skip the splash image
    if (delay <= 0) {

      // wait for the system to initialize
      await System.initialized.future;

      // launch engine
      return onInitializationComplete.call();
    }

    // signal default app loaded
    initialized.complete(true);

    // wait for the system to initialize
    await System.initialized.future;

    // show the splash logo for specified delay?
    await Future.delayed(Duration(seconds: min(delay,maxDelay)));

    // done
    onInitializationComplete.call();
  }
}

class _SplashState extends State<Splash> {

  Widget waitScreen()
  {
    // spinner color
    var color = Platform.backgroundColor ?? Theme.of(context).colorScheme.surface;
    color = color.computeLuminance() > .5 ? Colors.black.withOpacity(.5) : Colors.white.withOpacity(.5);

    // spinner
    Widget spinner = Center(child: SizedBox(width: 30, height: 30, child: CircularProgressIndicator(color: color)));

    // don't show spinner unless system loading delays
    // more than 10 seconds
    var duration = const Duration(seconds: 10);

    // fade in spinner
    var view = TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        curve: Curves.easeInExpo,
        duration: duration,
        builder: (BuildContext context, double opacity, Widget? child) => Opacity(opacity: opacity, child: child ??= spinner));

    // background color
    color = Platform.backgroundColor ?? Theme.of(context).colorScheme.surface;

    // page
    return Container(color: color, child: view);
  }

  Widget splashScreen(BoxConstraints constraints)
  {
    // image width
    double? width;

    // percent size?
    if (isPercent(System.currentApp?.splashWidth)) {
      var v = toDouble(System.currentApp?.splashWidth?.split("%")[0]);
      if (v != null)
      {
        v = max(min(v,100),0);
        width = constraints.maxWidth * (v/100);
      }
    }

    // fixed size?
    if (width == null && isNumeric(System.currentApp?.splashWidth)) {
      var v = toDouble(System.currentApp?.splashWidth);
      if (v != null)
      {
        v = max(min(v,constraints.maxWidth),0);
        width = v;
      }
    }

    // undefined size? use default
    width ??= constraints.maxWidth/4;

    // round up
    width = width.ceilToDouble();

    // zero size image? return offstage
    if (width <= 0) return const Offstage();

    // build image
    Widget? image;
    if (System.currentApp?.splash != null)
    {
      // convert data uri
      var uri = toDataUri(System.currentApp?.splash);
      if (uri != null)
      {
        image = uri.mimeType == "image/svg+xml" ?
        SvgPicture.memory(uri.contentAsBytes(), width: width) :
        Image.memory(uri.contentAsBytes(), width: width);
      }
    }
    image ??= Image.asset("assets/images/splash.gif",
        width: width,
        errorBuilder: (a,b,c) =>
            SvgPicture.asset("assets/images/splash.svg", width: width));

    // center and size image
    image = Center(child:SizedBox(width: width, child: image));

    Widget view = image;

    // fade in image
    if (widget.delay >= 2)
    {
      // fade in image in 1/3 the delay time
      var ms = (min(widget.delay,Splash.maxDelay) * 1000 / 3).ceil();
      var duration = Duration(milliseconds: ms);

      // fade in image
      view = TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          curve: Curves.ease,
          duration: duration,
          builder: (BuildContext context, double opacity, Widget? child) => Opacity(opacity: opacity, child: child ??= image));
    }

    // background color
    var color = toColor(System.currentApp?.splashBackground) ?? Platform.backgroundColor ?? Theme.of(context).colorScheme.surface;

    // page
    return Container(color: color, child: view);
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: _build);

  Widget _build(BuildContext context, BoxConstraints constraints) {

    var theme = ThemeData(
        colorSchemeSeed: FmlEngine.defaultColor,
        brightness: FmlEngine.defaultBrightness,
        fontFamily: FmlEngine.defaultFont,
        useMaterial3: true);

    // future view requires image
    var view = FutureBuilder(
        future: widget.initialized.future,
        builder: (context, snapshot) =>
        snapshot.hasData ? splashScreen(constraints) : waitScreen());

    return MaterialApp(home: view, theme: theme);
  }
}