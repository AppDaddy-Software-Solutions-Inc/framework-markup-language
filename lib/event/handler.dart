// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:convert';
import 'dart:core';
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
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/eval/eval.dart';
import 'package:fml/widgets/trigger/trigger_model.dart';
import 'package:fml/sound/sound.dart';
import 'package:petitparser/core.dart';
import 'package:xml/xml.dart';
import 'package:fml/event/event.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

// platform
import 'package:fml/platform/platform.vm.dart'
    if (dart.library.io) 'package:fml/platform/platform.vm.dart'
    if (dart.library.html) 'package:fml/platform/platform.web.dart';

/// EventHandler performs the executions of events and contains the functions for each event [Type]
///
/// Some events are handled internally while others are broadcasted and handled
/// within the appropriate widget(s) usually with the prefix 'on', example: `onClose`
class EventHandler extends Eval {
  static final RegExp thisDot = RegExp(r"\b[t^\.\w]his\.\b");
  static final RegExp nonQuotedSemiColons =
      RegExp(r"\;(?=([^'\\]*(\\.|'([^'\\]*\\.)*[^'\\]*'))*[^']*$)");

  final Model model;

  static const ExpressionEvaluator evaluator = ExpressionEvaluator();
  bool initialized = false;

  /// The String value mapping of all the functions
  final Map<String?, dynamic> functions = <String?, dynamic>{};

  EventHandler(this.model);

  Future<bool> execute(Observable? observable) async {
    bool ok = true;
    if (observable == null) return ok;

    // get expression
    String? expression = (observable.isEval)
        ? observable.value
        : (observable.signature ?? observable.value);
    if (isNullOrEmpty(expression)) return ok;

    // replace 'this' pointer with the parent model id
    if (expression!.contains(thisDot)) {
      expression = expression.replaceAll(thisDot, "${model.id}.");
    }

    // get variables from observable
    Map<String, dynamic> variables = observable.getVariables();

    // execute the expression
    return executeExpression(expression, variables);
  }

  Future<bool> executeExpression(
      String? expression, Map<String, dynamic> variables) async {
    if (isNullOrEmpty(expression)) return true;

    bool ok = true;

    // evaluate the expression
    var result = await evaluate(expression!, variables);

    // get event strings
    List<String>? events = result?.split(nonQuotedSemiColons);

    // process each event
    if (events != null) {
      for (String event in events) {
        dynamic result = await executeEvent(event.trim(), variables: variables);
        if (result is bool && !result)
        {
          ok = false;
          break;
        }
      }
    }

    return ok;
  }

  // returns a list of variables based on source and target alias names
  static Map<String, dynamic> getVariables(
      List<Binding>? bindings, Model local, Model remote,
      {List<String> localAliasNames = const ['this', 'source', 'src'],
      List<String> remoteAliasNames = const ['target', 'trg']}) {
    var variables = <String, dynamic>{};

    // get variables
    bindings?.forEach((binding) {
      var key = binding.key;
      var scope = local.scope;
      var name = binding.source.toLowerCase();

      // local alias
      var i = localAliasNames.indexOf(name);
      if (i >= 0) {
        key = key?.replaceFirst(localAliasNames[i], local.id);
        scope = local.scope;
      }

      // remove alias
      i = remoteAliasNames.indexOf(name);
      if (i >= 0) {
        key = key?.replaceFirst(remoteAliasNames[i], remote.id);
        scope = remote.scope;
      }

      // find the observable
      var observable = System.currentApp?.scopeManager.findObservable(scope, key);

      // add to the list
      variables[binding.signature] = binding.translate(observable?.get());
    });

    return variables;
  }

  Future<dynamic> executeEvent(String event, {Map<String?, dynamic>? variables}) async {

    // initialize event handlers
    initialize();

    dynamic result = await Eval.evaluate(event,
        variables: variables, altFunctions: functions);

    return result;
  }

