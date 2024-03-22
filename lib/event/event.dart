// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/event/manager.dart';
import 'package:fml/widgets/widget/widget_model.dart';

abstract class IEventScrolling {
  onScroll(Event event);
}

enum EventTypes {
  alert,
  animate,
  back,
  build,
  clear,
  cleardefaultapp,
  close,
  closeroute,
  complete,
  cont,
  copy,
  execute /* Executed by dot notation datasource events */,
  focusnode,
  home,
  keypress,
  signInWithJwt,
  logoff,
  signInWithFirebase,
  maximize,
  minimize,
  open,
  openjstemplate,
  openroute,
  post,
  quit,
  refresh,
  replace,
  replaceroute,
  reset,
  saveas,
  save,
  scroll,
  scrollto,
  set,
  showdebug,
  showlog,
  showtemplate,
  sort,
  sound,
  start,
  stash,
  stop,
  theme,
  toast,
  trigger,
  validate,
  wait
}

/// Events are inline void function calls
///
/// Generally Events are used from templates to force an action to happen within the code
/// Events are scoped but broadcast up and individual widgets can be set up to handle events
class Event {
  /// When an event is processed and you want it to stop broadcasting set handled = true
  bool _handled = false;
  set handled(bool b) {
    if ((cancellable != false) && (b == true)) _handled = true;
  }

  bool get handled {
    return _handled;
  }

  /// What type the event is to determine what it should do
  final EventTypes type;

  /// Parameters to go with an event
  Map<String, String?>? parameters;

  /// Deprecated
  bool bubbles = true;

  /// Acts as an override to any individual widget handling of [handled]
  ///
  /// If set to false it will prevent [handled] from being set to true
  bool cancellable = true;

  /// List of all [IEventManager] objects related to handling this event
  final List<EventManager> functions = [];

  final WidgetModel? model;

  Event(this.type,
      {this.parameters,
      this.bubbles = true,
      this.cancellable = true,
      this.model});
}
