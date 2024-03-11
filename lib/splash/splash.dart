// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fml/fml.dart';
import 'package:fml/system.dart';
import 'package:flutter/material.dart';

class Splash extends StatefulWidget
{
  final VoidCallback? onInitializationComplete;

  const Splash({super.key, this.onInitializationComplete});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash>
{
  @override
  void initState()
  {
    super.initState();
    initialize();
  }

  Future<void> initialize() async
  {
    // initialize the system
    await System().installed;

    // return
    if (widget.onInitializationComplete != null) widget.onInitializationComplete!();
  }

  @override
  Widget build(BuildContext context)
  {
    return LayoutBuilder(builder: _build);
  }

  Widget _build(BuildContext context, BoxConstraints constraints)
  {
    return MaterialApp(debugShowCheckedModeBanner: false, title: '', home: _buildBody(constraints));
  }

  Widget? _getSplashImage({required double width})
  {
    Widget? image;
    try {
      image = SvgPicture.asset("assets/images/splash.svg", width: width);
    }
    catch(e) {
      image = null;
    }
    try {
      if (image == null) image = Image.asset("assets/images/splash.gif", width: width);
    }
    catch(e) {
      image = null;
    }

    // logo from package
    try {
      if (image == null) image = SvgPicture.asset("assets/images/splash.svg", package: FmlEngine.package, width: width);
    }
    catch(e) {
      image = null;
    }
    try {
      if (image == null) image = Image.asset("assets/images/splash.gif", package: FmlEngine.package, width: width);
    }
    catch(e) {
      image = null;
    }

    return image;
  }

  Widget _buildBody(BoxConstraints constraints)
  {
    // this set the initial splash image
    // on web, it uses the loading.gif image
    var portrait = (constraints.maxWidth < constraints.maxHeight);

    var width = constraints.maxWidth - (constraints.maxWidth/(portrait ? 3 : 1.5));
    if (width > 500) width = 500;

    // get splash image
    var image = _getSplashImage(width: width);

    // return page
    return Container(color: Colors.black, child: Center(child: image));
  }
}