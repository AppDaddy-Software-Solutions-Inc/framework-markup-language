// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/detectors/detectable/detectable.dart';
import 'package:fml/datasources/detectors/iDetector.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/datasources/detectors/detector_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:xml/xml.dart';
import 'barcode.dart';
import 'package:fml/helper/helper_barrel.dart';

class BarcodeDetectorModel extends DetectorModel implements IDetector
{
  List<BarcodeFormats>? barcodeFormats;
  
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
    
    /////////////////////
    /* Barcode Formats */
    /////////////////////
    String? format = Xml.get(node: xml, tag: 'format');
    List<String> formats = [];
    if (format != null) formats = format.split(",");
    for (String format in formats)
    {
      format = format.trim().toUpperCase();
      BarcodeFormats? f = S.toEnum(format, BarcodeFormats.values);
      if (f != null)
      {
        if (this.barcodeFormats == null) this.barcodeFormats = [];
        if (!this.barcodeFormats!.contains(f)) this.barcodeFormats!.add(f);
      }
    }
  }

  @override
  void dispose()
  {
    Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  void detect(DetectableImage image) async
  {
    if (!busy)
    {
      busy = true;

      count++;
      Payload? payload = await BarcodeDetector().detect(image, barcodeFormats, tryharder, invert);
      if (payload != null)
      {
        Data data = Payload.toData(payload);
        await onDetected(data);
      }
      else await onDetectionFailed(Data(data: [{"message" : "Barcode detector $id failed to detect any barcodes in the supplied image"}]));

      busy = false;
    }
  }
}

