// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:convert';
import 'dart:core';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:firebase_auth/firebase_auth.dart' deferred as fbauth;
import 'package:firebase_core/firebase_core.dart' deferred as fbcore;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fml/dialog/manager.dart';
import 'package:fml/eval/evaluator.dart';
import 'package:fml/eval/expressions.dart';
import 'package:fml/event/manager.dart';
import 'package:fml/navigation/navigation_manager.dart';
import 'package:fml/phrase.dart';
import 'package:fml/system.dart';
import 'package:fml/template/template_manager.dart';
import 'package:fml/token/token.dart';
import 'package:fml/widgets/framework/framework_model.dart';
import 'package:fml/widgets/framework/framework_view.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/eval/eval.dart';
import 'package:fml/widgets/trigger/trigger_model.dart';
import 'package:fml/sound/sound.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';
import 'package:fml/event/event.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

/// EventHandler performs the executions of events and contains the functions for each event [Type]
///
/// Some events are handled internally while others are broadcasted and handled
/// within the appropriate widget(s) usually with the prefix 'on', example: `onClose`
class EventHandler extends Eval
{
  static final RegExp nonQuotedSemiColons = new RegExp(r"\);(?=([^'\\]*(\\.|'([^'\\]*\\.)*[^'\\]*'))*[^']*$)");
  static final RegExp nonQuotedPlusSigns  = new RegExp(r"\)\+(?=([^'\\]*(\\.|'([^'\\]*\\.)*[^'\\]*'))*[^']*$)");
  final WidgetModel model;

  static final ExpressionEvaluator evaluator = const ExpressionEvaluator();
  bool initialized = false;

  /// The String value mapping of all the functions
  final Map<String?, dynamic> functions = Map<String?, dynamic>();

  EventHandler(this.model);

  Future<bool> execute(Observable? observable) async
  {
    bool ok = true;
    if (observable == null) return ok;

    // get expression
    String? expression = (observable.isEval) ? observable.value : (observable.signature ?? observable.value);
    if (S.isNullOrEmpty(expression)) return ok;

    // get variables from observable
    Map<String?, dynamic> variables = getVariables(observable);

    // evaluate the expression
    if (expression is String) expression = await evaluate(expression, variables);

    // get event strings
    List<String> events = getEvents(expression);

    // process each event
    for (String event in events)
    {
      dynamic ok = await executeEvent(event, variables: variables);
      if (ok == false) break;
    }

    return ok;
  }

  Future<dynamic> executeEvent(String event, {Map<String?, dynamic>? variables}) async
  {
    // initialize event handlers
    initialize();

    dynamic ok = await Eval.evaluate(event, variables: variables, altFunctions: functions);
    return ok;
  }

