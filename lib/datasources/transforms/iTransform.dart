import 'package:fml/data/data.dart';

abstract class ITransform
{
  bool? get enabled;
  Future<void> apply(Data? data);
}