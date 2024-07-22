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

    String example1 = 'https://test.appdaddy.co';

    var version = "3.1.0";

    // launch the FML engine
    return FmlEngine(
            ApplicationType.multi,
            domain: example1,
            title: "Framework Markup Language V$version",
            version: version,
            color: Colors.lightBlue,
            brightness: Brightness.light,
            font: 'Roboto',
            transition: PageTransitions.platform)
        .launch();
  }
}
