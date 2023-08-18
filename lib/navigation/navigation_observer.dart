// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/navigation/page.dart';

abstract class INavigatorObserver
{
  onNavigatorPush({Map<String?, String>? parameters});
  Map<String?, String>? onNavigatorPop();
  onNavigatorChange();
  BuildContext getNavigatorContext();
}

class NavigationObserver extends NavigatorObserver
{
  final List<INavigatorObserver> _listeners = [];

  static final NavigationObserver _singleton = NavigationObserver._init();
  factory NavigationObserver()
  {
    return _singleton;
  }
  NavigationObserver._init();

  @override
  void didPush(Route route, Route? previousRoute)
  {
    super.didPush(route, previousRoute);

    // remember the route
    if (route.settings.arguments is PageConfiguration)
    {
      var configuration = route.settings.arguments as PageConfiguration;
      configuration.route = route;
    }

    // notify pushed route
    INavigatorObserver? pushed = listenerOf(route);
    if (pushed != null) pushed.onNavigatorPush();

    // signal change
    for (INavigatorObserver listener in _listeners)
    {
      listener.onNavigatorChange();
    }
  }

  @override
  void didPop(Route route, Route? previousRoute)
  {
    super.didPop(route, previousRoute);

    INavigatorObserver? popped = listenerOf(route);
    INavigatorObserver? pushed = listenerOf(previousRoute);

    // get parameters
    Map<String?, String>? parameters;
    if (popped != null) parameters = popped.onNavigatorPop();

    // notify pushed route
    if (pushed != null) pushed.onNavigatorPush(parameters: parameters);

    // signal change
    for (INavigatorObserver listener in _listeners) {
      listener.onNavigatorChange();
    }
  }

  @override
  void didRemove(Route route, Route? previousRoute)
  {
    super.didRemove(route, previousRoute);

    INavigatorObserver? popped = listenerOf(route);
    INavigatorObserver? pushed = listenerOf(previousRoute);

    // get parameters
    Map<String?, String>? parameters;
    if (popped != null) parameters = popped.onNavigatorPop();

    // notify pushed route
    if (pushed != null) pushed.onNavigatorPush(parameters: parameters);

    // signal change
    for (INavigatorObserver listener in _listeners) {
      listener.onNavigatorChange();
    }
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute})
  {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);

    INavigatorObserver? popped = listenerOf(oldRoute);
    INavigatorObserver? pushed = listenerOf(newRoute);

    /* Get Parameters */
    Map<String?, String>? parameters;
    if (popped != null) parameters = popped.onNavigatorPop();

    /* Notify Pushed Route */
    if (pushed != null) pushed.onNavigatorPush(parameters: parameters);

    /* Signal Change */
    for (INavigatorObserver listener in _listeners) {
      listener.onNavigatorChange();
    }
  }

  registerListener(INavigatorObserver listener)
  {
    if (!_listeners.contains(listener)) _listeners.add(listener);
  }

  removeListener(INavigatorObserver listener)
  {
    if (_listeners.contains(listener)) _listeners.remove(listener);
  }

  INavigatorObserver? listenerOf(Route? route)
  {
    if (route == null) return null;
    for (INavigatorObserver listener in _listeners)
    {
      BuildContext context = listener.getNavigatorContext();

        Route? listenerRoute = ModalRoute.of(context);
        if (route == listenerRoute) return listener;

    }
    return null;
  }

  INavigatorObserver? listenerOfExactType(Route route, Type T)
  {
    for (INavigatorObserver listener in _listeners)
    {
      BuildContext context = listener.getNavigatorContext();

        Route? listenerRoute = ModalRoute.of(context);
        if ((route == listenerRoute) && (listener.runtimeType == T)) return listener;

    }
    return null;
  }
}