  initialize()
  {
    // initialize event handlers
    if (!initialized)
    {
      functions[S.fromEnum(EventTypes.alert)]         = _handleEventAlert;
      functions[S.fromEnum(EventTypes.animate)]       = _handleEventAnimate;
      functions[S.fromEnum(EventTypes.back)]          = _handleEventBack;
      functions[S.fromEnum(EventTypes.build)]         = _handleEventBuild;
      functions[S.fromEnum(EventTypes.close)]         = _handleEventClose;
      functions[S.fromEnum(EventTypes.complete)]      = _handleEventComplete;
      functions[S.fromEnum(EventTypes.cont)]          = _handleEventContinue;
      functions['continue']                           = _handleEventContinue;
      functions[S.fromEnum(EventTypes.copy)]          = _handleEventCopy;
      functions[S.fromEnum(EventTypes.execute)]       = _handleEventExecute;
      functions[S.fromEnum(EventTypes.export)]        = _handleEventExport;
      functions[S.fromEnum(EventTypes.focusnode)]     = _handleEventFocusNode;
      functions[S.fromEnum(EventTypes.keypress)]      = _handleEventKeyPress;
      functions[S.fromEnum(EventTypes.signInWithJwt)] = _handleEventSignInWithJwt;
      functions[S.fromEnum(EventTypes.logoff)]        = _handleEventLogoff;
      functions[S.fromEnum(EventTypes.signInWithFirebase)] = _handleEventSignInWithFirebase;
      functions[S.fromEnum(EventTypes.open)]          = _handleEventOpen;
      // replace (legacy) overlaps with Eval() function replace. use replaceRoute()
      functions[S.fromEnum(EventTypes.replace)]       = _handleEventReplace;
      functions[S.fromEnum(EventTypes.replaceroute)]  = _handleEventReplace;
      functions[S.fromEnum(EventTypes.page)]          = _handleEventPage;
      functions[S.fromEnum(EventTypes.refresh)]       = _handleEventRefresh;
      functions[S.fromEnum(EventTypes.saveas)]        = _handleEventSaveAs;
      functions[S.fromEnum(EventTypes.save)]          = _handleEventSave;
      functions[S.fromEnum(EventTypes.scroll)]        = _handleEventScroll;
      functions[S.fromEnum(EventTypes.scrollto)]      = _handleEventScrollTo;
      functions[S.fromEnum(EventTypes.set)]           = _handleEventSet;
      functions[S.fromEnum(EventTypes.showdebug)]     = _handleEventShowDebug;
      functions[S.fromEnum(EventTypes.showlog)]       = _handleEventShowLog;
      functions[S.fromEnum(EventTypes.showtemplate)]  = _handleEventShowTemplate;
      functions[S.fromEnum(EventTypes.sound)]         = _handleEventSound;
      functions[S.fromEnum(EventTypes.stash)]         = _handleEventStash;
      functions[S.fromEnum(EventTypes.theme)]         = _handleEventTheme;
      functions[S.fromEnum(EventTypes.toast)]         = _handleEventToast;
      functions[S.fromEnum(EventTypes.trigger)]       = _handleEventTrigger;
      functions[S.fromEnum(EventTypes.validate)]      = _handleEventValidate;
      functions[S.fromEnum(EventTypes.wait)]          = _handleEventWait;

      // broadcast events
      EventTypes.values.forEach((type)
      {
        String? t = S.fromEnum(type);
        if (!functions.containsKey(t)) functions[t] = () => _broadcast(type);
      });

      initialized = true;
    }
  }

  Future<String?> evaluate(String expression, Map<String?, dynamic> variables) async
  {
    try
    {
      // replace non-quoted ');' with ')+' to trick parser into thinking its a binary expression
      expression = expression.replaceAll(nonQuotedSemiColons, ")+");
      while (expression.contains(")+ ")) expression = expression.replaceAll(")+ ",")+");
      expression = expression.replaceAll("+?", "?");
      expression = expression.replaceAll("+:", ":");
      if (expression.endsWith("+")) expression = expression.substring(0,expression.length - 1);

      // build variable map and modify expression
      Map<String, dynamic> _variables = Map<String, dynamic>();
      int i = 0;
      variables.forEach((key,value)
      {
        i++;
        var _key = "___V$i";
        _variables[_key] = _isNumeric(value) ? _toNum(value) : _isBool(value) ? _toBool(value) : value;
        expression = expression.replaceAll("$key", _key);
      });
      variables.clear();
      variables.addAll(_variables);

      // pre-parse the expression
      var parsed = Expression.tryParse(expression);

      // Unable to preparse
      if (parsed == null) {
        Log().debug('Unable to pre-parse conditionals $expression');
        return null;
      }

      // format call and conditional expressions as string variables
      if (parsed is ConditionalExpression)
      {
        // build event expressions as variables
        var events = getConditionals(parsed);
        events.sort((a, b) => Comparable.compare(b.length, a.length));
        expression = parsed.toString();
        events.forEach((e)
        {
          i++;
          var key = "___V$i";
          _variables[key] = e;
          expression = expression.replaceAll(e, key);
        });

        // execute the expression and get events string
        expression = await Eval.evaluate(expression, variables: _variables);
      }

      // replace non-quoted + with ;. This might be problematic. Needs testing
      expression = expression.replaceAll(nonQuotedPlusSigns, ");");
    }
    catch(e)
    {
      Log().exception(e);
      return '';
    }

    return expression;
  }

