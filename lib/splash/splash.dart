// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'dart:math';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fml/fml.dart';
import 'package:fml/helpers/string.dart';
import 'package:fml/system.dart';
import 'package:flutter/material.dart';

// platform
import 'package:fml/platform/platform.web.dart'
if (dart.library.io) 'package:fml/platform/platform.vm.dart'
if (dart.library.html) 'package:fml/platform/platform.web.dart';


class Splash extends StatefulWidget {
  final VoidCallback onInitializationComplete;

  // maximum time (seconds) a splash logo will be shown
  static int maxDelay = 10;

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
    int delay = System.currentApp?.splashDuration ?? 0;

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
    var theme = Theme.of(context);

    var pgColor = Platform.backgroundColor ?? theme.colorScheme.background;
    pgColor = pgColor.computeLuminance() > .5 ? Colors.black.withOpacity(.1) : Colors.white.withOpacity(.1);

    Widget view =  SizedBox(width: 30, height: 30, child: CircularProgressIndicator(color: pgColor));
    view = Center(child: view);

    var bgColor = Platform.backgroundColor ?? theme.colorScheme.background;
    view = Container(color: bgColor, child: view);

    return view;
  }

  Widget splashScreen(BoxConstraints constraints)
  {
    // get image width
    double? imageWidth;

    // percent size?
    if (isPercent(System.currentApp?.splashWidth)) {
      var v = toDouble(System.currentApp?.splashWidth?.split("%")[0]);
      if (v != null)
      {
        v = max(min(v,100),0);
        imageWidth = constraints.maxWidth * (v/100);
      }
    }

    // fixed size?
    if (imageWidth == null && isNumeric(System.currentApp?.splashWidth)) {
      var v = toDouble(System.currentApp?.splashWidth);
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
    if (System.currentApp?.splash != null)
    {
      // convert data uri
      var uri = toDataUri(System.currentApp?.splash);
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
        color: toColor(System.currentApp?.splashBackground) ?? Colors.black,
        child: Center(child: SizedBox(width: imageWidth, child: image)));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: _build);
  }

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