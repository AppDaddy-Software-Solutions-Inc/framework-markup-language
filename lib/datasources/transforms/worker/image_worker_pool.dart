import 'package:fml/datasources/transforms/worker/image_service.dart';
import 'package:squadron/squadron.dart';
import 'dart:typed_data';
import 'package:fml/datasources/transforms/worker/image_worker_activator.dart'
if (dart.library.js)   'package:fml/datasources/transforms/worker/browser/image_worker_activator.dart'
if (dart.library.html) 'package:fml/datasources/transforms/worker/browser/image_worker_activator.dart'
if (dart.library.io)   'package:fml/datasources/transforms/worker/vm/image_worker_activator.dart';

class ImageWorkerPool extends WorkerPool<ImageWorker> implements ImageService
{
  ImageWorkerPool(ConcurrencySettings concurrencySettings) : super(createWorker, concurrencySettings: concurrencySettings);

  @override
  Future<String?> gray(Uint8List imageData) => execute((w) => w.gray(imageData));

  @override
  Future<String?> crop(Uint8List imageData, int x, int y, int width, int height) => execute((w) => w.crop(imageData, x, y, width, height));

  @override
  Future<String?> flip(Uint8List imageData, String axis) => execute((w) => w.flip(imageData, axis));

  @override
  Future<String?> resize(Uint8List imageData, int width, int height) => execute((w) => w.resize(imageData, width, height));
}

// Implementation of ThumbnailService as a Squadron worker
class ImageWorker extends Worker implements ImageService
{
  ImageWorker(dynamic entryPoint, {List args = const []}) : super(entryPoint, args: args);

  @override
  Future<String?> gray(Uint8List imageData) => send(ImageService.Gray, args: [imageData]);

  @override
  Future<String?> crop(Uint8List imageData, int x, int y, int width, int height) => send(ImageService.Crop, args: [imageData,x,y,width,height]);

  @override
  Future<String?> flip(Uint8List imageData, String axis) => send(ImageService.Flip, args: [imageData,axis]);

  @override
  Future<String?> resize(Uint8List imageData, int width, int height) => send(ImageService.Resize, args: [imageData,width, height]);
}
