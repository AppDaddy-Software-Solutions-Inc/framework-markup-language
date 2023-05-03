// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/detectors/iDetectable.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/datasources/detectors/detector_model.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/observable/observables/boolean.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:xml/xml.dart';
import 'barcode_detector.dart';
import 'package:fml/helper/common_helpers.dart';

import 'package:fml/datasources/detectors/image/detectable_image.stub.dart'
if (dart.library.io)   'package:fml/datasources/detectors/image/detectable_image.mobile.dart'
if (dart.library.html) 'package:fml/datasources/detectors/image/detectable_image.web.dart';

class BarcodeDetectorModel extends DetectorModel implements IDetectable
{
  List<BarcodeFormats>? barcodeFormats;

  // try harder
  BooleanObservable? _tryharder;
  set tryharder(dynamic v)
  {
    if (_tryharder != null)
    {
      _tryharder!.set(v);
    }
    else if (v != null)
    {
      _tryharder = BooleanObservable(Binding.toKey(id, 'tryharder'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get tryharder => _tryharder?.get() ?? true;

  // invert the image on scan
  BooleanObservable? _invert;
  set invert(dynamic v)
  {
    if (_invert != null)
    {
      _invert!.set(v);
    }
    else if (v != null)
    {
      _invert = BooleanObservable(Binding.toKey(id, 'invert'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get invert => _invert?.get() ?? true;

  BarcodeDetectorModel(WidgetModel parent, String? id) : super(parent, id);

  static BarcodeDetectorModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    BarcodeDetectorModel? model;
    try
    {
      model = BarcodeDetectorModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e, caller: 'barcode.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {
    super.deserialize(xml);

    // properties
    tryharder = Xml.get(node: xml, tag: 'tryharder');
    invert    = Xml.get(node: xml, tag: 'invert');

    // barcode formats
    String? format = Xml.get(node: xml, tag: 'format');
    List<String> formats = [];
    if (format != null) formats = format.split(",");
    for (String format in formats)
    {
      format = format.trim().toUpperCase();
      BarcodeFormats? f = S.toEnum(format, BarcodeFormats.values);
      if (f != null)
      {
        barcodeFormats ??= [];
        if (!barcodeFormats!.contains(f)) barcodeFormats!.add(f);
      }
    }
  }

  @override
  void dispose()
  {
    // Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  @override
  void detect(DetectableImage image, bool streamed) async
  {
    if (!busy)
    {
      busy = true;

      count++;
      Payload? payload = await IBarcodeDetector().detect(image, barcodeFormats, tryharder, invert);
      if (payload != null)
      {
        Data data = Payload.toData(payload);
        await onDetected(data);
      }
      else if (!streamed) await onDetectionFailed(Data(data: [{"message" : "Barcode detector $id failed to detect any barcodes in the supplied image"}]));
      busy = false;
    }
  }
}

