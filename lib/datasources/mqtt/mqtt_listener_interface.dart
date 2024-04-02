// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'payload.dart';

abstract class IMqttListener {
  onMessage(Payload payload);
  onConnected();
  onDisconnected(String origin);
  onPublished(String topic, String message);
  onSubscribed(String topic);
  onUnsubscribed(String topic);
  onError(String error);
}
