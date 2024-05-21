// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/detectors/detector_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/datasources/detectors/detector_model.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:xml/xml.dart';
import 'biometrics_detector.dart';
import 'package:fml/helpers/helpers.dart';

import 'package:fml/datasources/detectors/image/detectable_image.web.dart'
    if (dart.library.io) 'package:fml/datasources/detectors/image/detectable_image.vm.dart'
    if (dart.library.html) 'package:fml/datasources/detectors/image/detectable_image.web.dart';

class BiometricsDetectorModel extends DetectorModel implements IDetectable {
  BiometricsDetectorModel(super.parent, super.id);

  static BiometricsDetectorModel? fromXml(Model parent, XmlElement xml) {
    BiometricsDetectorModel? model;
    try {
      model = BiometricsDetectorModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'biometrics.Model');
      model = null;
    }
    return model;
  }

  @override
  void detect(DetectableImage image, bool streamed) async {
    if (!busy) {
      busy = true;

      count++;
      Payload? payload = await IBiometricsDetector().detect(image);
      if (payload != null) {
        Data data = Payload.toData(payload);
        await onDetected(data);
      } else if (!streamed) {
        await onDetectionFailed(Data(data: [
          {
            "message":
                "Biometrics detector $id failed to detect any faces in the supplied image"
          }
        ]));
      }

      busy = false;
    }
  }
}
