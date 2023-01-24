// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fml/system.dart';
import 'package:flutter/material.dart';

class Splash extends StatefulWidget
{
  final VoidCallback? onInitializationComplete;

  const Splash({Key? key, this.onInitializationComplete}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
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
    // instantiate the system singleton,
    System();

    // initialize the system
    await System.initialized;

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

  Widget _buildBody(BoxConstraints constraints)
  {
    // this set the initial splash image
    // on web, it uses the loading.gif image
    var portrait = (constraints.maxWidth < constraints.maxHeight);

    var width = constraints.maxWidth - (constraints.maxWidth/(portrait ? 3 : 1.5));
    if (width > 500) width = 500;

    var logo = SvgPicture.asset("assets/images/splash.svg",width: width);
    return Container(color: Colors.white, child: Center(child: logo));
  }
}