// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/foundation.dart';
import 'package:fml/datasources/base/model.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/helpers/string.dart';
import 'package:fml/helpers/xml.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/observable/observable.dart';
import 'package:fml/observable/observables/boolean.dart';
import 'package:fml/observable/observables/string.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/datasources/detectors/barcode/barcode_detector.dart' as barcode_detector;
import 'package:fml/datasources/detectors/rfid/rfid_detector.dart' as rfid_detector;
import 'package:xml/xml.dart';
import 'package:zebra123/zebra123.dart';

enum ScanMode { scanning, tracking }

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

  /// If the zebra device is scanning
  late final BooleanObservable _scanning;
  bool get scanning => _scanning.get() ?? false;

  /// If the zebra device is scanning
  late final BooleanObservable _tracking;
  bool get tracking => _tracking.get() ?? false;

  // disable datasource by default when not top of stack
  // override by setting background="true"
  @override
  bool get enabledInBackground => false;

  @override
  bool get autoexecute => super.autoexecute ?? true;

  // busy - override since busy is controlled by the zebra device and not ondata success
  late final BooleanObservable _busy;
  @override
  set busy(dynamic v) {}
  @override
  bool get busy => _busy.get() ?? false;

  // mode
  StringObservable? _mode;
  set mode(dynamic v) {
    if (_mode != null) {
      _mode!.set(v);
    } else if (v != null) {
      _mode = StringObservable(Binding.toKey(id, 'mode'), v,
          scope: scope, listener: _setMode);
    }
  }
  String? get mode => _mode?.get();
  
  // change reader mode
  _setMode(Observable observable) async {
    var mode = toEnum(this.mode, Modes.values);
    if (reader != null && mode != null) {
      // in most cases we would want to change the mode of the
      // physical device itself, bt since we can have multiple zebra datasources
      // listening to the same physical device, we must keep t as mixed mode.
      // reader!.setMode(mode);
    }
  }

  ZebraModel(super.parent, super.id) {
    connected = reader?.connectionStatus == Status.connected;
    _scanning = BooleanObservable(Binding.toKey(id, 'scanning'), false, scope: scope, listener: onPropertyChange);
    _tracking = BooleanObservable(Binding.toKey(id, 'tracking'), false, scope: scope, listener: onPropertyChange);
    _busy     = BooleanObservable(Binding.toKey(id, 'busy'),     false, scope: scope, listener: onPropertyChange);
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

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {
    // deserialize
    super.deserialize(xml);

    // properties
    mode = Xml.get(node: xml, tag: 'mode');
  }

  @override
  Future<bool> start() async {

    // connect via the sdk
    if (reader == null) {
      reader = Zebra123(callback: onZebraEvent);
      if (_mode != null) _setMode(_mode!);
    }
    reader!.connect();
    connected = reader!.connectionStatus == Status.connected;
    return true;
  }

  @override
  Future<bool> stop() async {
    reader?.disconnect();
    return true;
  }

  void _stopScan() {
    if (reader == null) return;
    if (tracking) {
      _tracking.set(false);
      reader?.stopTracking();
    }
    if (scanning) {
      reader?.stopScanning();
      _scanning.set(false);
    }
    connected = reader!.connectionStatus == Status.connected;
  }

  @override
  Future<dynamic> execute(
      String caller,
      String propertyOrFunction,
      List<dynamic> arguments) async {

    /// setter
    if (scope == null) return null;
    String function = propertyOrFunction.toLowerCase().trim();

    switch (function) {

      // start scanning
      case "start":

        if (reader == null) return false;
        _stopScan();

        // get the scan mode
        var mode = toEnum(elementAt(arguments, 0), ScanMode.values) ?? ScanMode.scanning;
        if (arguments.length < 2) mode = ScanMode.scanning;

        switch (mode) {

          // scanning
          case ScanMode.scanning:
            _scanning.set(true);
            reader!.startScanning();
            break;

          // tracking
          case ScanMode.tracking:
            var tags = (toStr(elementAt(arguments, 1)) ?? "").split(",");
            _tracking.set(true);
            reader!.startTracking(tags);
            break;
        }
        return true;

      // start scanning
      case "scan":

        if (reader == null) return false;
        _stopScan();

        _scanning.set(true);
        reader!.startScanning();
        return true;

      // start tracking
      case "track":

        if (tracking) break;
        _stopScan();

        var tags = (toStr(elementAt(arguments, 0)) ?? "").split(",");
        _tracking.set(true);
        reader!.startTracking(tags);
        return true;

      // stop scanning or tracking
      case "stop":
        _stopScan();
        return true;

      case "write":
        if (reader == null) return;
        _stopScan();

        String? epc = toStr(elementAt(arguments, 0)) ?? "";
        if (isNullOrEmpty(epc)) return false;
        reader?.writeTag(epc,
            epcNew: toStr(elementAt(arguments, 1)),
            password: toDouble(elementAt(arguments, 2)),
            passwordNew: toDouble(elementAt(arguments, 3)),
            data: toStr(elementAt(arguments, 4)),
        );
        return true;

      case "connect":
        return await start();

      case "disconnect":
        return await stop();
    }

    return super.execute(caller, propertyOrFunction, arguments);
  }


  String _setBarcodeFormat(String? format) {

    if (format == null) return fromEnum(barcode_detector.BarcodeFormats.unknown) ?? "unknown";

    format = format.toLowerCase();
    format = format.replaceFirst("label-type-","");

    return fromEnum(toEnum(format, barcode_detector.BarcodeFormats.values)) ?? format;
  }

  void onZebraEvent(Interfaces interface, Events event, dynamic data) {

    if (!enabled) return;
    var mode = toEnum(this.mode, Modes.values) ?? Modes.mixed;

    switch (event) {

      case Events.readBarcode:
        if (data is List<Barcode>) {
          var payload = barcode_detector.Payload();
          for (Barcode barcode in data) {

            if (kDebugMode) print("Source: $interface Barcode: ${barcode.barcode} Format: ${barcode.format} Date: ${barcode.seen}");
            var bc = barcode_detector.Barcode();

            bc.source = fromEnum(interface);
            bc.barcode = barcode.barcode;
            bc.display = barcode.barcode;
            bc.format  = _setBarcodeFormat(barcode.format);
            bc.seen    = barcode.seen;

            payload.barcodes.add(bc);
          }

          // only return success if barcode or mixed mode
          if (mode == Modes.barcode || mode == Modes.mixed) {
            onSuccess(barcode_detector.Payload.toData(payload));
          }
        }
        break;

      case Events.readRfid:
        if (data is List<RfidTag>) {
          var payload = rfid_detector.Payload();
          for (RfidTag tag in data) {
            if (kDebugMode) print("Source: $interface Tag: ${tag.epc} Rssi: ${tag.rssi}");
            var tg = rfid_detector.Tag();
            tg.source = fromEnum(interface);
            tg.epc = tag.epc;
            tg.antenna = tag.antenna;
            tg.rssi = tag.rssi;
            tg.distance = tag.distance;
            tg.size = tag.size;
            tg.memoryBankData = tag.memoryBankData;
            tg.lockData = tag.lockData;
            tg.seen = tag.seen;
            payload.tags.add(tg);
          }

          // order tags by rssi
          payload.tags.sort((a, b) => (b.rssi ?? 0).compareTo((a.rssi ?? 0)));

          // only return success if rfid or mixed mode
          if (mode == Modes.rfid || mode == Modes.mixed) {
            onSuccess(rfid_detector.Payload.toData(payload));
          }
        }
        break;

      case Events.startRead:
        if (kDebugMode) print("Source: $interface StartRead");
        _busy.set(true);
        break;

      case Events.stopRead:
        if (kDebugMode) print("Source: $interface StopRead");
        _busy.set(false);
        break;

      case Events.error:
        if (data is Error) {
          if (kDebugMode) print("Source: $interface Error: ${data.message}");
        }
        break;

      case Events.connectionStatus:
        if (data is ConnectionStatus) {
          if (kDebugMode) print("Source: $interface ConnectionStatus: ${data.status}");
          connected = data.status == Status.connected;
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
    _stopScan();
    reader?.disconnect();
    reader = null;
    super.dispose();
  }
}
