// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:collection';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:fml/data/data.dart';
import 'package:fml/datasources/base/model.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/observable/observables/integer.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/helpers/helpers.dart';
import 'package:xml/xml.dart';
import 'beacon.dart';

class BeaconModel extends DataSourceModel implements IDataSource, IBeaconListener
{
  final HashMap<String, int> firstSeen = HashMap<String, int>();
  final HashMap<String, int> lastSeen  = HashMap<String, int>();

  @override
  bool get autoexecute => super.autoexecute ?? true;

  // minor
  IntegerObservable? _minor;
  set minor(dynamic v) 
  {
    if (_minor != null) 
    {
      _minor!.set(v);
    } 
    else if (v != null) 
    {
      _minor = IntegerObservable(Binding.toKey(id, 'minor'), v, scope: scope);
    }
  }
  int? get minor => _minor?.get();

  // major
  IntegerObservable? _major;
  set major(dynamic v)
  {
    if (_major != null)
    {
      _major!.set(v);
    }
    else if (v != null)
    {
      _major = IntegerObservable(Binding.toKey(id, 'major'), v, scope: scope);
    }
  }
  int? get major => _major?.get();

  // distance
  IntegerObservable? _distance;
  set distance(dynamic v)
  {
    if (_distance != null)
    {
      _distance!.set(v);
    }
    else if (v != null)
    {
      _distance = IntegerObservable(Binding.toKey(id, 'distance'), v, scope: scope);
    }
  }
  int? get distance => _distance?.get();
  
  BeaconModel(WidgetModel parent, String? id) : super(parent, id);

  static BeaconModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    BeaconModel? model;
    try
    {
      model = BeaconModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e, caller: 'beacon.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {
    // deserialize
    super.deserialize(xml);

    // properties
    major    = Xml.get(node: xml, tag: 'major');
    minor    = Xml.get(node: xml, tag: 'minor');
    distance = toInt(Xml.get(node: xml, tag: 'distance'));
  }

  @override
  void dispose()
  {
    Reader().removeListener(this);
    super.dispose();
  }

  @override
  Future<bool> start({bool refresh = false, String? key}) async
  {
    bool ok = true;
    try
    {
      Reader().registerListener(this);
    }
    catch(e)
    {
      ok = await onFail(Data(), code: 500, message: e.toString());
    }
    return ok;
  }

  @override
  Future<bool> stop() async
  {
    try
    {
      Reader().removeListener(this);
      super.stop();
    }
    catch(e)
    {
      await onFail(Data(), code: 500, message: e.toString());
    }
    return true;
  }

  int _beaconsFound = 0;

  void _removeExpired()
  {
    if (firstSeen.isEmpty && lastSeen.isEmpty) return;

    // remove any items that haven't been seen in the past 15 seconds
    List<String> expired = [];
    for (var e in lastSeen.entries) {
      if (DateTime.now().millisecondsSinceEpoch - e.value > (1000 * 15)) {
        expired.add(e.key);
      }
    }
    if (expired.isNotEmpty)
    {
      firstSeen.removeWhere((key, value) => expired.contains(key));
      lastSeen.removeWhere((key, value)  => expired.contains(key));
    }
  }
  @override
  onBeaconData(List<Beacon> beacons)
  {
    // enabled?
    if (enabled == false) return;

    // if no beacons found on last
    // iteration and none in this,
    // just quit
    if (_beaconsFound == 0 && beacons.isEmpty) return _removeExpired();

    // rember last count of beacons found
    _beaconsFound = beacons.length;

    Log().debug('BEACON Scanner -> Found ${beacons.length} beacons');

    // remove beacons that dont match our criteria
    if (major != null || minor != null || distance != null) {
      beacons.removeWhere((element)
    {
      if (major    != null && element.major != major) return true;
      if (minor    != null && element.minor != minor) return true;
      if (distance != null && element.accuracy > distance!) return true;
      return false;
    });
    }

    // sort by distance
    if (beacons.length > 1) {
      beacons.sort((a, b) => Comparable.compare(a.accuracy, b.accuracy));
    }

    Log().debug('BEACON Scanner -> ${beacons.length} beacons matching your criteria');

    // Build the Data
    Data data = Data();
    for (var beacon in beacons) {
      // calculate age
      int age = 0;
      if (beacon.macAddress != null)
      {
        var dt = DateTime.now().millisecondsSinceEpoch;
        if (!firstSeen.keys.contains(beacon.macAddress!)) firstSeen[beacon.macAddress!] = dt;
        lastSeen[beacon.macAddress!] = dt;
        age = lastSeen[beacon.macAddress!]! - firstSeen[beacon.macAddress!]!;
      }

      Map<dynamic, dynamic> map = <dynamic, dynamic>{};
      map["id"]         = beacon.proximityUUID;
      map["epoch"]      = "${DateTime.now().millisecondsSinceEpoch}";
      map["age"]        = "$age";
      map["macaddress"] = beacon.macAddress;
      map["rssi"]       = "${beacon.rssi}";
      map["power"]      = "${beacon.txPower ?? 0.0}";
      map["minor"]      = "${beacon.minor}";
      map["major"]      = "${beacon.major}";
      map["distance"]   = "${beacon.accuracy}";
      map["proximity"]  = "${beacon.proximity}";
      data.add(map);
    }

    // remove any items that haven't been seen in the past 15 seconds
    _removeExpired();

    // Notify
    onSuccess(data);
  }
}