  Map<String?, dynamic> getVariables(Observable observable)
  {
    Map<String?, dynamic> variables =  Map<String?, dynamic>();
    if (observable.bindings != null)
    observable.bindings!.forEach((binding)
    {
      Observable? source;
      if (observable.sources != null) source = observable.sources!.firstWhereOrNull((observable) => observable.key == binding.key);
      variables[binding.signature] = (source != null)  ? binding.translate(source.get()) : null;

    });
    return variables;
  }

  List<String> getConditionals(Expression? parsed)
  {
    List<String> s = [];
    if (parsed is ConditionalExpression)
    {
      s.addAll(getConditionals(parsed.consequent));
      s.addAll(getConditionals(parsed.alternate));
    }
    else if ((parsed is BinaryExpression) || (parsed is CallExpression)) s.add(parsed.toString());
    return s;
  }

  List<String> getEvents(String? expression)
  {
    List<String> events = [];
    if (expression is String)
    {
      const String dummySeperator = '!~^';
      expression = expression.replaceAll(nonQuotedSemiColons, ")" + dummySeperator);
      events = expression.split(dummySeperator);
    }
    return events;
  }
  void _broadcast(EventTypes type)
  {
    EventManager.of(model)?.broadcastEvent(model,Event(type, model: model));
  }

  /// Returns a bool from a dynamic value using [S.toBool]
  static dynamic _toBool(dynamic value)
  {
    return S.toBool(value);
  }

  /// Returns a Nul from a dynamic value using [S.toNum]
  static dynamic _toNum(dynamic value)
  {
    return S.toNum(value);
  }

  /// Returns true if the value is numeric
  static bool _isNumeric(dynamic value)
  {
    return S.isNumber(value);
  }

  /// Returns a bool from a dynamic value using [S.isBool]
  static bool _isBool(dynamic value)
  {
    return S.isBool(value);
  }

  /// Sets an [Observable] value given an id
  Future<bool> _handleEventSet([dynamic variable, dynamic value, dynamic global]) async
  {
    bool ok = true;
    if (S.isNullOrEmpty(variable)) return ok;

    // removed global references
    // this is all done in the global.xml file now
    //WidgetModel model = this.model;
    //if ((!S.isNullOrEmpty(global)) && (S.toBool(global) == true))
    //{
    //  model = System();
    //}

    Scope? scope = Scope.of(model);
    if (scope == null) return ok;

    // set the variable
    scope.setObservable(variable.toString(), value != null ? value.toString() : null);

    return ok;
  }

  /// Sets a Hive Value and Creates and [Observable] by the same name
  Future<bool> _handleEventStash(dynamic key, dynamic value) async => await System.app?.stashValue(key,value) ?? true;

  /// Creates an alert dialog
  Future<bool> _handleEventAlert([dynamic type, dynamic title, dynamic message]) async
  {
    await model.framework?.show(type: S.toEnum(S.toStr(type), DialogType.values), title: S.toStr(title), description: S.toStr(message));
    return true;
  }

  /// Creates a toast dialog
  Future<bool> _handleEventToast([dynamic message, dynamic duration]) async
  {
    System.toast(S.toStr(message), duration: S.toInt(duration ?? 2));
    return true;
  }

  /// Creates a continue dialog
  ///
  /// Returns a bool, false will prevent further events from a template string from firing
  Future<bool> _handleEventContinue([dynamic type,  dynamic title, dynamic message, dynamic phrase1, dynamic phrase2]) async
  {
    bool ok = true;
    int? response = await model.framework?.show(
        type: S.toEnum(S.toStr(type), DialogType.values),
        title: S.toStr(title), description: S.toStr(message),
        buttons: [
          Text(S.toStr(phrase1) ?? phrase.no, style: TextStyle(fontSize: 18, color: Colors.white)),
          Text(S.toStr(phrase2) ?? phrase.yes, style: TextStyle(fontSize: 18, color: Colors.white))]);
    if (response == 0)  ok = false;
    if (response == 1)  ok = true;
    if (response == -1) ok = false;
    return ok;
  }

