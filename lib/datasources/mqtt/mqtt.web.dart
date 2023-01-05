// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';

import 'package:fml/system.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:uuid/uuid.dart';
import 'iMqttListener.dart';
import 'payload.dart';
import 'iMqtt.dart';
import 'package:fml/helper/helper_barrel.dart';

IMqtt? getMqtt(String url, IMqttListener listener) => MqttWeb(url, listener);

class MqttWeb implements IMqtt
{
  late String url;
  late String scheme;
  late String server;
  late int    port;
  int  keepalive = 60;
  bool connected = false;

  String identifier = (System().userProperty('name') ?? 'unknown') + " : " + Uuid().v1();
  late MqttBrowserClient client;

  IMqttListener listener;
  bool stop = false;

  MqttWeb(String url, this.listener)
  {
    Uri? uri = S.toURI(url);
    if (uri == null) return;
    this.scheme = 'ws';
    this.server = uri.host;
    this.port   = url.contains(":") ? uri.port : 61614;
    this.url    = scheme + '://' + server;

    Log().debug('MQTT:: Domain - $url');

    /// Create Client
    client = MqttBrowserClient(this.url, identifier);

    /// Set logging on if needed, defaults to off
    client.logging(on: false);

    /// If you intend to use a keep alive value in your connect message that is not the default(60s)
    /// you must set it here
    client.keepAlivePeriod = keepalive;

    client.port = port;

    /// Add the unsolicited disconnection callback
    client.onDisconnected = onDisconnected;

    /// Add the successful connection callback
    client.onConnected = onConnected;

    /// Add a subscribed callback, there is also an unsubscribed callback if you need it.
    /// You can add these before connection or change them dynamically after connection if
    /// you wish. There is also an onSubscribeFail callback for failed subscriptions, these
    /// can fail either because you have tried to subscribe to an invalid topic or the source
    /// rejects the subscribe request.
    client.onSubscribed   = onSubscribed;
    client.onUnsubscribed = onUnSubscribed;

    /// Set a ping received callback if needed, called whenever a ping response(pong) is received
    /// from the source.
    client.pongCallback = pong;
  }

  Future<bool> connect() async
  {
    Log().debug('MQTT:: Connecting to $url on port $port');

    /// Create a connection message to use or use the default one. The default one sets the
    /// client identifier, any supplied username/password, the default keepalive interval(60s)
    /// and clean session, an example of a specific one below.
    final connMess = MqttConnectMessage()
        .withClientIdentifier(identifier)
        .withWillTopic('willtopic') // If you set this you must set a will message
        .withWillMessage('My Will message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atMostOnce);

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
      Log().debug('MQTT:: Error Connecting to $url on port $port. Status is $e');
      client.disconnect();
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected)
    {
      Log().debug('MQTT:: Client Connected');
    }
    else
    {
      Log().debug('MQTT:: Error Connecting to $url on port $port. Status is ${client.connectionStatus}');
      client.disconnect();
      return false;
    }

    return true;
  }

  void onConnected()
  {
    Log().debug('MQTT:: OnConnected');

    // Set Connected
    connected = true;

    /// Notify that messages have been published
    client.published?.listen((MqttPublishMessage message) => Log().debug('MQTT::Published notification:: topic is ${message.variableHeader?.topicName}, with message ${message.payload.toString()}with Qos ${message.header?.qos}'));

    /// Listen for Messages
    client.updates?.listen(onData, onDone: onDone, onError: onError);
  }

  /// The client has a change notifier object(see the Observable class) which we then listen to to get
  /// notifications of published updates to each subscribed topic.
  void onData (List messages)
  {
    Log().debug('MQTT -> Messages received');
    messages.forEach((msg)
    {
      final MqttPublishMessage recMess = msg.payload as MqttPublishMessage;
      final pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      Log().debug('MQTT -> Message received for topic [${msg.topic}] Message[$pt]');

      /// notify listener
      listener.onMqttData(payload: Payload(topic: msg.topic, payload: pt));
    });
  }

  void onDone()
  {
    Log().debug('MQTT -> Done');
  }

  void onError(error)
  {
    Log().debug('MQTT -> Error');
  }

  Future<bool> disconnect() async
  {
    Log().debug('MQTT:: Disconnecting');
    client.disconnect();
    return true;
  }

  void onDisconnected()
  {
    if (client.connectionStatus!.disconnectionOrigin == MqttDisconnectionOrigin.solicited)
    {
      Log().debug('MQTT:: Disconnected (Solicited)');
    }
    else
    {
      Log().debug('MQTT:: Disconnected (Unsolicited)');
    }
  }

  Future<bool> subscribe(String? topic) async
  {
    if (topic != null)
    {
      Log().debug('MQTT:: Subscribing to topic -> $topic');
      if (topic != null) client.subscribe(topic, MqttQos.atMostOnce);
    }
    return true;
  }

  void onSubscribed(String topic)
  {
    Log().debug('MQTT:: Subscribed to topic -> $topic');
  }

  Future<bool> unsubsribe(String topic) async
  {
    Log().debug('MQTT:: Unsubscribing from topic -> $topic');
    client.subscriptionsManager?.subscriptions.forEach((key, value) => client.unsubscribe(key));
    return true;
  }

  void onUnSubscribed(String? topic)
  {
    Log().debug('MQTT:: Unsubscribed from topic -> $topic');
  }

  void sleep(int seconds) async
  {
    await MqttUtilities.asyncSleep(seconds);
  }

  Future<bool> publish(String topic, String msg) async
  {
    // connected?
    if (!connected) return false;

    final builder = MqttClientPayloadBuilder();
    builder.addString(msg);
    if (builder.payload != null) client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);

    return true;
  }

  void pong()
  {
    Log().debug('MQTT:: Ping response client callback invoked');
  }

  dispose()
  {
    unsubsribe(topic!);
    disconnect();
  }
}