  initialize() {
    // initialize event handlers
    if (!initialized) {
      functions[fromEnum(EventTypes.alert)] = _handleEventAlert;
      functions[fromEnum(EventTypes.animate)] = _handleEventAnimate;
      functions[fromEnum(EventTypes.back)] = _handleEventBack;
      functions[fromEnum(EventTypes.build)] = _handleEventBuild;
      functions[fromEnum(EventTypes.clearbranding)] = _handleEventClearBranding;
      functions[fromEnum(EventTypes.close)] = _handleEventClose;
      functions[fromEnum(EventTypes.cont)] = _handleEventContinue;
      functions['continue'] = _handleEventContinue;
      functions[fromEnum(EventTypes.copy)] = _handleEventCopy;
      functions[fromEnum(EventTypes.execute)] = _handleEventExecute;
      functions[fromEnum(EventTypes.focusnode)] = _handleEventFocusNode;
      functions[fromEnum(EventTypes.keypress)] = _handleEventKeyPress;
      functions[fromEnum(EventTypes.logon)] = _handleEventLogon;
      functions[fromEnum(EventTypes.logoff)] = _handleEventLogoff;
      functions[fromEnum(EventTypes.fblogon)] = _handleEventFirebaseLogon;
      functions[fromEnum(EventTypes.open)] = _handleEventOpen;
      functions[fromEnum(EventTypes.openjstemplate)] =
          _handleEventOpenJsTemplate;
      // replace (legacy) overlaps with Eval() function replace. use replaceRoute()
      functions[fromEnum(EventTypes.replace)] = _handleEventReplace;
      functions[fromEnum(EventTypes.replaceroute)] = _handleEventReplace;
      functions[fromEnum(EventTypes.refresh)] = _handleEventRefresh;
      functions[fromEnum(EventTypes.reset)] = _handleEventReset;
      functions[fromEnum(EventTypes.saveas)] = _handleEventSaveAs;
      functions[fromEnum(EventTypes.set)] = _handleEventSet;
      functions[fromEnum(EventTypes.setbranding)] = _handleEventSetBranding;
      functions[fromEnum(EventTypes.showdebug)] = _handleEventShowDebug;
      functions[fromEnum(EventTypes.showlog)] = _handleEventShowLog;
      functions[fromEnum(EventTypes.showtemplate)] = _handleEventShowTemplate;
      functions[fromEnum(EventTypes.sound)] = _handleEventSound;
      functions[fromEnum(EventTypes.stash)] = _handleEventStash;
      functions[fromEnum(EventTypes.theme)] = _handleEventTheme;
      functions[fromEnum(EventTypes.toast)] = _handleEventToast;
      functions[fromEnum(EventTypes.trigger)] = _handleEventTrigger;
      functions[fromEnum(EventTypes.wait)] = _handleEventWait;

      // broadcast events
      for (var type in EventTypes.values) {
        String? t = fromEnum(type);
        if (!functions.containsKey(t)) functions[t] = () => _broadcast(type);
      }

      initialized = true;
    }
  }

  Future<String?> evaluate(
      String expression, Map<String?, dynamic> variables) async {
    var i = 0;
    var myExpression = expression;
    var myVariables = <String, dynamic>{};

    try {
      // format the expression
      if (myExpression.contains(nonQuotedSemiColons)) {
        myExpression = formatExpression(myExpression);
      }

      // build variable map and modify expression
      variables.forEach((key, value) {
        i++;
        var myKey = "___V$i";
        myVariables[myKey] = toNum(value, allowMalformed: false) ??
            toBool(value, allowFalse: ['false'], allowTrue: ['true']) ??
            value;
        myExpression = myExpression.replaceAll("$key", myKey);
      });
      variables.clear();
      variables.addAll(myVariables);

      // parse the expression
      var myParsedResult = Expression.tryParse(myExpression);
      var myParsedExpression =
          (myParsedResult is Success) ? myParsedResult.value : null;

      // Unable to preparse
      if (myParsedExpression == null) {
        Log().debug(
            'Failed to parse $myParsedExpression. Error is ${myParsedResult.message}');
        return null;
      }

      // format call and conditional expressions as string variables
      if (myParsedExpression is ConditionalExpression) {
        // build event expressions as variables
        var events = getConditionals(myParsedExpression);
        events.sort((a, b) => Comparable.compare(b.length, a.length));
        myExpression = myParsedExpression.toString();
        for (var e in events) {
          i++;
          var key = "___V$i";
          myVariables[key] = e;
          myExpression = myExpression.replaceAll(e, key);
        }

        // execute the expression and return the result
        myExpression =
            (await Eval.evaluate(myExpression, variables: myVariables))
                .toString();
      }
    } catch (e) {
      Log().exception(e);
      return '';
    }

    return myExpression;
  }

