// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'page.dart';

class Transition extends DefaultTransitionDelegate
{
  const Transition() : super();

  @override
  Iterable<RouteTransitionRecord> resolve({
    required List<RouteTransitionRecord> newPageRouteHistory,
    required Map<RouteTransitionRecord?, RouteTransitionRecord>
    locationToExitingPageRoute,
    required Map<RouteTransitionRecord?, List<RouteTransitionRecord>>
    pageRouteToPagelessRoutes,
  })
  {
    final results = super.resolve(newPageRouteHistory: newPageRouteHistory, locationToExitingPageRoute: locationToExitingPageRoute, pageRouteToPagelessRoutes: pageRouteToPagelessRoutes);

    return results;
  }
}

class CustomTransitionBuilder extends PageTransitionsBuilder
{
  const CustomTransitionBuilder(this.platform);
  final String platform;

  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {

    PageConfiguration? args = route.settings.arguments as PageConfiguration?;
    String? transition = (args != null && args.transition != null) ? args.transition : platform;
    if (transition != null) {
      switch(transition) {
        case 'ios':
        case 'macos':
        case 'slide':
          return SlideTransition(position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero,).animate(animation), child: child,);
        case 'android':
          return ScaleTransition(
              scale: animation.drive(Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.ease))),
              child: FadeTransition(opacity: animation, child: child));
        case 'windows':
        case 'linux':
          return FadeTransition(opacity: animation, child: child);
        case 'slideleft':
          return SlideTransition(position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero,).animate(animation), child: child,);
        case 'slideright':
          return SlideTransition(position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero,).animate(animation), child: child,);
        case 'scale':
          return ScaleTransition(scale: Tween<double>(begin: 0.0, end: 1.0,)
              .animate(CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn,),), child: child,);
        case 'rotation': // FR? You're using a rotate transition, what is this.. 1993!?
          return RotationTransition(turns: Tween<double>(begin: 0.0, end: 1.0,)
              .animate(CurvedAnimation(parent: animation, curve: Curves.linear,),), child: child,);
      }
    }
    return FadeTransition(opacity: animation, child: child);
  }
}