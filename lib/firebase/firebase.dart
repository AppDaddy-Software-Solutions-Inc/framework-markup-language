import 'package:firebase_auth/firebase_auth.dart' deferred as auth;
import 'package:firebase_core/firebase_core.dart' deferred as core;

import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:fml/helpers/string.dart';
import 'package:fml/helpers/xml.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/system.dart';

import 'package:xml/xml.dart';

enum Providers { google, facebook, apple, email, microsoft }

class Firebase {

  late final XmlElement config;

  dynamic app;

  // connected to firebase?
  bool _connected = false;
  bool get connected =>  _connected;

  Firebase(XmlElement config) {
    this.config = config.copy();
  }

  Future<bool> _init() async {

    if (app == null) {

      // load libraries
      await auth.loadLibrary();
      await core.loadLibrary();

      // build app
      app = await core.Firebase.initializeApp(options: _options);
    }

    return true;
  }

  Future<dynamic> logon(Providers providerId) async {

    dynamic user;

    try {

      // initialize firebase
      await _init();

      // logoff any existing user
      await logoff();

      var provider = auth.OAuthProvider("$providerId.com");
      provider.scopes.addAll(['profile','email']);

      Map<String, String> parameters = <String, String>{};
      parameters["prompt"] = 'select_account';
      provider.setCustomParameters(parameters);

      if (kIsWeb) {
        var credential =
        await auth.FirebaseAuth.instance.signInWithPopup(provider);
        user = credential.user;
      }

      else {
        var credential =
        await auth.FirebaseAuth.instance.signInWithProvider(provider);
        user = credential.user;
      }

      // set connected
      _connected = true;

    } catch (e) {
      user = null;
      System.toast("Ooops. There was a problem logging in. $e", duration: 2);
      Log().error("Error logging in firebase user. Error is $e");
    }

    return user;
  }

  Future<bool> logoff() async {
    bool ok = true;
    _connected = false;
    try {

      // initialize firebase
      await _init();

      // logoff
      await auth.FirebaseAuth.instance.signOut();
    }
    catch (e) {
      Log().error("Error logging out the firebase user. Error is $e");
    }
    return ok;
  }

  dynamic get _options {

    // web?
    if (kIsWeb) {
      return _web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return _ios;
      case TargetPlatform.macOS:
        return _macos;
      case TargetPlatform.windows:
        return _windows;
      case TargetPlatform.linux:
      case TargetPlatform.android:
      default:
        return _android;
    }
  }

  XmlElement? childOf(XmlElement? parent, String childName) {

    if (parent == null) return null;

    var e = Xml.getChildElement(node: parent, tag: childName) ??
        Xml.getChildElement(node: parent, tag: childName.toLowerCase()) ??
        Xml.getChildElement(node: parent, tag: childName.toUpperCase());

    return e;
  }

  String valueOf(XmlElement? node) {
    String? value = Xml.get(node: node, tag: 'value');
    if (isNullOrEmpty(value)) value = Xml.getText(node);
    return value ?? '';
  }

  dynamic get _web {

    var tag = "Web";
    var root = childOf(config, tag);

    var options = core.FirebaseOptions(
      apiKey: valueOf(childOf(root, "apiKey")),
      appId: valueOf(childOf(root, "appId")),
      messagingSenderId: valueOf(childOf(root, "messagingSenderId")),
      projectId: valueOf(childOf(root, "projectId")),
      authDomain: valueOf(childOf(root, "authDomain")),
      storageBucket: valueOf(childOf(root, "storageBucket")),
      measurementId: valueOf(childOf(root, "measurementId")),
    );
    return options;
  }

  dynamic get _android {
    var tag = "Android";
    var root = childOf(config, tag);

    var options = core.FirebaseOptions(
      apiKey: valueOf(childOf(root, "apiKey")),
      appId: valueOf(childOf(root, "appId")),
      messagingSenderId: valueOf(childOf(root, "messagingSenderId")),
      projectId: valueOf(childOf(root, "projectId")),
      storageBucket: valueOf(childOf(root, "storageBucket")),
    );
    return options;
  }

  dynamic get _ios {

    var tag = "Ios";
    var root = childOf(config, tag);


    var options = core.FirebaseOptions(
      apiKey: valueOf(childOf(root, "apiKey")),
      appId: valueOf(childOf(root, "appId")),
      messagingSenderId: valueOf(childOf(root, "messagingSenderId")),
      projectId: valueOf(childOf(root, "projectId")),
      storageBucket: valueOf(childOf(root, "storageBucket")),
      iosClientId: valueOf(childOf(root, "iosClientId")),
      iosBundleId: valueOf(childOf(root, "iosBundleId")),
    );
    return options;
  }

  dynamic get _macos {

    var tag = "MacOS";
    var root = childOf(config, tag);

    var options = core.FirebaseOptions(
      apiKey: valueOf(childOf(root, "apiKey")),
      appId: valueOf(childOf(root, "appId")),
      messagingSenderId: 'messagingSenderId',
      projectId: valueOf(childOf(root, "projectId")),
      storageBucket: valueOf(childOf(root, "storageBucket")),
      iosClientId: valueOf(childOf(root, "iosClientId")),
      iosBundleId: valueOf(childOf(root, "iosBundleId")),
    );
    return options;
  }

  dynamic get _windows {
    var tag = "Windows";
    var root = childOf(config, tag);

    var options = core.FirebaseOptions(
      apiKey: valueOf(childOf(root, "apiKey")),
      appId: valueOf(childOf(root, "appId")),
      messagingSenderId: valueOf(childOf(root, "messagingSenderId")),
      projectId: valueOf(childOf(root, "projectId")),
      authDomain: valueOf(childOf(root, "authDomain")),
      storageBucket: valueOf(childOf(root, "storageBucket")),
      measurementId: valueOf(childOf(root, "measurementId")),
    );
    return options;
  }
}