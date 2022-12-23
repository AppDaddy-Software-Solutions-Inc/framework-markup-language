import 'package:fml/datasources/transforms/worker/image_worker_pool.dart' show ImageWorker;

ImageWorker createWorker() => ImageWorker('/workers/image_worker.dart.js');
String get workerPlatform => 'browser';
