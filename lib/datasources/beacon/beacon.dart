// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
// import 'dart:math';

// import 'package:fml/helperrr/string.dart';
// import 'package:flutter_blue/flutter_blue.dart';

// import 'package:convert/convert.dart';
// import 'package:flutter/foundation.dart';
// export 'package:flutter_blue/flutter_blue.dart' show ScanResult;

// const EddystoneServiceId = "0000feaa-0000-1000-8000-00805f9b34fb";
// const IBeaconManufacturerId = 0x004C;

// enum types {eddystone, ibeacon}

// abstract class Beacon
// {
//   final  types   type;
//   final  int     epoch;
//   final  String  id;
//   final  String  name;
//   final  int     power;
//   final  int     rssi;
//   final  int     minor;
//   final  int     major;

//   int    get txAt1Meter => power;

//   double get distanceInMeters
//   {
//     double ratio = rssi * 1.0 / (txAt1Meter);
//     if (ratio < 1.0)
//          return pow(ratio, 10);
//     else return (0.89976) * pow(ratio, 7.7095) + 0.111;
//   }

//   int get ageInMilliseconds
//   {
//      if (epoch == null) return null;
//      return  (DateTime.now().millisecondsSinceEpoch - epoch);
//   }

//   DateTime get dateLastSeen
//   {
//     if (epoch == null) return null;
//     return  DateTime.fromMillisecondsSinceEpoch(epoch);
//   }

//   Beacon({this.type, this.epoch, this.id, this.name, this.power, this.rssi, this.major, this.minor});

//   static List<Beacon> fromScanResult(ScanResult scanResult)
//   {
//     return <Beacon>[EddystoneUID.fromScanResult(scanResult), EddystoneEID.fromScanResult(scanResult), IBeacon.fromScanResult(scanResult)].where((b) => b != null).toList();
//   }
// }

// abstract class Eddystone extends Beacon
// {
//   Eddystone({@required this.frameType, @required String id, @required int tx, @required ScanResult scanResult}) : super(type: types.eddystone, epoch: DateTime.now().millisecondsSinceEpoch, id: id, name: scanResult.device.name, power: tx, rssi: scanResult.rssi);

//   final int frameType;

//   @override
//   int get txAt1Meter => power - 41;
// }

// class EddystoneUID extends Eddystone
// {
//   final String namespaceId;
//   final String beaconId;

//   EddystoneUID({@required int frameType, @required this.namespaceId, @required this.beaconId, @required int tx, @required ScanResult scanResult}) : super(id: beaconId, tx: tx, scanResult: scanResult, frameType: frameType);

//   static EddystoneUID.fromScanResult(ScanResult scanResult)
//   {
//     if (!scanResult.advertisementData.serviceData.containsKey(EddystoneServiceId))
//     {
//       return null;
//     }
//     if (scanResult.advertisementData.serviceData[EddystoneServiceId].length < 18)
//     {
//       return null;
//     }
//     if (scanResult.advertisementData.serviceData[EddystoneServiceId][0] != 0x00)
//     {
//       return null;
//     }

//     List<int> rawBytes = scanResult.advertisementData.serviceData[EddystoneServiceId];
//     var frameType = rawBytes[0];
//     var tx = S.byteToInt8(rawBytes[1]);
//     var namespaceId = S.byteListToHexString(rawBytes.sublist(2, 12));
//     var beaconId = S.byteListToHexString(rawBytes.sublist(12, 18));
//     return EddystoneUID(frameType: frameType, namespaceId: namespaceId, beaconId: beaconId, tx: tx, scanResult: scanResult);
//   }
// }

// class EddystoneEID extends Eddystone
// {
//   final String ephemeralId;

//   EddystoneEID({@required int frameType, @required this.ephemeralId, @required int tx, @required ScanResult scanResult}) : super(id: ephemeralId, tx: tx, scanResult: scanResult, frameType: frameType);

//   static EddystoneEID.fromScanResult(ScanResult scanResult)
//   {
//     if (!scanResult.advertisementData.serviceData.containsKey(EddystoneServiceId))
//     {
//       return null;
//     }
//     if (scanResult.advertisementData.serviceData[EddystoneServiceId].length < 10)
//     {
//       return null;
//     }
//     if (scanResult.advertisementData.serviceData[EddystoneServiceId][0] != 0x30)
//     {
//       return null;
//     }
//     List<int> rawBytes = scanResult.advertisementData.serviceData[EddystoneServiceId];
//     var frameType = rawBytes[0];
//     var tx = S.byteToInt8(rawBytes[1]);

//     var ephemeralId = hex.encode(rawBytes).toString().substring(4);
//     return EddystoneEID(frameType: frameType, ephemeralId: ephemeralId, tx: tx, scanResult: scanResult);
//   }
// }

// class IBeacon extends Beacon
// {
//   final String uuid;
//   final int major;
//   final int minor;

//   IBeacon({@required this.uuid, @required this.major, @required this.minor, @required int tx, @required ScanResult scanResult}) : super(type: types.ibeacon, epoch: DateTime.now().millisecondsSinceEpoch, id: uuid, name: scanResult.device.name, power: tx, rssi: scanResult.rssi, major: major, minor: minor);

//   static IBeacon.fromScanResult(ScanResult scanResult)
//   {
//     if (!scanResult.advertisementData.manufacturerData.containsKey(IBeaconManufacturerId))
//     {
//       return null;
//     }