  /// Creates a wait timer that pauses further events from a template string from firing
  Future<bool> _handleEventWait([dynamic time]) async
  {
    try {
      int _wait = 0;
      if (time == null) return true;
      time = time.toString().trim().toLowerCase();

      int factor = 1;

      if (time.endsWith('ms')) {
        time = time.split('ms')[0];
        factor = 1;
      }
      else if (time.endsWith('m')) {
        time = time.split('m')[0];
        factor = 1000 * 60;
      }
      else if (time.endsWith('h')) {
        time = time.split('h')[0];
        factor = 1000 * 60 * 60;
      } else {
        time = time.split('s')[0];
        factor = 1000;
      } // seconds

      if (S.isNumber(time)) {
        int t = S.toInt((S.toDouble(time) ?? 1) * factor) ?? 1000;
        if (t >= 0) _wait = t;
      }

      if (_wait > 0)  await Future.delayed(Duration(milliseconds : _wait));
    }
    catch(e) {
      Log().error('wait(${time.toString()}) event failed');
    }
    return true;
  }

  /// Broadcasts the complete event to be handled by individual widgets
  Future<bool> _handleEventComplete([dynamic id]) async
  {
    Map<String,String?> parameters = Map<String,String?>();
    parameters['id']          = S.toStr(id);
    EventManager.of(model)?.broadcastEvent(model,Event(EventTypes.complete, parameters: parameters, model: model));
    return true;
  }

  /// Login attempt
  ///
  /// Sets the user credentials on the client side to generate a secure token and attempts a login to the server side via databroker
  Future<bool> _handleEventSignInWithFirebase([dynamic provider, dynamic refresh]) async
  {
    String? token;
    if (!S.isNullOrEmpty(provider))
    {
      var user = await _firebaseLogon(provider,<String>['email', 'profile']);
      if (user != null) token = await user.getIdToken();
    }
    if (token == null) return false;
    return await _logon(token, false, false, S.toBool(refresh));
  }

  Future<bool> _handleEventSignInWithJwt([dynamic token, dynamic validateSignature, dynamic validateAge, dynamic refresh]) async
  {
    return _logon(token, validateSignature, validateAge, refresh);
  }

  Future<bool> _logon(String token, bool? validateAge, bool? validateSignature, bool? refresh) async
  {
    // remove bearer header
    token = token.replaceFirst(RegExp("bearer", caseSensitive: false),"").trim();

    // decode token
    Jwt jwt = Jwt.decode(token, validateAge: validateAge ?? false, validateSignature: validateSignature ?? false);
    if (jwt.valid)
    {
      // logon
      System.app?.logon(jwt);

      // refresh the framework
      if (S.toBool(refresh) != false) EventManager.of(model)?.broadcastEvent(model,Event(EventTypes.refresh, parameters: null, model: model));

      return true;
    }
    else
    {
      System.app?.logoff();
      return false;
    }
  }

  /// Logs a user off
  Future<bool> _handleEventLogoff([dynamic refresh]) async
  {
    bool ok = await System.app?.logoff() ?? true;

    // Refresh the Framework
    if ((ok) && (S.toBool(refresh) != false)) EventManager.of(model)?.broadcastEvent(model,Event(EventTypes.refresh, parameters: null, model: model));

    return ok;
  }

  Future<bool> _firebaseInit() async
  {
    if (System.app?.firebase == null)
    {
      String  apiKey     = System.app?.settings("FIREBASE_API_KEY") ?? '0000000000';
      String? authDomain = System.app?.settings("FIREBASE_AUTH_DOMAIN");

      await fbauth.loadLibrary();
      await fbcore.loadLibrary();

      var options = fbcore.FirebaseOptions(appId: "FML", messagingSenderId: "FML", projectId: "FML", apiKey: apiKey, authDomain: authDomain);
      System.app?.firebase = await fbcore.Firebase.initializeApp(options: options);
    }
    return true;
  }

