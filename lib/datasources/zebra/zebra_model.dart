// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/foundation.dart';
import 'package:fml/datasources/base/model.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/helpers/xml.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/observable/observables/boolean.dart';
import 'package:fml/observable/observables/string.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/datasources/detectors/barcode/barcode_detector.dart' as barcode_detector;
import 'package:fml/datasources/detectors/rfid/rfid_detector.dart' as rfid_detector;
import 'package:xml/xml.dart';
import 'package:zebra123/zebra123.dart';

class ZebraModel extends DataSourceModel implements IDataSource {

  // holds the reader instance
  Zebra123? reader;

  /// If the zebra device is connected
  BooleanObservable? _connected;
  set connected(dynamic v) {
    if (_connected != null) {
      _connected!.set(v);
    } else if (v != null) {
      _connected = BooleanObservable(Binding.toKey(id, 'connected'), v, scope: scope);
    }
  }
  bool get connected => _connected?.get() ?? false;

  /// If the zebra device is connected
  StringObservable? _method;
  set method(dynamic v) {
    if (_method != null) {
      _method!.set(v);
    } else if (v != null) {
      _method = StringObservable(Binding.toKey(id, 'method'), v, scope: scope);
    }
  }
  String get method => _method?.get() ?? "either";

  // disable datasource by default when not top of stack
  // override by setting background="true"
  @override
  bool get enabledInBackground => false;

  @override
  bool get autoexecute => super.autoexecute ?? true;

  ZebraModel(super.parent, super.id) {
    connected = false;
  }

  static ZebraModel? fromXml(Model parent, XmlElement xml) {
    ZebraModel? model;
    try {
      model = ZebraModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'zebra.Model');
      model = null;
    }
    return model;
  }

  @override
  Future<bool> start({bool refresh = false, String? key}) async {

    // connect via the sdk
    reader ??= Zebra123(callback: onZebraData);
    reader!.connect();
    return false;
  }

  void onZebraData(ZebraInterfaces interface, ZebraEvents event, dynamic data) {

    if (!enabled) return;
    
    switch (event) {

      case ZebraEvents.readBarcode:
        if (data is List<Barcode>) {
          var payload = barcode_detector.Payload();
          for (Barcode barcode in data) {
            if (kDebugMode) print("Source: $interface Barcode: ${barcode.barcode} Format: ${barcode.format} Date: ${barcode.seen}");
            var bc = barcode_detector.Barcode();
            bc.source = fromEnum(interface);
            bc.barcode = barcode.barcode;
            bc.display = barcode.barcode;
            bc.format = barcode.format;
            bc.seen = barcode.seen;
            payload.barcodes.add(bc);
          }
          onSuccess(barcode_detector.Payload.toData(payload));
        }
        break;

      case ZebraEvents.readRfid:
        if (data is List<RfidTag>) {
          var payload = rfid_detector.Payload();
          for (RfidTag tag in data) {
<<<<<<< HEAD
            if (kDebugMode) print("Source: $interface Tag: ${tag.epc} Rssi: ${tag.rssi}");
=======
            if (kDebugMode) print("Source: $interface Epc: ${tag.epc} Rssi: ${tag.rssi}");
>>>>>>> icons-datasource
            var tg = rfid_detector.Tag();
            tg.source = fromEnum(interface);
            tg.id = tag.epc;
            tg.antenna = tag.antenna;
            tg.rssi = tag.rssi;
            tg.distance = tag.distance;
            tg.size = tag.size;
            tg.memoryBankData = tag.memoryBankData;
            tg.lockData = tag.lockData;
            tg.seen = tag.seen;
            payload.tags.add(tg);
          }
          onSuccess(rfid_detector.Payload.toData(payload));
        }
        break;

      case ZebraEvents.error:
        if (data is Error) {
          if (kDebugMode) print("Source: $interface Error: ${data.message}");
        }
        break;

      case ZebraEvents.connectionStatus:
        if (data is ConnectionStatus) {
          if (kDebugMode) print("Source: $interface ConnectionStatus: ${data.status}");
          connected = data.status == ZebraConnectionStatus.connected;
        }
        break;

      default:
        if (kDebugMode) {
          if (kDebugMode) print("Source: $interface Unknown Event: $event");
        }
    }
  }

  @override
  void dispose() {
    reader?.disconnect();
    reader = null;
    super.dispose();
  }
}
