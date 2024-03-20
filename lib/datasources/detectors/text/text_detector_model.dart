// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/detectors/detector_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/datasources/detectors/detector_model.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/datasources/detectors/text/text_detector.dart';
import 'package:fml/helpers/helpers.dart';

import 'package:fml/datasources/detectors/image/detectable_image.stub.dart'
    if (dart.library.io) 'package:fml/datasources/detectors/image/detectable_image.mobile.dart'
    if (dart.library.html) 'package:fml/datasources/detectors/image/detectable_image.web.dart';

class TextDetectorModel extends DetectorModel implements IDetectable {
  TextDetectorModel(super.parent, super.id);

  static TextDetectorModel? fromXml(WidgetModel parent, XmlElement xml) {
    TextDetectorModel? model;
    try {
      model = TextDetectorModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'ocr.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {
    super.deserialize(xml);
  }

  @override
  void detect(DetectableImage image, bool streamed) async {
    if (!busy) {
      busy = true;

      count++;
      Payload? payload = await ITextDetector().detect(image);
      if (payload != null) {
        Data data = Payload.toData(payload);
        await onDetected(data);
      } else if (!streamed) {
        await onDetectionFailed(Data(data: [
          {
            "message":
                "Text detector $id failed to detect any text in the supplied image"
          }
        ]));
      }

      busy = false;
    }
  }
}
