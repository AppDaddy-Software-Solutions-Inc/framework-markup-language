// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fml/fml.dart';
import 'package:fml/system.dart';
import 'package:flutter/material.dart';

class Splash extends StatefulWidget {
  final VoidCallback? onInitializationComplete;

  const Splash({super.key, this.onInitializationComplete});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    // initialize the system
    await System().installed;

    // return
    if (widget.onInitializationComplete != null) {
      widget.onInitializationComplete!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: _build);
  }

  Widget _build(BuildContext context, BoxConstraints constraints) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '',
        home: _buildBody(constraints));
  }

  Widget? _getSplashImage(BoxConstraints constraints) {
    // splash image - splash.gif, if not found, then splash.svg
    Widget image = Image.asset("assets/images/splash.gif",
        errorBuilder: (a, b, c) =>
            SvgPicture.asset("assets/images/splash.svg"));

    // constrain the image
    var portrait = (constraints.maxWidth < constraints.maxHeight);
    double? width =
        constraints.maxWidth - (constraints.maxWidth / (portrait ? 3 : 1.5));
    if (width > 400) {
      image = Container(
          constraints:
              BoxConstraints(maxWidth: width, maxHeight: constraints.maxHeight),
          child: image);
    }

    return image;
  }

  Widget _buildBody(BoxConstraints constraints) {
    // get splash image
    var image = _getSplashImage(constraints);

    // return page
    return Container(
        color: FmlEngine.splashBackgroundColor, child: Center(child: image));
  }
}
