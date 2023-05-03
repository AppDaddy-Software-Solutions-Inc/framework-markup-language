// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/observable/binding.dart';
import 'package:fml/observable/observables/boolean.dart';
import 'package:fml/observable/observables/integer.dart';
import 'package:fml/observable/observables/string.dart';
import 'package:fml/observable/scope.dart';
import 'package:fml/phrase.dart';
import 'package:fml/system.dart';
import 'package:fml/token/token.dart';
import 'package:fml/widgets/widget/widget_model.dart';

class UserModel extends WidgetModel
{
  static final String myId = "USER";

  late Future<bool> initialized;

  // user is logged on
  late final BooleanObservable _connected;
  bool get connected => _connected.get() ?? false;

  // auhenticated token
  late final StringObservable _token;

  // preferred language
  late final StringObservable _language;

  // user rights
  late final IntegerObservable _rights;
  int? get rights => _rights.get();

  // user claims
  final Map<String, StringObservable> _claims = {};

  /// current json web token used to authenticate
  Jwt? _jwt;
  Jwt? get jwt => _jwt;

  UserModel(WidgetModel parent, {String? jwt}) : super(parent, myId, scope: Scope(id: myId))
  {
    // load the config
    initialized = initialize();

    // set token
    if (jwt != null)
    {
      var token = Jwt(jwt);
      if (token.valid)
      {
        _jwt = token;
        logon(token);
      }
    }
  }

  // initializes the app
  @override
  Future<bool> initialize() async
  {
    // wait for the system to initialize
    await System.initialized;

    _connected = BooleanObservable(Binding.toKey("connected"), false, scope: scope);
    _rights    = IntegerObservable(Binding.toKey("language"), Phrases.english, scope: scope);
    _language  = StringObservable(Binding.toKey("rights"), 0, scope: scope);
    _token     = StringObservable(Binding.toKey('jwt'), null, scope: scope);
    return true;
  }

  Future<bool> logon(Jwt jwt) async
  {
    // valid token?
    if (jwt.valid)
    {
      // set system token
      _jwt = jwt;
      _token.set(jwt.token);

      // set connected = true
      _connected.set(true);

      // set user claims
      jwt.claims.forEach((key, value)
      {
        key = key.toLowerCase().trim();
        switch (key)
        {
          case 'connected' :
            break;

          case 'rights' :
            _rights.set(value);
            break;

          case 'language' :
            _language.set(value);
            break;

          default:
            if (_claims.containsKey(key)) {
              _claims[key]!.set(value);
            } else {
              _claims[key] = StringObservable(Binding.toKey(key), value, scope: scope);
            }
        }
      });

      // clear missing claims
      _claims.forEach((key, observable) => jwt.claims.containsKey(key) ? null : observable.set(null));

      // set phrase language
      phrase.language = _language.get();

      return true;
    }

    // clear all claims
    else {
      return await logoff();
    }
  }

  Future<bool> logoff() async
  {
    // clear system token
    _jwt = null;
    _token.set(null);

    // set connected = true
    _connected.set(false);

    // clear claims
    _claims.forEach((key, observable) => observable.set(null));

    // clear language
    _language.set(Phrases.english);

    // clear rights
    _rights.set(0);

    // set phrase language
    phrase.language = Phrases.english;

    return false;
  }

  // return specific user claim
  String? claim(String property) => _claims.containsKey(property) ? _claims[property]?.get() : null;
}