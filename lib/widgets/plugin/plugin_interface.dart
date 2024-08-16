import 'package:fml/widgets/package/package_model.dart';
abstract class IPlugin {
  PackageModel? get packageModel;
  String? get packageName;
  String? get packageClass;
}