  Future<dynamic> _firebaseLogon(String provider, List<String> scopes) async
  {
    var user;
    try
    {
      await _firebaseInit();
      await _firebaseLogoff();

      var _provider = fbauth.OAuthProvider(provider);
      _provider.scopes.addAll(scopes);

      Map<String,String> parameters = Map<String,String>();
      parameters["prompt"] = 'select_account';
      _provider.setCustomParameters(parameters);

      var credential = await fbauth.FirebaseAuth.instance.signInWithPopup(_provider);
      user = credential.user;
    }
    catch(e)
    {
      user = null;
      //System.toast("Ooops. There was a problem logging in ...", duration: 2);
      Log().error("Error logging in firebase user. Error is $e");
    }
    return user;
  }

  Future<bool> _firebaseLogoff() async
  {
    bool ok = true;
    try
    {
      await _firebaseInit();
      await fbauth.FirebaseAuth.instance.signOut();
    }
    catch(e)
    {
      Log().error("Error logging out the firebase user. Error is $e");
    }
    return ok;
  }

  /// Broadcasts the commit event to be handled by individual widgets
  Future<bool> _handleEventValidate([dynamic id]) async
  {
    Map<String,String?> parameters      = Map<String,String?>();
    parameters['id']          = S.toStr(id);
    EventManager.of(model)?.broadcastEvent(model,Event(EventTypes.validate, parameters: parameters, model: model));
    return true;
  }

  /// Plays a sound
  Future<bool> _handleEventSound([dynamic file, dynamic url, dynamic duration]) async
  {
    Log().debug("Framework onSound()");

    file      = S.toStr(file)      ?? null;
    url       = S.toStr(url)       ?? null;
    duration  = S.toInt(duration)  ?? 0;

    try
    {
      if (isDesktop)
      {
        Log().debug("[DESKTOP] Framework onSound()");
        Log().debug('TBD: sound support for desktops');
        return true;
      }

      //////////////////////
      /* Play Local Sound */
      //////////////////////
      if (!S.isNullOrEmpty(file))
      {
        Sound.playLocal('/assets/audio/$file', duration: duration);
        return true;
      }

      ///////////////////////
      /* Play Remote Sound */
      ///////////////////////
      if (!S.isNullOrEmpty(url))
      {
        Sound.playRemote(url, duration: duration);
        return true;
      }

      //////////
      /* Beep */
      //////////
      file = "beep.mp3";
      Sound.playLocal('/assets/audio/$file', duration: duration);
      return true;
    }
    catch(e)
    {
      Log().debug("Framework onSound()");
      Log().exception(e);
    }

    return true;
  }

  /// Broadcasts the open event to be handled by individual widgets
  Future<bool> _handleEventOpen([dynamic url, dynamic modal, dynamic transition, dynamic replace, dynamic replaceall]) async
  {
    Map<String,String?> parameters     = Map<String,String?>();
    parameters['url']        = S.toStr(url);
    parameters['modal']      = S.toStr(modal);
    parameters['transition'] = S.toStr(transition);
    parameters['replace']    = S.toStr(replace);
    parameters['replaceall'] = S.toStr(replaceall);
    if (url != null && url != '') EventManager.of(model)?.broadcastEvent(model,Event(EventTypes.open, parameters: parameters, model: model));
    return true;
  }

  /// Broadcasts the open event to be handled by individual widgets
  Future<bool> _handleEventReplace([dynamic url, dynamic transition]) async
  {
    Map<String,String?> parameters     = Map<String,String?>();
    parameters['url']        = S.toStr(url);
    parameters['transition'] = S.toStr(transition);
    parameters['replace']    = "true";
    if (S.isNullOrEmpty(url)) EventManager.of(model)?.broadcastEvent(model,Event(EventTypes.open, parameters: parameters, model: model));
    return true;
  }

