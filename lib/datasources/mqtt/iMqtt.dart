// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'iMqttListener.dart';
import 'mqtt.mobile.dart'
if (dart.library.io)   'mqtt.mobile.dart'
if (dart.library.html) 'mqtt.web.dart';

abstract class IMqtt
{
  static IMqtt? create(String url, IMqttListener listener, {String? username, String? password}) => getMqtt(url, listener, username: username, password: password);
  Future<bool> connect();
  Future<bool> disconnect();
  Future<bool> publish(String topic, String msg);
  Future<bool> subscribe(String topic);
  Future<bool> unsubscribe(String topic);
  dispose();
}
