// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:collection';
import 'package:fml/event/handler.dart';
import 'package:fml/widgets/widget/model.dart';
import 'event.dart';

typedef OnEventCallback = void Function(Event);

abstract class IEventManager {
  registerEventListener(EventTypes type, OnEventCallback callback,
      {int? priority});
  removeEventListener(EventTypes type, OnEventCallback callback);
  broadcastEvent(Model sender, Event event);
  executeEvent(Model sender, String event);
}

/// EventManager handles all event notifications from its decendants
///
/// An EventManager can broadcast events and listen for events to handle
/// There is an EventManager wrapped around the [Framework] so every widget
/// has at least one ancestor EventManager
class EventManager {
  final HashMap<EventTypes, List<OnEventCallback>> listeners =
      HashMap<EventTypes, List<OnEventCallback>>();

  EventManager();

  /// Gets the nearest [EventManager] ancestor from this widget
  static IEventManager? of(Model model) {
    if (model is IEventManager) {
      return model as IEventManager;
    } else {
      return _parentOf(model);
    }
  }

  /// Register a listener on an event type
  ///
  /// To have a widget's [EventManager] listen to an [Event] you must register a listener
  /// in the didChangeDependencies() and didUpdateWidget() in its _ViewState
  register(EventTypes type, OnEventCallback callback, {int? priority}) {
    if (!listeners.containsKey(type)) listeners[type] = [];
    int i = listeners[type]!.length;
    if ((priority != null) && (priority >= 0) && (priority <= i)) i = priority;
    if (!listeners[type]!.contains(callback)) {
      listeners[type]!.insert(i, callback);
    }
  }

  /// Remove a listener on an event type
  ///
  /// If you register a listener in a _ViewState you must remove it in the dispose()
  void remove(EventTypes type, OnEventCallback callback) {
    if (listeners.containsKey(type) && listeners[type]!.contains(callback)) {
      listeners[type]!.remove(callback);
    }
  }

  /// Executes and Event
  Future<dynamic> execute(Model source, String event) async =>
      await EventHandler(source).executeEvent(event);

  /// Notifies listeners about an [Event]
  void broadcast(Model source, Event event) {
    /* Already Processed? */
    if (!event.functions.contains(this)) {
      // Mark as Processed
      event.functions.add(this);

      // Notify Listeners
      List<OnEventCallback>? callbacks;
      if (listeners.containsKey(event.type)) callbacks = listeners[event.type];
      if (callbacks != null) {
        for (var callback in callbacks) {
          if (!event.handled) {
            callback(event);
          }
        }
      }

      // Notify Child Event Managers
      if (!event.handled) {
        List<IEventManager> children = _childrenOf(source);
        for (IEventManager child in children) {
          if (event.handled) break;
          child.broadcastEvent(child as Model, event);
        }
      }

      // Notify Parent Event Manager
      if (!event.handled && event.bubbles) {
        IEventManager? parent = _parentOf(source);
        if (parent != null) parent.broadcastEvent(parent as Model, event);
      }
    }
  }

  static IEventManager? _parentOf(Model? model) {
    if (model == null) return null;
    if (model.parent is IEventManager) return model.parent as IEventManager;
    return _parentOf(model.parent);
  }

  List<IEventManager> _childrenOf(Model? model) {
    List<IEventManager> list = [];
    if (model?.children != null) {
      for (Model child in model!.children!) {
        list.addAll(_childrenOf(child));
      }
    }
    return list;
  }
}
