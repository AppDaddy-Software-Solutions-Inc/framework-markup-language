// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/system.dart';

final bool enableTestPlayground = false;

class Page404View extends StatelessWidget
{
  final String url;
  Page404View(this.url);

  @override
  Widget build(BuildContext context)
  {
    Scaffold view = Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [Container(child: Icon(Icons.error_outline, size: 128, color: Theme.of(context).colorScheme.error)),
              Text('Error', textAlign: TextAlign.center, style: TextStyle(fontSize: 50, letterSpacing: 2, color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.normal),
              ),
              Text('Page Not Found', textAlign: TextAlign.center, style: TextStyle(fontSize: 30, color: Theme.of(context).colorScheme.onSurface),
              ),
              const Padding(padding: EdgeInsets.all(8)),
              System.app?.singlePage ?? false ?
              Text('Check local assets folder and ensure the file exists', textAlign: TextAlign.center, style: TextStyle(fontSize: 26, color: Theme.of(context).colorScheme.onSurface))
              :
              Text('Check your network connection and nsure the address is correct', textAlign: TextAlign.center, style: TextStyle(fontSize: 26,color: Theme.of(context).colorScheme.onSurface))
            ],
          )),
    );
    return view;
  }
}