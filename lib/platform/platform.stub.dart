// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
class Platform
{
  static Future<String?> get path async => null;
  static String? get useragent => null;
  static init() async => throw UnimplementedError();
  static Future<dynamic> fileSaveAs(List<int> bytes, String filepath) async => throw UnimplementedError();
  static dynamic fileSaveAsFromBlob(dynamic blob, String? filepath) => throw UnimplementedError();
  static void openPrinterDialog() => throw UnimplementedError();
  static dynamic getFile(String? filepath) => throw UnimplementedError();
  static String? folderPath(String folder) => throw UnimplementedError();
  static String? filePath(String? filepath) => throw UnimplementedError();
  static bool folderExists(String folder) => throw UnimplementedError();
  static bool fileExists(String filepath) => throw UnimplementedError();
  static Future<dynamic> readFile(String? filepath, {bool asBytes = false}) async => throw UnimplementedError();
  static Future<String?> createFolder(String? folder) async => throw UnimplementedError();
  static Future<bool> writeFile(String? filepath, dynamic content) async => throw UnimplementedError();
  static Future<bool> deleteFile(String filepath) async => throw UnimplementedError();
  static Future<bool> goBackPages(int pages) async => throw UnimplementedError();
  static int getNavigationType() => throw UnimplementedError();
}