//     if (scanResult.advertisementData.manufacturerData[IBeaconManufacturerId].length < 23)
//     {
//       return null;
//     }

//     if (scanResult.advertisementData.manufacturerData[IBeaconManufacturerId][0] != 0x02 || scanResult.advertisementData.manufacturerData[IBeaconManufacturerId][1] != 0x15)
//     {
//       return null;
//     }

//     List<int> rawBytes = scanResult.advertisementData.manufacturerData[IBeaconManufacturerId];
//     var uuid  = S.byteListToHexString(rawBytes.sublist(2, 18));
//     var major = S.twoByteToInt16(rawBytes[18], rawBytes[19]);
//     var minor = S.twoByteToInt16(rawBytes[20], rawBytes[21]);
//     var tx    = S.byteToInt8(rawBytes[22]);

//     return IBeacon(uuid: uuid, major: major, minor: minor, tx: tx, scanResult: scanResult);
//   }
// }

// class Payload
// {
//   List<Beacon> beacons = [];
//   Payload({this.beacons});
// }

// abstract class iBeaconListener
// {
//   onBeaconData({Payload payload});
//   onBeaconError(String error);
// }

// class Reader
// {
//   static final Reader _singleton = Reader._initialize();
//   static final _detector = FlutterBlue.instance;

//   bool available;
//   bool enabled;

//   List<iBeaconListener> _listeners;

//   factory Reader()
//   {
//     return _singleton;
//   }

//   Reader._initialize()
//   {
//     _initializeScanner();
//   }

//   Map<String,Beacon> _beacons = Map<String,Beacon>();
//   Payload payload = Payload();
//   bool reset = false;

//   //////////
//   /* Read */
//   //////////
//   read()
//   {
//     ////////////////
//     /* Clear List */
//     ////////////////
//     reset = true;

//     //////////////////////
//     /* Notify Listeners */
//     //////////////////////
//     notifyListeners(payload);
//   }

//   _initializeScanner() async
//   {
//     try
//     {
//       available = await _detector.isAvailable;
//       enabled   = await _detector.isOn;
//       if (available)
//       {
//         _detector.isScanning.listen(onScanListener);
//         _detector.scanResults.listen(onResult);
//         if (_listeners != null) _startScan();
//       }
//     }
//     catch(e) {}
//   }

//   void _startScan() async
//   {
//     try
//     {
//       if (available == true) _detector.startScan(timeout: Duration(seconds: 2),allowDuplicates: true);
//     }
//     catch(e) {}
//   }

//   void _stopScan() async
//   {
//     try
//     {
//       if (available == true) _detector.stopScan();
//     }
//     catch(e){}
//   }

//   void onScanListener(bool scanning)
//   {
//     if (!scanning)
//     {
//       //////////////////
//       /* Build Result */
//       //////////////////
//       List<Beacon> list = _beacons.values.toList();

//       /////////////////////////
//       /* Clear Original List */
//       /////////////////////////
//       if (reset)
//       {
//         _beacons.clear();
//         reset = false;
//       }

//       ///////////////////////////
//       /* Sort List by Distance */
//       ///////////////////////////
//       list.sort((a, b) => a.distanceInMeters.compareTo(b.distanceInMeters));

//       ///////////////////
//       /* Build Payload */
//       ///////////////////
//       payload = Payload(beacons: list);

//       //////////////////////
//       /* Notify Listeners */
//       //////////////////////
//       notifyListeners(payload);

//       ////////////
//       /* Rescan */
//       ////////////
//       if (_listeners != null) _startScan();
//     }
//   }

//   onResult(results)
//   {
//     if (results != null)
//     for (ScanResult result in results)
//     {
//       List<Beacon> beacons = Beacon.fromScanResult(result);
//       if (beacons != null)
//       for (Beacon beacon in beacons)
//       {
//         String id = null;
//         if (beacon is IBeacon)   id = beacon.uuid;
//         if (beacon is Eddystone) id = beacon.id;
//         if (!S.isNullOrEmpty(id)) _beacons[id] = beacon;
//       }
//     }
//   }

//   registerListener(iBeaconListener listener) async
//   {
//     if (listener == null) return;
//     if (_listeners == null) _listeners = [];
//     if (!_listeners.contains(listener))
//     {
//       if (available == true)
//       {
//         if (enabled != true)
//         {
//           enabled = await _detector.isOn;
//           if (enabled == false) return notifyListenersOfError("Please enable bluetooth on your device");
//         }
//         _listeners.add(listener);
//         _startScan();
//       }
//       else return notifyListenersOfError("Bluetooth unavailable on this device");
//     }
//   }

//   removeListener(iBeaconListener listener) async
//   {
//     if ((_listeners != null) && (_listeners.contains(listener)))
//     {
//       _listeners.remove(listener);
//       if (_listeners.isEmpty)
//       {
//         _listeners = null;
//         _stopScan();
//       }
//     }
//   }

//   notifyListeners(Payload data)
//   {
//     if ((_listeners != null) && (data != null))
//     {
//       var listeners = _listeners.where((element) => true);
//       listeners.forEach((listener) => listener.onBeaconData(payload: data));
//     }
//   }

//   notifyListenersOfError(String error)
//   {
//     if (_listeners != null)
//     {
//       var listeners = _listeners.where((element) => true);
//       listeners.forEach((listener) => listener.onBeaconError(error));
//     }
//     return false;
//   }
// }