  /// Builds a template from a String and opens in a modal or new window
  Future<bool> _handleEventBuild([dynamic xml, dynamic isModal, dynamic transition]) async
  {
    var document = XmlDocument.parse(xml);
    String uuid = "${Uuid().v1()}.xml";
    TemplateManager().toMemory(uuid, document);
    return _handleEventOpen(uuid, isModal, transition);
  }

  /// Broadcasts the close event to be handled by individual widgets
  Future<bool> _handleEventClose([dynamic p]) async
  {
    Map<String,String?> parameters = Map<String,String?>();
    // We set both parameters here and let the nearest listener choose how to handle it
    parameters['until'] = S.toStr(p); // pop until
    parameters['window'] = S.toStr(p); // close specific window
    EventManager.of(model)?.broadcastEvent(model,Event(EventTypes.close, parameters: parameters));
    return true;
  }

  /// Depreciated, see [EventHandler._handleEventClose]
  Future<bool> _handleEventBack([dynamic p]) async
  {
    return _handleEventClose(p);
  }

  /// Broadcasts the page event to be handled by individual widgets
  Future<bool> _handleEventPage([dynamic page]) async
  {
    Map<String,String?> parameters = Map<String,String?>();
    parameters['page']   = S.toStr(page);
    EventManager.of(model)?.broadcastEvent(model, Event(EventTypes.page, parameters: parameters));
    return true;
  }

  /// Broadcasts the refresh event to be handled by individual widgets
  Future<bool> _handleEventRefresh() async
  {
    Map<String,String?> parameters = Map<String,String?>();
    EventManager.of(model)?.broadcastEvent(model, Event(EventTypes.refresh, parameters: parameters));
    return true;
  }

  /// Broadcasts the save event to be handled by individual widgets
  Future<bool> _handleEventSave([dynamic id, dynamic complete]) async
  {
    Map<String,String?> parameters   = Map<String,String?>();
    parameters['id']       = S.toStr(id);
    parameters['complete'] = S.toStr(complete);
    EventManager.of(model)?.broadcastEvent(model, Event(EventTypes.save, parameters: parameters));
    return true;
  }

  /// Saves the text to file
  Future<bool> _handleEventSaveAs([dynamic text, dynamic title]) async
  {
    try
    {
      var bytes = utf8.encode(text);
      Platform.fileSaveAs(bytes, title ?? 'file.text');
    }
    catch(e)
    {
      Log().error("Error in saveAs(). Error is $e");
    }
    return true;
  }

  /// Broadcasts the keypress event to be handled by individual widgets
  Future<bool> _handleEventKeyPress([dynamic key]) async
  {
    Map<String,String?> parameters   = Map<String,String?>();
    parameters['key']      = S.toStr(key);
    EventManager.of(model)?.broadcastEvent(model, Event(EventTypes.keypress, parameters: parameters));
    return true;
  }

  /// Broadcasts the scroll event to be handled by individual widgets
  Future<bool> _handleEventScroll([dynamic direction, dynamic pixels]) async
  {
    Map<String,String?> parameters     = Map<String,String?>();
    parameters['direction']  = S.toStr(direction);
    parameters['pixels']     = S.toStr(pixels);
    EventManager.of(model)?.broadcastEvent(model, Event(EventTypes.scroll, parameters: parameters));
    return true;
  }

  /// Broadcasts the export event to be handled by individual widgets
  Future<bool> _handleEventExport([dynamic format, bool? israw]) async
  {
    Map<String,String?> parameters = Map<String,String?>();
    parameters['format'] = S.toStr(format);
    parameters['israw']  = S.toStr(israw);
    EventManager.of(model)?.broadcastEvent(model, Event(EventTypes.export, parameters: parameters));
    return true;
  }

