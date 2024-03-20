// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/navigation/page.dart';

class RouteParser extends RouteInformationParser<PageConfiguration> {
  const RouteParser() : super();

  @override
  Future<PageConfiguration> parseRouteInformation(
      RouteInformation routeInformation) {
    PageConfiguration configuration =
        PageConfiguration(uri: Uri.tryParse(routeInformation.uri.toString()));
    return Future.value(configuration);
  }

  @override
  RouteInformation restoreRouteInformation(PageConfiguration configuration) {
    return RouteInformation(uri: Uri.tryParse(configuration.uri.toString()));
  }
}
