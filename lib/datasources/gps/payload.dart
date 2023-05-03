// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:xml/xml.dart';

class Payload
{
  final double? accuracy;
  final double? latitude;
  final double? longitude;
  final double? altitude;
  final double? speed;
  final double? speedaccuracy;
  final double? heading;
  final int?    epoch;
  final String? user;
  final String? username;
  Payload({this.accuracy, this.latitude, this.longitude, this.altitude, this.speed, this.speedaccuracy, this.heading, this.epoch, this.user, this.username});

  serialize(XmlElement node)
  {
    if (accuracy  != null) node.attributes.add(XmlAttribute(XmlName('accuracy'),    accuracy.toString()));
    if (latitude  != null) node.attributes.add(XmlAttribute(XmlName('latitude'),    latitude.toString()));
    if (longitude != null) node.attributes.add(XmlAttribute(XmlName('longitude'),   longitude.toString()));
    if (altitude  != null) node.attributes.add(XmlAttribute(XmlName('altitude'),    altitude.toString()));
    if (speed     != null) node.attributes.add(XmlAttribute(XmlName('altitude'),    altitude.toString()));
    if (speedaccuracy  != null) node.attributes.add(XmlAttribute(XmlName('speed'),  speed.toString()));
    if (heading   != null) node.attributes.add(XmlAttribute(XmlName('heading'),     heading.toString()));
    if (epoch     != null) node.attributes.add(XmlAttribute(XmlName('epoch'),       epoch.toString()));
    if (epoch     != null) node.attributes.add(XmlAttribute(XmlName('time'),        DateTime.fromMillisecondsSinceEpoch(epoch!).toLocal().toString()));
    if (user      != null) node.attributes.add(XmlAttribute(XmlName('user'),        user!));
    if (username  != null) node.attributes.add(XmlAttribute(XmlName('username'),    username!));
  }

  Map<String, String> get map
  {
    Map<String, String> _map = <String,String>{};
    _map['accuracy']      = accuracy      != null ? accuracy.toString()      : "0.0";
    _map['latitude']      = latitude      != null ? latitude.toString()      : "0.0";
    _map['longitude']     = longitude     != null ? longitude.toString()     : "0.0";
    _map['altitude']      = altitude      != null ? altitude.toString()      : "0.0";
    _map['speed']         = speed         != null ? speed.toString()         : "0.0";
    _map['speedaccuracy'] = speedaccuracy != null ? speedaccuracy.toString() : "0.0";
    _map['heading']       = heading       != null ? heading.toString()       : "0.0";
    _map['epoch']         = epoch         != null ? epoch.toString()         : "0";
    _map['time']          = epoch         != null ? DateTime.fromMillisecondsSinceEpoch(epoch!).toLocal().toString() : "";
    _map['user']          = user          != null ? user.toString()          : "";
    _map['epoch']         = username      != null ? username.toString()      : "";
    return _map;
  }
}