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

IMqtt? getMqtt(String? url, {IMqttListener? listener}) => MqttMobile(url, listener: listener);

class MqttMobile implements IMqtt
{
  String? url;
  late String scheme;
  String? server;
  int?    port;
  String? topic;
  String id    = '';
  String identifier = (System().setUserProperty('name') ?? 'unknown') + " : " + Uuid().v1();
  int    keepalive = 60;
  bool?   connected;
  List<String?> pending = [];

  late MqttServerClient client;

  List<IMqttListener>? _listeners;
  bool stop = false;

  MqttMobile(String? url, {IMqttListener? listener})
  {
    if (url == null) return;

    /////////////////////
    /* Convert the URL */
    /////////////////////
    Uri? uri = S.toURI(url);
    if (uri == null) return;
    this.scheme = uri.scheme;
    this.server = uri.host;
    this.port   = (uri.port <= 0) ? 1883 : uri.port;
    this.topic  = uri.path;
    if (topic != null) topic = topic!.substring(1);
    this.url = scheme + '://' + server!;
    if (scheme.toLowerCase().startsWith('mqtt')) this.url = server;

    ///////////////////
    /* Create Client */
    ///////////////////
    client = MqttServerClient(this.url!, id);

    /// Set logging on if needed, defaults to off
    client.logging(on: false);

    /// If you intend to use a keep alive value in your connect message that is not the default(60s)
    /// you must set it here
    client.keepAlivePeriod = keepalive;

    /// The ws port for Mosquitto is 8080, for wss it is 8081
    client.port = port;

    /// Add the unsolicited disconnection callback
    client.onDisconnected = onDisconnected;

    /// Add the successful connection callback
    client.onConnected = onConnected;

    client.useWebSocket = (scheme.toLowerCase().startsWith('ws'));

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

    ///////////////////////
    /* Register Listener */
    ///////////////////////
    if (listener != null) registerListener(listener);

    ////////////////
    /* Initialize */
    ////////////////
    _initialize();
  }

  Future<bool> _initialize() async
  {
    bool ok = true;
    if (ok) ok = await connect();
    if (ok) ok = await subscribe(topic!);
    return ok;
  }

  /// The client has a change notifier object(see the Observable class) which we then listen to to get
  /// notifications of published updates to each subscribed topic.
  void onMessage (List<MqttReceivedMessage<MqttMessage>> messages)
  {
    messages.forEach((msg)
    {
      final MqttPublishMessage recMess = msg.payload as MqttPublishMessage;
      final pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      Log().debug('MQTT -> Message received for topic [${msg.topic}] Message[$pt]');

      Payload data = Payload(topic: msg.topic, payload: pt);
      notifyListeners(data);
    });
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

    ///////////////////
    /* Set Connected */
    ///////////////////
    connected = true;

    /////////////////////////
    /* Listen for Messages */
    /////////////////////////
    client.updates!.listen((msg) => onMessage(msg));

    //////////////////////////////
    /* Publish Penning Messages */
    //////////////////////////////
    publish();
  }

  Future<bool> disconnect() async
  {
    Log().debug('MQTT:: Disconnecting');
    client.disconnect();
    return true;
  }

  void onDisconnected()
  {
    connected = false;
    if (client.connectionStatus!.disconnectionOrigin == MqttDisconnectionOrigin.solicited)
    {
      Log().debug('MQTT:: Disconnected (Solicited)');
    }
    else
    {
      Log().debug('MQTT:: Disconnected (Unsolicited)');
    }
  }

  Future<bool> subscribe(String topic) async
  {
    Log().debug('MQTT:: Subscribing to topic -> $topic');
    client.subscribe(topic, MqttQos.atMostOnce);
    return true;
  }

  void onSubscribed(String topic)
  {
    Log().debug('MQTT:: Subscribed to topic -> $topic');
  }

  Future<bool> unsubsribe(String topic) async
  {
    Log().debug('MQTT:: Unsubscribing from topic -> $topic');
    client.unsubscribe(topic);
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

  Future<bool> publish({String? msg}) async
  {
    if (!S.isNullOrEmpty(msg)) pending.add(msg);

    ////////////////
    /* Connected? */
    ////////////////
    if (connected != true) return true;

    //////////////////////
    /* Process Messages */
    //////////////////////
    pending.forEach((msg)
    {
      /// If needed you can listen for published messages that have completed the publishing
      /// handshake which is Qos dependant. Any message received on this stream has completed its
      /// publishing handshake with the source.
      client.published!.listen((MqttPublishMessage message) => Log().debug('MQTT::Published notification:: topic is ${message.variableHeader!.topicName}, with Qos ${message.header!.qos}'));

      final builder = MqttClientPayloadBuilder();
      builder.addString(msg!);
      client.publishMessage(topic!, MqttQos.exactlyOnce, builder.payload!);
    });

    ///////////////////
    /* Clear Pending */
    ///////////////////
    pending.clear();

    return true;
  }

  void pong()
  {
    Log().debug('MQTT:: Ping response client callback invoked');
  }

  registerListener(IMqttListener listener)
  {
    if (_listeners == null) _listeners = [];
    if (!_listeners!.contains(listener)) _listeners!.add(listener);
  }

  removeListener(IMqttListener listener)
  {
    if ((_listeners != null) && (_listeners!.contains(listener)))
    {
      _listeners!.remove(listener);
      if (_listeners!.isEmpty) _listeners = null;
    }
  }

  notifyListeners(Payload data)
  {
    if (_listeners != null) _listeners!.forEach((listener) => listener.onMqttData(payload: data));
  }

  dispose()
  {
    unsubsribe(topic!);
    disconnect();
  }
}
