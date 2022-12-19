// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/navigation/page.dart';

class RouteParser extends RouteInformationParser<PageConfiguration>
{
  const RouteParser() : super();

  @override
  Future<PageConfiguration> parseRouteInformation(RouteInformation routeInformation)
  {
    PageConfiguration configuration = PageConfiguration(url: routeInformation.location);
    return Future.value(configuration);
  }

  @override
  RouteInformation restoreRouteInformation(PageConfiguration configuration)
  {
    return RouteInformation(location: configuration.url);
  }
}