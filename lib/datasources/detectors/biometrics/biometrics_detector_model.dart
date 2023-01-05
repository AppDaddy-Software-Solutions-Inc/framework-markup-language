// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/detectors/iDetectable.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/datasources/detectors/detector_model.dart' ;
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:xml/xml.dart';
import 'biometrics_detector.dart';
import 'package:fml/helper/helper_barrel.dart';

import 'package:fml/datasources/detectors/image/detectable_image.stub.dart'
if (dart.library.io)   'package:fml/datasources/detectors/image/detectable_image.mobile.dart'
if (dart.library.html) 'package:fml/datasources/detectors/image/detectable_image.web.dart';

class BiometricsDetectorModel extends DetectorModel implements IDetectable
{
  BiometricsDetectorModel(WidgetModel parent, String? id) : super(parent, id);

  static BiometricsDetectorModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    BiometricsDetectorModel? model;
    try
    {
      model = BiometricsDetectorModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e, caller: 'biometrics.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {    super.deserialize(xml);
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
      Payload? payload = await IBiometricsDetector().detect(image);
      if (payload != null)
      {
        Data data = Payload.toData(payload);
        await onDetected(data);
      }
      else await onDetectionFailed(Data(data: [{"message" : "Biometrics detector $id failed to detect any faces in the supplied image"}]));

      busy = false;
    }
  }
}

