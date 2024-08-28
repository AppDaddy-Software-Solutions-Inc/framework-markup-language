// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/base/model.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/datasources/zebra/zebra_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/observable/observables/boolean.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/datasources/zebra/zebra_wedge.dart' as wedge;
import 'package:fml/datasources/zebra/zebra_sdk.dart' as sdk;
import 'package:fml/datasources/detectors/barcode/barcode_detector.dart' as barcode;
import 'package:fml/datasources/detectors/rfid/rfid_detector.dart' as rfid;
import 'package:xml/xml.dart';
import 'package:fml/helpers/helpers.dart';

class ZebraModel extends DataSourceModel implements IDataSource, IZebraListener {

  // holds the reader instance
  dynamic reader;

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
    // if (reader == null) {
    //   // attempt to connect to the sdk
    //   var reader = sdk.Reader();
    //   await reader.init();
    //   if (reader.status == 200) {
    //     this.reader = reader;
    //     connected = true;
    //   }
    // }

    // connect via the wedge
    if (reader == null) {
      // attempt to connect to the sdk
      var reader = wedge.Reader();
      await reader.initialized.future;
      if (reader.status == 200) {
        this.reader = reader;
        connected = true;
      }
    }

    // register a listener
    if (reader != null) {
      reader.registerListener(this);
      return true;
    }

    return false;
  }

  @override
  void dispose() {
    reader?.removeListener(this);
    super.dispose();
  }

  @override
  Future<bool> stop() async {
    reader?.removeListener(this);
    return true;
  }

  @override
  void onZebraData({dynamic payload}) {

    // enabled?
    if (!enabled) return;

    // no payload
    if (payload == null) return;

    // barcode data?
    if (payload is barcode.Payload && payload.barcodes.isNotEmpty) {
      Data data = barcode.Payload.toData(payload);
      onSuccess(data, code: 200);
    }

    // rfid tag data?
    if (payload is rfid.Payload && payload.tags.isNotEmpty) {
      Data data = rfid.Payload.toData(payload);
      onSuccess(data, code: 200);
    }
  }

  @override
  void onZebraConnectionStatus(bool connected) {
    this.connected = connected;
  }
}
