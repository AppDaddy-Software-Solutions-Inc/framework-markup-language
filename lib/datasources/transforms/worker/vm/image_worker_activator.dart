import 'package:fml/datasources/transforms/worker/image_worker_pool.dart' show ImageWorker;
import 'package:fml/datasources/transforms/worker/vm/image_worker.dart' as isolate;

ImageWorker createWorker() => ImageWorker(isolate.start);
String get workerPlatform => 'vm';
