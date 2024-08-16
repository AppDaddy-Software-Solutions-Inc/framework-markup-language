import 'package:flutter/material.dart';
import 'package:fml/widgets/package/package_model.dart';
abstract class IPlugin {
  PackageModel? get package;
  String? get plugin;
  Widget? build();
}
