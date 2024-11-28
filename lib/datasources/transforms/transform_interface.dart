import 'package:fml/data/data.dart';

abstract class IDataTransform {
  bool? get enabled;
  Future<void> apply(Data? data);
}