  static String formatExpression(String expression) {
    const placeholder = "[[;]]";

    // replace unquotes ";" characters with special placeholder
    expression = expression.replaceAll(nonQuotedSemiColons, placeholder);

    // remove trailing spaces after all placeholders
    while (expression.contains("$placeholder ")) {
      expression = expression.replaceAll("$placeholder ", placeholder);
    }

    // remove placeholder with adjacent "?" operators
    expression = expression.replaceAll("$placeholder?", " ?");

    // remove placeholder with adjacent ":" operators
    expression = expression.replaceAll("$placeholder:", " :");

    // remove trailing placeholders
    while (expression.endsWith(placeholder)) {
      expression = expression.replaceFirst(
          placeholder, "", expression.lastIndexOf(placeholder));
    }

    // replace placeholders with ";" characters
    return expression.replaceAll(placeholder, ";");
  }

  static List<String> getConditionals(Expression? parsed) {
    List<String> s = [];
    if (parsed is ConditionalExpression) {
      s.addAll(getConditionals(parsed.consequent));
      s.addAll(getConditionals(parsed.alternate));
    } else if ((parsed is BinaryExpression) || (parsed is CallExpression)) {
      s.add(parsed.toString());
    }
    return s;
  }

  void _broadcast(EventTypes type) {
    EventManager.of(model)?.broadcastEvent(model, Event(type, model: model));
  }

  /// Sets an [Observable] value given an id
  Future<bool> _handleEventSet(
      [dynamic variable, dynamic value, dynamic global]) async {
    bool ok = true;
    if (isNullOrEmpty(variable)) return ok;

    // removed global references
    // this is all done in the global.xml file now
    //WidgetModel model = this.model;
    //if ((!isNullOrEmpty(global)) && (toBool(global) == true))
    //{
    //  model = System();
    //}

    Scope? scope = Scope.of(model);
    if (scope == null) return ok;

    // set the variable
    scope.setObservable(variable.toString(), value?.toString());

    return ok;
  }

  /// Sets a Hive Value and Creates and [Observable] by the same name
  Future<bool> _handleEventStash(dynamic key, dynamic value) async =>
      await System.currentApp?.stashValue(key, value) ?? true;

  /// Creates an alert dialog
  Future<bool> _handleEventAlert(
      [dynamic type, dynamic title, dynamic message]) async {
    var dialogType = toEnum(toStr(type), DialogType.values);

    // alert type not supplied
    if (dialogType == null) {
      dialogType = DialogType.none;
      message = title;
      title = type;
      if (message == null && (toStr(title)?.length ?? 0) > 20) {
        title = null;
        message = type;
      }
    }

    await model.framework?.show(
        type: dialogType, title: toStr(title), description: toStr(message));
    return true;
  }

  /// Creates a toast dialog
  Future<bool> _handleEventToast([dynamic message, dynamic duration]) async {
    System.toast(toStr(message), duration: toInt(duration ?? 2));
    return true;
  }