  /// Broadcasts the animate event to be handled by individual widgets
  Future<bool> _handleEventAnimate([dynamic id, dynamic enabled]) async
  {
    Map<String,String?> parameters = Map<String,String?>();
    parameters['id']      = S.toStr(id);
    parameters['enabled'] = S.toStr(enabled);
    EventManager.of(model)?.broadcastEvent(model, Event(EventTypes.animate, parameters: parameters));
    return true;
  }

  /// Broadcasts the scrollto event to be handled by individual widgets
  Future<bool> _handleEventScrollTo([dynamic id]) async
  {
    Map<String,String?> parameters     = Map<String,String?>();
    parameters['id']  = S.toStr(id);
    EventManager.of(model)?.broadcastEvent(model, Event(EventTypes.scrollto, parameters: parameters));
    return true;
  }

  /// Calls the trigger with the associated id which then fires it own event(s)
  Future<bool> _handleEventTrigger([dynamic id]) async
  {

    TriggerModel? trigger;
    if (trigger == null) trigger = model.findAncestorOfExactType(TriggerModel, id: id, includeSiblings: true);
    if (trigger == null) trigger = model.findDescendantOfExactType(TriggerModel, id: id);
    if (trigger == null)
    {
      Map<String,String?> parameters = Map<String,String?>();
      parameters['id'] = S.toStr(id);
      EventManager.of(model)?.broadcastEvent(model, Event(EventTypes.trigger, parameters: parameters));
    }
    else
    {
      bool shot = await trigger.trigger();
      return shot;
    }
    return true;
  }

  /// Puts the value on the OS clipboard
  Future<bool> _handleEventCopy([dynamic value]) async
  {
    try
    {
      Clipboard.setData(ClipboardData(text: S.toStr(value)));
      System.toast(phrase.copiedToClipboard);
    }
    catch(e) {}
    return true;
  }

  /// Changes the theme
  Future<bool> _handleEventTheme([dynamic brightness, dynamic color]) async
  {
    try {
      Map<String,String?> parameters = Map<String,String?>();
      parameters['brightness']  = S.toStr(brightness);
      parameters['color']  = S.toStr(color);
      EventManager.of(model)?.broadcastEvent(model, Event(EventTypes.theme, parameters: parameters));
    } catch(e) {}
    return true;
  }

  /// Broadcasts a node that should act as focused
  Future<bool> _handleEventFocusNode([dynamic node]) async
  {
    try {
      Map<String,String?> parameters = Map<String,String?>();
      parameters['key']  = S.toStr(node);
      EventManager.of(model)?.broadcastEvent(model, Event(EventTypes.focusnode, parameters: parameters));
    } catch(e) {}
    return true;
  }

  /// display the template
  Future<bool> _handleEventShowDebug() async
  {
    FrameworkView? framework = NavigationManager().frameworkOf();
    if (framework != null) {
      FrameworkModel model = framework.model;
      EventManager.of(model)?.executeEvent(model, "LOG.export('html',true)");
      return true;
    }
    return false;
  }

  /// display the template
  Future<bool> _handleEventShowLog() async
  {
    FrameworkView? framework = NavigationManager().frameworkOf();
    if (framework != null) {
      FrameworkModel model = framework.model;
      EventManager.of(model)?.executeEvent(model, "LOG.export('html',false)");
      return true;
    }
    return false;
  }

  /// display the template
  Future<bool> _handleEventShowTemplate() async
  {
    EventManager.of(model)?.broadcastEvent(model, Event(EventTypes.showtemplate, parameters: null));
    return true;
  }

  /// Executes an Object Function - Olajos Match 14, 2020
  /// This is a catch all and is used to manage all of the <id>.func() calls
  Future<bool?> _handleEventExecute(String id, String function, dynamic arguments) async
  {
    // get widget model
    WidgetModel? model = Scope.findWidgetModel(id, this.model.scope);

    // execute the function
    if (model != null) return await model.execute(id, function, arguments);

    // model not found
    Log().debug("Widget Model $id not found", caller: "_handleEventExecute");

    return true;
  }
}

