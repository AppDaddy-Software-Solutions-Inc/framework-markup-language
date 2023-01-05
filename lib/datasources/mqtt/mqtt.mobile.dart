// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';

import 'package:fml/system.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:uuid/uuid.dart';

import 'iMqttListener.dart';
import 'payload.dart';
import 'iMqtt.dart';
import 'package:fml/helper/helper_barrel.dart';

IMqtt? getMqtt(String url, IMqttListener listener) => MqttMobile(url, listener);

class MqttMobile implements IMqtt
{
  late MqttServerClient client;
  String url;
  String identifier = (System().userProperty('name') ?? 'unknown') + " : " + Uuid().v1();
  int    keepalive = 60;
  bool   connected = false;
  IMqttListener listener;

  MqttMobile(this.url, this.listener)
  {
    Uri? uri = S.toURI(this.url);
    if (uri == null) return;
    var scheme = uri.scheme;
    var server = uri.host;
    var port   = (uri.port == 443 || uri.port == 80) ? 1883 : uri.port;
    var url = scheme + '://' + server;

    /// Create Client
    client = MqttServerClient(url, identifier);

    /// Set logging on if needed, defaults to off
    client.logging(on: false);

    /// If you intend to use a keep alive value in your connect message that is not the default(60s)
    /// you must set it here
    client.keepAlivePeriod = keepalive;

    /// The ws port for Mosquitto is 8080, for wss it is 8081
    client.port = port;

    /// Add the unsolicited disconnection callback
    client.onDisconnected = _onDisconnected;

    /// Add the successful connection callback
    client.onConnected = _onConnected;

    client.useWebSocket = (scheme.toLowerCase().startsWith('ws'));

    /// Add a subscribed callback, there is also an unsubscribed callback if you need it.
    /// You can add these before connection or change them dynamically after connection if
    /// you wish. There is also an onSubscribeFail callback for failed subscriptions, these
    /// can fail either because you have tried to subscribe to an invalid topic or the source
    /// rejects the subscribe request.
    client.onSubscribed   = _onSubscribed;
    client.onUnsubscribed = _onUnSubscribed;

    /// Set a ping received callback if needed, called whenever a ping response(pong) is received
    /// from the source.
    client.pongCallback = _onPong;
  }

  Future<bool> connect() async
  {
    Log().debug('MQTT:: Connecting to $url on port ${client.port}');

    /// Create a connection message to use or use the default one. The default one sets the
    /// client identifier, any supplied username/password, the default keepalive interval(60s)
    /// and clean session, an example of a specific one below.
    final connMess = MqttConnectMessage()
        .withClientIdentifier(identifier)
        .withWillTopic('willtopic') // If you set this you must set a will message
        .withWillMessage('My Will message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);

    client.connectionMessage = connMess;
    client.keepAlivePeriod = keepalive;

    /// Connect the client, any errors here are communicated by raising of the appropriate exception. Note
    /// in some circumstances the source will just disconnect us, see the spec about this, we however will
    /// never send malformed messages.
    try
    {
      await client.connect();
    }
    on Exception catch(e)
    {
      Log().debug('MQTT:: Error Connecting to $url on port ${client.port}. Status is $e');
      client.disconnect();
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected)
    {
      Log().debug('MQTT:: Client Connected');
    }
    else
    {
      Log().debug('MQTT:: Error Connecting to $url on port ${client.port}. Status is ${client.connectionStatus}');
      client.disconnect();
      return false;
    }

    return true;
  }

  void _onConnected()
  {
    Log().debug('MQTT:: OnConnected');

    // Set Connected
    connected = true;

    // Listen for Messages
    client.updates?.listen(_onData, onDone: _onDone, onError: _onError);

    // notify listener
    listener.onConnected();
  }

  /// The client has a change notifier object(see the Observable class) which we then listen to to get
  /// notifications of published updates to each subscribed topic.
  void _onData (List<MqttReceivedMessage<MqttMessage>> messages)
  {
    messages.forEach((msg)
    {
      final MqttPublishMessage recMess = msg.payload as MqttPublishMessage;
      final message = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      Log().debug('MQTT -> Message received for topic [${msg.topic}] Message[$message]');

      /// notify listener
      listener.onMessage(Payload(topic: msg.topic, message: message));
    });
  }

  void _onDone()
  {
    Log().debug('MQTT -> Done');
  }

  void _onError(error)
  {
    Log().debug('MQTT -> Error');
  }

  Future<bool> disconnect() async
  {
    Log().debug('MQTT:: Disconnecting');
    client.subscriptionsManager?.subscriptions.forEach((key, subscription) => client.unsubscribe(key));
    client.disconnect();
    return true;
  }

  void _onDisconnected()
  {
    connected = false;

    if (client.connectionStatus!.disconnectionOrigin == MqttDisconnectionOrigin.solicited)
         Log().debug('MQTT:: Disconnected (Solicited)');
    else Log().debug('MQTT:: Disconnected');

    // notify listener
    listener.onDisconnected();
  }

  Future<bool> subscribe(String topic) async
  {
    Log().debug('MQTT:: Subscribing to topic -> $topic');
    client.subscribe(topic, MqttQos.atMostOnce);
    return true;
  }

  void _onSubscribed(String topic)
  {
    Log().debug('MQTT:: Subscribed to topic -> $topic');

    // notify listener
    listener.onSubscribed(topic);
  }

  Future<bool> unsubscribe(String topic) async
  {
    Log().debug('MQTT:: Unsubscribing from topic -> $topic');
    client.unsubscribe(topic);
    return true;
  }

  void _onUnSubscribed(String? topic)
  {
    Log().debug('MQTT:: Unsubscribed from topic -> $topic');

    // notify listener
    if (topic != null) listener.onUnsubscribed(topic);
  }

  Future<bool> publish(String topic, String msg) async
  {
    // connected
    if (!connected) return false;

    /// If needed you can listen for published messages that have completed the publishing
    /// handshake which is Qos dependant. Any message received on this stream has completed its
    /// publishing handshake with the source.
    client.published!.listen((MqttPublishMessage message) => Log().debug('MQTT::Published notification:: topic is ${message.variableHeader!.topicName}, with Qos ${message.header!.qos}'));

    final builder = MqttClientPayloadBuilder();
    builder.addString(msg);
    client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);

    return true;
  }

  void _onPublished(MqttPublishMessage message) async
  {
    var topic = message.variableHeader?.topicName;
    var msg   = message.payload.toString();
    Log().debug('MQTT::Published notification:: topic is $topic, with message $msg');

    // notify listener
    if (topic != null) listener.onPublished(topic, msg);
  }


  void _onPong()
  {
    Log().debug('MQTT:: Ping response client callback invoked');
  }

  dispose()
  {
    disconnect();
  }
}
