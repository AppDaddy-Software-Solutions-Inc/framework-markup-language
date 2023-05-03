// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';

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

  static NavigationObserver _singleton = NavigationObserver._init();
  factory NavigationObserver()
  {
    return _singleton;
  }
  NavigationObserver._init();

  @override
  void didPush(Route route, Route? previousRoute)
  {
    super.didPush(route, previousRoute);

    /////////////////////////
    /* Notify Pushed Route */
    /////////////////////////
    INavigatorObserver? _pushed = listenerOf(route);
    if (_pushed != null) _pushed.onNavigatorPush();

    ///////////////////
    /* Signal Change */
    ///////////////////
    for (INavigatorObserver listener in _listeners) {
      listener.onNavigatorChange();
    }
  }

  @override
  void didPop(Route route, Route? previousRoute)
  {
    super.didPop(route, previousRoute);

    INavigatorObserver? _popped = listenerOf(route);
    INavigatorObserver? _pushed = listenerOf(previousRoute);

    ////////////////////
    /* Get Parameters */
    ////////////////////
    Map<String?, String>? parameters;
    if (_popped != null) parameters = _popped.onNavigatorPop();

    /////////////////////////
    /* Notify Pushed Route */
    /////////////////////////
    if (_pushed != null) _pushed.onNavigatorPush(parameters: parameters);

    ///////////////////
    /* Signal Change */
    ///////////////////
    for (INavigatorObserver listener in _listeners) {
      listener.onNavigatorChange();
    }
  }

  @override
  void didRemove(Route route, Route? previousRoute)
  {
    super.didRemove(route, previousRoute);

    INavigatorObserver? _popped = listenerOf(route);
    INavigatorObserver? _pushed = listenerOf(previousRoute);

    ////////////////////
    /* Get Parameters */
    ////////////////////
    Map<String?, String>? parameters;
    if (_popped != null) parameters = _popped.onNavigatorPop();

    /////////////////////////
    /* Notify Pushed Route */
    /////////////////////////
    if (_pushed != null) _pushed.onNavigatorPush(parameters: parameters);

    ///////////////////
    /* Signal Change */
    ///////////////////
    for (INavigatorObserver listener in _listeners) {
      listener.onNavigatorChange();
    }
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute})
  {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);

    INavigatorObserver? _popped = listenerOf(oldRoute);
    INavigatorObserver? _pushed = listenerOf(newRoute);

    /* Get Parameters */
    Map<String?, String>? parameters;
    if (_popped != null) parameters = _popped.onNavigatorPop();

    /* Notify Pushed Route */
    if (_pushed != null) _pushed.onNavigatorPush(parameters: parameters);

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