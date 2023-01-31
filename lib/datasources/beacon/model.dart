// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
// import 'package:fml/data/data.dart';
// import 'package:fml/datasources/base/checkbox_model.dart' as BASE;
// import 'package:fml/datasources/iDataSource.dart';
// import 'package:fml/helperrr/string.dart';
// import 'package:fml/helperrr/xml.dart';
// import 'package:fml/log/checkbox_model.dart';
// 
// import 'package:fml/widgets/widget/checkbox_model.dart'  ;
// import 'package:xml/xml.dart';
// import 'beacon.dart';

// class Model extends BASE.Model implements iDataSource, iBeaconListener
// {
//   final String elementType = "beacon);

//   Model(WidgetModel parent, String id) : super(parent, id)
//   {
//   }

//   static Model? fromXml(WidgetModel parent, XmlElement xml)
//   {
//     Model model;
//     try
//     {
//       model = Model(parent, Xml.get(node: xml, tag: 'id'));
//       model.deserialize(xml);
//     }
//     catch(e)
//     {
//       Log().exception(e, template: model.templateName, object: 'iframe.Model');
//       model = null;
//     }
//     return model;
//   }

//   /// Deserializes the FML template elements, attributes and children
//   @override
//   void deserialize(XmlElement xml)
//   {
//     if (xml == null) return;

//     // deserialize
//     super.deserialize(xml);

//     // properties
//   }

//   @override
//   dispose()
//   {
//     Reader().removeListener(this);
//     super.dispose();
//   }

//   @override
//   Future<bool> start({bool refresh = false, String key}) async
//   {
//     bool ok = true;

//     try
//     {
//       Reader().registerListener(this);
//       await Reader().read();
//     }
//     catch (e)
//     {
//       ok = await onException(null, code: 500, message: e.toString());
//     }

//     return ok;
//   }

//   @override
//   Future<bool> stop() async
//   {
//     try
//     {
//       Reader().removeListener(this);
//       super.stop();
//     }
//     catch (e)
//     {
//       await onException(null, code: 500, message: e.toString());
//     }
//     return true;
//   }

//   onBeaconError(String error)
//   {
//     onException(null, code: 500, message: error);
//   }

//   onBeaconData({Payload payload})
//   {
//     // enabled?
//     if (enabled == false) return;

//     // Build the Data
//     Data data = Data();
//     payload.beacons.forEach((beacon)
//     {
//       Map<dynamic, dynamic> map = Map<dynamic, dynamic>();
//       map["type"]  = beacon.type != null ? S.fromEnum(beacon.type) : "";
//       map["epoch"] = beacon.epoch != null ? beacon.epoch.toString() : "";
//       map["age"]   = beacon.ageInMilliseconds != null ? (beacon.ageInMilliseconds / 1000).toStringAsFixed(0) : "";
//       map["date"]  = beacon.dateLastSeen != null ? beacon.dateLastSeen.toString() : "";
//       map["uuid"]  = beacon.id != null ? beacon.id.toString() : "";
//       map["uuid"]  = beacon.id != null ? beacon.id.toString() : "";
//       map["name"]  = beacon.name != null ? beacon.name.toString() : "";
//       map["rssi"]  = beacon.rssi != null ? beacon.rssi.toString() : "";
//       map["power"] = beacon.power != null ? beacon.power.toString() : "";
//       map["minor"] = beacon.minor != null ? beacon.minor.toString() : "";
//       map["major"] = beacon.major != null ? beacon.major.toString() : "";
//       map["distance"] = beacon.distanceInMeters != null ? beacon.distanceInMeters.toStringAsFixed(2) : "";
//       data.add(map);
//     });

//     // Notify
//     onResponse(data);
//   }
// }
