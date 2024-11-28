// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/detectors/detector_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/datasources/detectors/detector_model.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/observable/observables/boolean.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:xml/xml.dart';
import 'barcode_detector.dart';
import 'package:fml/helpers/helpers.dart';

import 'package:fml/datasources/detectors/barcode/barcode_detector.web.dart'
if (dart.library.io) 'package:fml/datasources/detectors/barcode/barcode_detector.vm.dart'
if (dart.library.html) 'package:fml/datasources/detectors/barcode/barcode_detector.web.dart';

import 'package:fml/datasources/detectors/image/detectable_image.web.dart'
    if (dart.library.io) 'package:fml/datasources/detectors/image/detectable_image.vm.dart'
    if (dart.library.html) 'package:fml/datasources/detectors/image/detectable_image.web.dart';

class BarcodeDetectorModel extends DetectorModel implements IDetectable {
  List<BarcodeFormats>? barcodeFormats;

  // try harder
  BooleanObservable? _tryharder;
  set tryharder(dynamic v) {
    if (_tryharder != null) {
      _tryharder!.set(v);
    } else if (v != null) {
      _tryharder = BooleanObservable(Binding.toKey(id, 'tryharder'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool get tryharder => _tryharder?.get() ?? true;

  // invert the image on scan
  BooleanObservable? _invert;
  set invert(dynamic v) {
    if (_invert != null) {
      _invert!.set(v);
    } else if (v != null) {
      _invert = BooleanObservable(Binding.toKey(id, 'invert'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool get invert => _invert?.get() ?? true;

  BarcodeDetectorModel(super.parent, super.id);

  static BarcodeDetectorModel? fromXml(Model parent, XmlElement xml) {
    BarcodeDetectorModel? model;
    try {
      model = BarcodeDetectorModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'barcode.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {
    super.deserialize(xml);

    // properties
    tryharder = Xml.get(node: xml, tag: 'tryharder');
    invert = Xml.get(node: xml, tag: 'invert');

    // barcode formats
    String? format = Xml.get(node: xml, tag: 'format');
    List<String> formats = [];
    if (format != null) formats = format.split(",");
    for (String format in formats) {
      format = format.trim().toUpperCase();
      var f = toEnum(format, BarcodeFormats.values);
      if (f != null) {
        barcodeFormats ??= [];
        if (!barcodeFormats!.contains(f)) barcodeFormats!.add(f);
      }
    }
  }

  @override
  void detect(DetectableImage image, bool streamed) async {
    if (!busy) {
      busy = true;

      count++;

      // get the detector
      var detector = await BarcodeDetector().getDetector();

      // detect in image
      var payload = await detector.detect(image, barcodeFormats, tryharder, invert);

      if (payload != null) {
        Data data = Payload.toData(payload);
        await onDetected(data);
      } else if (!streamed) {
        await onDetectionFailed(Data(data: [
          {
            "message":
                "Barcode detector $id failed to detect any barcodes in the supplied image"
          }
        ]));
      }
      busy = false;
    }
  }
}
