import 'package:fml/helpers/xml.dart';
import 'package:fml/widgets/package/package_mixin.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:xml/xml.dart';

class PackageModel extends Model with PackageMixin {

  PackageModel(super.parent, super.id);

  static PackageModel fromXml(Model parent, XmlElement xml) {
    var model = PackageModel(parent, Xml.get(node: xml, tag: 'id'));
    model.deserialize(xml);
    return model;
  }
}

