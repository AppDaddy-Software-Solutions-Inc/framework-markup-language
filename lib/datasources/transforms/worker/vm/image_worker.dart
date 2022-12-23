import 'package:fml/datasources/transforms/worker/image_service.dart';
import 'package:squadron/squadron_service.dart';

void start(Map command) => run((startRequest) => ImageServiceImpl(), command);