  /// Creates a continue dialog
  ///
  /// Returns a bool, false will prevent further events from a template string from firing
  Future<bool> _handleEventContinue(
      [dynamic type,
      dynamic title,
      dynamic message,
      dynamic phrase1,
      dynamic phrase2]) async {
    bool ok = true;

    var color = Colors.black87;
    //var context = System().context;
    //if (context != null) color = Theme.of(context).buttonTheme.colorScheme?.inversePrimary ?? Theme.of(context).colorScheme.inversePrimary;
    var no = Text(toStr(phrase1) ?? phrase.no,
        style:
            TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.w600));
    var yes = Text(toStr(phrase2) ?? phrase.yes,
        style:
            TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.w600));

    int? response = await model.framework?.show(
        type: toEnum(toStr(type), DialogType.values),
        title: toStr(title),
        description: toStr(message),
        buttons: [no, yes]);

    if (response == 0) ok = false;
    if (response == 1) ok = true;
    if (response == -1) ok = false;
    return ok;
  }

  /// Creates a wait timer that pauses further events from a template string from firing
  Future<bool> _handleEventWait([dynamic time]) async {
    try {
      int wait = 0;
      if (time == null) return true;
      time = time.toString().trim().toLowerCase();

      int factor = 1;

      if (time.endsWith('ms')) {
        time = time.split('ms')[0];
        factor = 1;
      } else if (time.endsWith('m')) {
        time = time.split('m')[0];
        factor = 1000 * 60;
      } else if (time.endsWith('h')) {
        time = time.split('h')[0];
        factor = 1000 * 60 * 60;
      } else {
        time = time.split('s')[0];
        factor = 1000;
      } // seconds

      if (isNumeric(time)) {
        int t = toInt((toDouble(time) ?? 1) * factor) ?? 1000;
        if (t >= 0) wait = t;
      }

      if (wait > 0) await Future.delayed(Duration(milliseconds: wait));
    } catch (e) {
      Log().error('wait(${time.toString()}) event failed');
    }
    return true;
  }

  /// Login using Firebase
  Future<bool> _handleEventFirebaseLogon(
      [dynamic provider, dynamic refresh]) async {

    if (provider is! String) return false;

    String? token;
    if (!isNullOrEmpty(provider)) {
      var user = await _firebaseLogon(provider, <String>['email', 'profile']);
      if (user != null) token = await user.getIdToken();
    }

    if (token == null) return false;
    return await _logon(token, false, false, toBool(refresh) ?? true);
  }

  /// Login using Jason Web Token
  Future<bool> _handleEventLogon(
      [dynamic token,
      dynamic validateSignature,
      dynamic validateAge,
      dynamic refresh]) async {

    return _logon(toStr(token) ?? '', toBool(validateSignature) ?? false, toBool(validateAge) ?? false, toBool(refresh) ?? true);
  }

  Future<bool> _logon(String token, bool? validateAge, bool? validateSignature,
      bool? refresh) async {
    // remove bearer header
    token =
        token.replaceFirst(RegExp("bearer", caseSensitive: false), "").trim();

    // decode token
    Jwt jwt = Jwt.decode(token,
        validateAge: validateAge ?? false,
        validateSignature: validateSignature ?? false);
    if (jwt.valid) {
      // logon
      System.currentApp?.logon(jwt);

      // refresh the framework
      if (toBool(refresh) != false) {
        EventManager.of(model)?.broadcastEvent(
            model, Event(EventTypes.refresh, parameters: null, model: model));
      }

      return true;
    } else {
      System.currentApp?.logoff();
      return false;
    }
  }

  /// Logs a user off
  Future<bool> _handleEventLogoff([dynamic refresh]) async {
    bool ok = await System.currentApp?.logoff() ?? true;

    // Refresh the Framework
    if ((ok) && (toBool(refresh) != false)) {
      EventManager.of(model)?.broadcastEvent(
          model, Event(EventTypes.refresh, parameters: null, model: model));
    }

    return ok;
  }

  Future<bool> _firebaseInit() async {
    if (System.currentApp?.firebase == null) {
      String apiKey = System.currentApp?.firebaseApiKey ?? '0000000000';
      String? authDomain = System.currentApp?.firebaseAuthDomain;

      await fbauth.loadLibrary();
      await fbcore.loadLibrary();

      var options = fbcore.FirebaseOptions(
          appId: "FML",
          messagingSenderId: "FML",
          projectId: "FML",
          apiKey: apiKey,
          authDomain: authDomain);
      System.currentApp?.firebase =
          await fbcore.Firebase.initializeApp(options: options);
    }
    return true;
  }

  Future<dynamic> _firebaseLogon(String provider, List<String> scopes) async {
    dynamic user;
    try {
      await _firebaseInit();
      await _firebaseLogoff();

      var provider0 = fbauth.OAuthProvider(provider);
      provider0.scopes.addAll(scopes);

      Map<String, String> parameters = <String, String>{};
      parameters["prompt"] = 'select_account';
      provider0.setCustomParameters(parameters);

      var credential =
          await fbauth.FirebaseAuth.instance.signInWithPopup(provider0);
      user = credential.user;
    } catch (e) {
      user = null;
      //System.toast("Ooops. There was a problem logging in ...", duration: 2);
      Log().error("Error logging in firebase user. Error is $e");
    }
    return user;
  }

  Future<bool> _firebaseLogoff() async {
    bool ok = true;
    try {
      await _firebaseInit();
      await fbauth.FirebaseAuth.instance.signOut();
    } catch (e) {
      Log().error("Error logging out the firebase user. Error is $e");
    }
    return ok;
  }

  /// Plays a sound
  Future<bool> _handleEventSound(
      [dynamic file, dynamic url, dynamic duration]) async {
    Log().debug("Framework onSound()");

    file = toStr(file);
    url = toStr(url);
    duration = toInt(duration) ?? 0;

    try {
      if (isDesktop) {
        Log().debug("[DESKTOP] Framework onSound()");
        Log().debug('TBD: sound support for desktops');
        return true;
      }

      //////////////////////
      /* Play Local Sound */
      //////////////////////
      if (!isNullOrEmpty(file)) {
        Sound.playLocal('/assets/audio/$file', duration: duration);
        return true;
      }

      ///////////////////////
      /* Play Remote Sound */
      ///////////////////////
      if (!isNullOrEmpty(url)) {
        Sound.playRemote(url, duration: duration);
        return true;
      }

      //////////
      /* Beep */
      //////////
      file = "beep.mp3";
      Sound.playLocal('/assets/audio/$file', duration: duration);
      return true;
    } catch (e) {
      Log().debug("Framework onSound()");
      Log().exception(e);
    }

    return true;
  }

  /// Broadcasts the open event to be handled by individual widgets
  Future<bool> _handleEventOpen(
      [dynamic url,
      dynamic modal,
      dynamic transition,
      dynamic replace,
      dynamic replaceall]) async {
    Map<String, String?> parameters = <String, String?>{};
    parameters['url'] = toStr(url);
    parameters['modal'] = toStr(modal);
    parameters['transition'] = toStr(transition);
    parameters['replace'] = toStr(replace);
    parameters['replaceall'] = toStr(replaceall);
    if (url != null && url != '') {
      EventManager.of(model)?.broadcastEvent(
          model, Event(EventTypes.open, parameters: parameters, model: model));
    }
    return true;
  }

  /// Broadcasts the open event to be handled by individual widgets
  Future<bool> _handleEventOpenJsTemplate([dynamic templ8]) async {
    Map<String, String?> parameters = {};

    parameters['templ8'] = toStr(templ8);
    if (templ8 != null && templ8 != '') {
      EventManager.of(model)?.broadcastEvent(
          model,
          Event(EventTypes.openjstemplate,
              parameters: parameters, model: model));
    }
    return true;
  }

  /// Broadcasts the open event to be handled by individual widgets
  Future<bool> _handleEventReplace([dynamic url, dynamic transition]) async {
    Map<String, String?> parameters = <String, String?>{};
    parameters['url'] = toStr(url);
    parameters['transition'] = toStr(transition);
    parameters['replace'] = "true";
    if (url != null && url != '') {
      EventManager.of(model)?.broadcastEvent(
          model, Event(EventTypes.open, parameters: parameters, model: model));
    }
    return true;
  }

  /// Builds a template from a String and opens in a modal or new window
  Future<bool> _handleEventBuild(
      [dynamic xml, dynamic isModal, dynamic transition]) async {
    var document = XmlDocument.parse(xml);
    String uuid = "${newId()}.xml";
    TemplateManager().toMemory(uuid, document);
    return _handleEventOpen(uuid, isModal, transition);
  }

  /// Broadcasts the close event to be handled by individual widgets
  Future<bool> _handleEventClose([dynamic p]) async {
    Map<String, String?> parameters = <String, String?>{};
    // We set both parameters here and let the nearest listener choose how to handle it
    parameters['until'] = toStr(p); // pop until
    parameters['window'] = toStr(p); // close specific window
    EventManager.of(model)?.broadcastEvent(
        model, Event(EventTypes.close, parameters: parameters));
    return true;
  }

  /// Depreciated, see [EventHandler._handleEventClose]
  Future<bool> _handleEventBack([dynamic p]) async {
    return _handleEventClose(p);
  }

  /// Broadcasts the refresh event to be handled by individual widgets
  Future<bool> _handleEventRefresh() async {
    Map<String, String?> parameters = <String, String?>{};
    EventManager.of(model)?.broadcastEvent(
        model, Event(EventTypes.refresh, parameters: parameters));
    return true;
  }

  /// Saves the text to file
  Future<bool> _handleEventSaveAs([dynamic text, dynamic title]) async {
    try {
      var bytes = utf8.encode(text);
      Platform.fileSaveAs(bytes, title ?? 'file.text');
    } catch (e) {
      Log().error("Error in saveAs(). Error is $e");
    }
    return true;
  }

  /// Broadcasts the keypress event to be handled by individual widgets
  Future<bool> _handleEventKeyPress([dynamic key]) async {
    Map<String, String?> parameters = <String, String?>{};
    parameters['key'] = toStr(key);
    EventManager.of(model)?.broadcastEvent(
        model, Event(EventTypes.keypress, parameters: parameters));
    return true;
  }

  /// Broadcasts the animate event to be handled by individual widgets
  Future<bool> _handleEventAnimate([dynamic id, dynamic enabled]) async {
    Map<String, String?> parameters = <String, String?>{};
    parameters['id'] = toStr(id);
    parameters['enabled'] = toStr(enabled);
    EventManager.of(model)?.broadcastEvent(
        model, Event(EventTypes.animate, parameters: parameters));
    return true;
  }

  /// Broadcasts the animate event to be handled by individual widgets
  Future<bool> _handleEventReset([dynamic id, dynamic enabled]) async {
    Map<String, String?> parameters = <String, String?>{};
    parameters['id'] = toStr(id);
    parameters['enabled'] = toStr(enabled);
    EventManager.of(model)?.broadcastEvent(
        model, Event(EventTypes.reset, parameters: parameters));
    return true;
  }

  /// Calls the trigger with the associated id which then fires it own event(s)
  Future<bool> _handleEventTrigger([dynamic id]) async {
    TriggerModel? trigger;
    trigger ??= model.findAncestorOfExactType(TriggerModel,
        id: id, includeSiblings: true);
    trigger ??= model.findDescendantOfExactType(TriggerModel, id: id);
    if (trigger == null) {
      Map<String, String?> parameters = <String, String?>{};
      parameters['id'] = toStr(id);
      EventManager.of(model)?.broadcastEvent(
          model, Event(EventTypes.trigger, parameters: parameters));
    } else {
      bool shot = await trigger.trigger();
      return shot;
    }
    return true;
  }

  /// Puts the value on the OS clipboard
  Future<bool> _handleEventCopy([dynamic value, dynamic toast]) async {
    try {
      String? label = toStr(value);
      if (label != null && label.isNotEmpty) {
        Clipboard.setData(ClipboardData(text: label));
        if (toBool(toast) != false) System.toast('"${toStr(value)!}" ${phrase.copiedToClipboard}', duration: 1);
      }
    } catch (e) {
      Log().debug('$e');
    }
    return true;
  }

  /// Changes the theme
  Future<bool> _handleEventTheme(
      [dynamic brightness, dynamic color, dynamic font]) async {
    try {
      Map<String, String?> parameters = <String, String?>{};
      parameters['brightness'] = toStr(brightness);
      parameters['color'] = toStr(color);
      parameters['font'] = toStr(font);
      EventManager.of(model)?.broadcastEvent(
          model, Event(EventTypes.theme, parameters: parameters));
    } catch (e) {
      Log().debug('$e');
    }
    return true;
  }

  /// Broadcasts a node that should act as focused
  Future<bool> _handleEventFocusNode([dynamic node]) async {
    try {
      Map<String, String?> parameters = <String, String?>{};
      parameters['key'] = toStr(node);
      EventManager.of(model)?.broadcastEvent(
          model, Event(EventTypes.focusnode, parameters: parameters));
    } catch (e) {
      Log().debug('$e');
    }
    return true;
  }

  /// display the template
  Future<bool> _handleEventShowDebug() async {
    FrameworkView? framework = NavigationManager().frameworkOf();
    if (framework != null) {
      FrameworkModel model = framework.model;
      EventManager.of(model)?.executeEvent(model, "DEBUG.open()");
      return true;
    }
    return false;
  }

  /// display the template
  Future<bool> _handleEventShowLog() async {
    FrameworkView? framework = NavigationManager().frameworkOf();
    if (framework != null) {
      FrameworkModel model = framework.model;
      EventManager.of(model)
          ?.executeEvent(model, "SYSTEM.LOG.export('html',false)");
      return true;
    }
    return false;
  }

  /// display the template
  Future<bool> _handleEventShowTemplate() async {
    EventManager.of(model)?.broadcastEvent(
        model, Event(EventTypes.showtemplate, parameters: null));
    return true;
  }

  // sets app branding
  Future<bool> _handleEventSetBranding(dynamic icon) async {
    try {
      System.setBranding(icon);
    } catch (e) {
      Log().error("Error in setBranding(). Error is $e");
    }
    return true;
  }

  // clears app branding
  Future<bool> _handleEventClearBranding() async {
    System.clearBranding();
    return true;
  }

  /// Executes an Object Function - Olajos Match 14, 2020
  /// This is a catch all and is used to manage all of the <id>.func() calls
  Future<dynamic> _handleEventExecute(String id, String function, dynamic arguments) async {

    var scope = this.model.scope;

    //grab the raw ID before splitting to pass to execute
    var rawID = id;

    // named scope reference?
    if (id.contains(".")) {

      var parts = id.split(".");
      scope = Scope.findNamedScope(id) ?? scope;
      if (scope != this.model.scope) parts.removeAt(0);

      // id should not be set to parts. first as the execute relies on the secondary part of the id to choose the attribute to be set
      id = parts.first;
    }

    // get widget model
    var model = scope?.findModel(id);

    // execute the function
    if (model != null) {
      // execute expects the ID to contain the property to be set appended with dot notation.
      return await model.execute(rawID, function, arguments);
    }

    // stash clear?
    // this hack is necessary since stash isn't a model
    // and adding another function seems overkill
    if (id == "STASH" && function.toLowerCase() == "clear") {
      return await System.currentApp?.clearStash() ?? true;
    }

    return true;
  }
}
