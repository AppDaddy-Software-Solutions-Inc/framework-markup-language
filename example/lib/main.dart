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

    //String example = 'https://pad.fml.dev';
    String example = 'https://test.appdaddy.co';
    //String example = 'http://10.69.4.245:81/';
    //String example = 'http://in4.pro';
    //String example = 'https://pad.fml.dev';
    //String example = 'http://lawapsweb.law.goodyear.com:8081/';

    var version = "3.1.2";

    // launch the FML engine
    return FmlEngine(
            ApplicationType.single,
            domain: example,
            title: "Framework Markup Language V$version",
            version: version,
            color: Colors.lightBlue,
            brightness: Brightness.light,
            font: 'Roboto',
            transition: PageTransitions.platform)
        .launch();
  }
}
