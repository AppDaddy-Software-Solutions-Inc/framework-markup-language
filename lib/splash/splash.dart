// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'dart:math';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fml/fml.dart';
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
  final Completer<Widget> image = Completer<Widget>();

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

    var delay = toInt(System.defaultApp?.splashDelay) ?? defaultDelay;

    // skip the splash image
    if (delay <= 0) return onInitializationComplete?.call();

    // build image
    var image = _getSplashImage();

    // set splash image
    this.image.complete(image);

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

  Widget _getSplashImage()
  {
    Widget? view;

    // default apps change the custom splash image
    if (System.defaultApp?.splash != null)
    {
      // convert data uri
      var image = toDataUri(System.defaultApp?.splash);
      if (image != null)
      {
        // svg image?
        if (image.mimeType == "image/svg+xml")
        {
          view = SvgPicture.memory(image.contentAsBytes(), width: 480, height: 480);
        }
        else
        {
          view = Image.memory(image.contentAsBytes(), width: 480, height: 480, fit: null);
        }
      }
    }

    view ??= Image.asset("assets/images/splash.gif",
        errorBuilder: (a,b,c) =>
            SvgPicture.asset("assets/images/splash.svg"));

    return view;
  }
}

class _SplashState extends State<Splash> {

  Widget _getWaitScreen()
  {
    Widget view =  const SizedBox(width: 50, height: 50, child: CircularProgressIndicator.adaptive());
    view = Center(child: view);
    return view;
  }

  Widget _getSplashScreen(BoxConstraints constraints, Widget image)
  {
    Widget view = image;

    // constrain the image to 400 pixels in width
    var portrait = (constraints.maxWidth < constraints.maxHeight);
    double? width = constraints.maxWidth - (constraints.maxWidth / (portrait ? 3 : 1.5));
    if (width > 400)
    {
      view = Container(
          constraints:
          BoxConstraints(maxWidth: width, maxHeight: constraints.maxHeight),
          child: view);
    }

    // splash screen background color
    final Color? color = toColor(System.defaultApp?.splashBackground) ?? FmlEngine.splashBackgroundColor;

    // return wrapped centered image
    return Container(color: color, child: Center(child: view));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: _build);
  }

  Widget _build(BuildContext context, BoxConstraints constraints) {

    // future view requires image
    var view = FutureBuilder(
        future: widget.image.future,
        builder: (context, snapshot) =>
        snapshot.hasData ? _getSplashScreen(constraints, snapshot.data!) : _getWaitScreen());

    return MaterialApp(home: view);
  }
}
