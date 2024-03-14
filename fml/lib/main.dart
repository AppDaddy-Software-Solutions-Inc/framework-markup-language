import 'package:flutter/material.dart';
import 'package:fml/fml.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    String domain = 'https://test.appdaddy.co';
    //String domain = 'file://fmlpad';
    //String domain = 'file://example'

    // String domain = 'http://10.69.4.245:81';
    // String domain = 'http://10.67.130.75:8081';
    // String domain = 'http://10.69.4.149:81';
    // String domain = 'http://hbrapsweb.goodyear.com:8081';
    // String domain = 'http://ludapsweb.ec.goodyear.com:8081';
    // String domain = 'http://tpkapsweb.tpk.goodyear.com:8081';

    var version = "3.0.0";

    // launch the FML engine
    return FmlEngine(
        domain: domain,
        title: "Flutter Markup Language V$version",
        version: version,
        multiApp: true,
        color: Colors.lightBlue,
        brightness: Brightness.dark,
        font: 'Roboto',
        transition: PageTransitions.platform,
        splashBackgroundColor: Colors.black).launch();
  }
}