// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/detectors/detectable/detectable.dart';
import 'package:fml/datasources/detectors/iDetector.dart';
import 'package:fml/log/manager.dart';

import 'package:fml/datasources/detectors/detector_model.dart' ;
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:xml/xml.dart';
import 'package:fml/datasources/detectors/text/text.dart';
import 'package:fml/helper/helper_barrel.dart';

class TextDetectorModel extends DetectorModel implements IDetector
{
  TextDetectorModel(WidgetModel parent, String? id) : super(parent, id);

  static TextDetectorModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    TextDetectorModel? model;
    try
    {
      model = TextDetectorModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'ocr.Model');
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
      Payload? payload = await TextDetector().detect(image);
      if (payload != null)
      {
        Data data = Payload.toData(payload);
        await onDetected(data);
      }
      else await onDetectionFailed(Data(data: [{"message" : "Text detector $id failed to detect any text in the supplied image"}]));

      busy = false;
    }
  }
}

