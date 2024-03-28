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
    //String example1 = 'http://10.69.4.245:81/';
    String example1 = 'https://test.appdaddy.co';
    //String example1 = 'http://ludapsweb.ec.goodyear.com:81/';
    //String example1 = 'https://fml.dev';
    //String example2 = 'file://fmlpad';
    //String example3 = 'file://example';

    var version = "3.0.0";

    // launch the FML engine
    return FmlEngine(
            ApplicationType.branded,
            domain: example1,
            title: "Flutter Markup Language V$version",
            version: version,
            color: Colors.lightBlue,
            brightness: Brightness.light,
            font: 'Roboto',
            transition: PageTransitions.platform)
        .launch();
  }
}
