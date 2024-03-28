// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'dart:math';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fml/helpers/string.dart';
import 'package:fml/system.dart';
import 'package:flutter/material.dart';

class Splash extends StatefulWidget {
  final VoidCallback? onInitializationComplete;

  // default time (seconds) the splash logo is shown
  static int defaultDelay = 2;

  // maximum time (seconds) a splash logo will be shown
  static int maxDelay = 10;

  // await on image
  final Completer<bool> initialized = Completer<bool>();

  Splash({super.key, this.onInitializationComplete})
  {
    initialize();
  }

  @override
  State<Splash> createState() => _SplashState();

  Future<void> initialize() async {

    // start time of initialization wait
    var started = DateTime.now().microsecond;

    // wait for system apps to load
    await System.appsLoaded.future;

    // get splash delay
    var delay = toInt(System.brandedApp?.splashDelay) ?? defaultDelay;

    // skip the splash image
    if (delay <= 0) return onInitializationComplete?.call();

    // signal default app loaded
    initialized.complete(true);

    // wait for the system to initialize
    await System.initialized.future;

    // end time of initialization wait
    var ended = DateTime.now().microsecond;

    // elapsed time
    var elapsed = ((ended - started)/1000).ceil();

    // splash screen display time (seconds)
    delay = min(delay,maxDelay);

    // pause start to show display screen just a little longer?
    if (elapsed < delay) await Future.delayed(Duration(seconds: delay - elapsed));

    // done
    onInitializationComplete?.call();
  }
}

class _SplashState extends State<Splash> {

  Widget waitScreen()
  {
    Widget view =  const SizedBox(width: 50, height: 50, child: CircularProgressIndicator.adaptive());
    view = Center(child: view);
    return view;
  }

  Widget splashScreen(BoxConstraints constraints)
  {
    // get image width
    double? imageWidth;

    // percent size?
    if (isPercent(System.brandedApp?.splashWidth)) {
      var v = toDouble(System.brandedApp?.splashWidth?.split("%")[0]);
      if (v != null)
      {
        v = max(min(v,100),0);
        imageWidth = constraints.maxWidth * (v/100);
      }
    }

    // fixed size?
    if (imageWidth == null && isNumeric(System.brandedApp?.splashWidth)) {
      var v = toDouble(System.brandedApp?.splashWidth);
      if (v != null)
      {
        v = max(min(v,constraints.maxWidth),0);
        imageWidth = v;
      }
    }

    // undefined size? use default
    imageWidth ??= constraints.maxWidth/4;

    // round up
    imageWidth = imageWidth.ceilToDouble();

    // zero size image? return offstage
    if (imageWidth <= 0) return const Offstage();

    // get image
    Widget? image;
    if (System.brandedApp?.splash != null)
    {
      // convert data uri
      var uri = toDataUri(System.brandedApp?.splash);
      if (uri != null)
      {
        image = uri.mimeType == "image/svg+xml" ?
        SvgPicture.memory(uri.contentAsBytes(), width: imageWidth) :
        Image.memory(uri.contentAsBytes(), width: imageWidth);
      }
    }
    image ??= Image.asset("assets/images/splash.gif",
        width: imageWidth,
        errorBuilder: (a,b,c) =>
            SvgPicture.asset("assets/images/splash.svg", width: imageWidth));

    // return wrapped centered image
    return Container(
        color: toColor(System.brandedApp?.splashBackground) ?? Colors.black,
        child: Center(child: SizedBox(width: imageWidth, child: image)));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: _build);
  }

  Widget _build(BuildContext context, BoxConstraints constraints) {

    // future view requires image
    var view = FutureBuilder(
        future: widget.initialized.future,
        builder: (context, snapshot) =>
        snapshot.hasData ? splashScreen(constraints) : waitScreen());

    return MaterialApp(home: view);
  }
}