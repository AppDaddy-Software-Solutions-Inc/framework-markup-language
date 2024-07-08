// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/navigation/page.dart';

abstract class INavigatorObserver {
  onNavigatorPush({Map<String?, String>? parameters});
  Map<String?, String>? onNavigatorPop();
  void onNavigatorChange();
  BuildContext getNavigatorContext();
  Future<bool> canPop();
}

class NavigationObserver extends NavigatorObserver {
  final List<INavigatorObserver> _listeners = [];

  static final NavigationObserver _singleton = NavigationObserver._init();
  factory NavigationObserver() {
    return _singleton;
  }
  NavigationObserver._init();

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);

    // is a framework route?
    if (route.settings.arguments is PageConfiguration) {

      // notify pushed route
      var pushed = listenersOf(route);
      for (var listener in pushed) {
        listener.onNavigatorPush();
      }

      // signal change
      for (INavigatorObserver listener in _listeners) {
        listener.onNavigatorChange();
      }
    }
  }

  /// The [Navigator] popped `route`.
  ///
  /// The route immediately below that one, and thus the newly active
  /// route, is `previousRoute`.
  @override
  void didPop(Route route, Route? previousRoute) {

    super.didPop(route, previousRoute);

    // is a framework route?
    if (route.settings.arguments is PageConfiguration) {

      // get pushed & popped route listeners
      var popped = listenersOf(route);
      var pushed = listenersOf(previousRoute);

      // notify popped route(s)
      Map<String?, String>? parameters;
      for (var listener in popped) {
        var result = listener.onNavigatorPop();
        parameters ??= result;
      }

      // notify pushed route(s)
      for (var listener in pushed) {
        listener.onNavigatorPush(parameters: parameters);
      }

      // signal change
      for (INavigatorObserver listener in _listeners) {
        listener.onNavigatorChange();
      }
    }
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);

    // is a framework route?
    if (route.settings.arguments is PageConfiguration) {

      // get pushed & popped route listeners
      var popped = listenersOf(route);
      var pushed = listenersOf(previousRoute);

      // notify popped route(s)
      Map<String?, String>? parameters;
      for (var listener in popped) {
        var result = listener.onNavigatorPop();
        parameters ??= result;
      }

      // notify pushed route(s)
      for (var listener in pushed) {
        listener.onNavigatorPush(parameters: parameters);
      }

      // signal change
      for (INavigatorObserver listener in _listeners) {
        listener.onNavigatorChange();
      }
    }
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);

    // is a framework route?
    if (newRoute?.settings.arguments is PageConfiguration) {

      // get pushed & popped route listeners
      var popped = listenersOf(oldRoute);
      var pushed = listenersOf(newRoute);

      // notify popped route(s)
      Map<String?, String>? parameters;
      for (var listener in popped) {
        var result = listener.onNavigatorPop();
        parameters ??= result;
      }

      // notify pushed route(s)
      for (var listener in pushed) {
        listener.onNavigatorPush(parameters: parameters);
      }

      /* Signal Change */
      for (INavigatorObserver listener in _listeners) {
        listener.onNavigatorChange();
      }
    }
  }

  registerListener(INavigatorObserver listener) {
    if (!_listeners.contains(listener)) _listeners.add(listener);
  }

  removeListener(INavigatorObserver listener) {
    if (_listeners.contains(listener)) _listeners.remove(listener);
  }

  List<INavigatorObserver> listenersOf(Route? route) {

    if (route == null) return [];

    List<INavigatorObserver> listeners = [];

    // traverse listeners
    for (INavigatorObserver listener in _listeners) {
      if (route == routeOf(listener.getNavigatorContext())) listeners.add(listener);
    }

    return listeners;
  }

  List<INavigatorObserver> listenersOfPage(Page? page) {

    if (page == null) return [];

    List<INavigatorObserver>  listeners = [];

    // traverse listeners
    for (INavigatorObserver listener in _listeners) {
      if (pageOf(listener.getNavigatorContext()) == page) listeners.add(listener);
    }

    return listeners;
  }

  static Page? pageOf(BuildContext context) {
    Page? page;
    var route = routeOf(context);
    if (route?.settings != null && route?.settings is Page) {
      page = (route!.settings as Page);
    }
    return page;
  }

  static Route? routeOf(BuildContext context) => ModalRoute.of(context);
}
