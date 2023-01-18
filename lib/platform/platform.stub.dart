// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
class Platform
{
  static Future<String?> get path async => null;
  static String? get useragent => "unimplemented";
  static init() async => throw('Unimplemented');
  static Future<dynamic> fileSaveAs(List<int> bytes, String filepath) async => throw('Unimplemented');
  static dynamic fileSaveAsFromBlob(dynamic blob, String? filepath) => throw('Unimplemented');
  static void openPrinterDialog() => throw('Unimplemented');
  static dynamic getFile(String? filepath) => throw('Unimplemented');
  static String? folderPath(String folder) => throw('Unimplemented');
  static String? filePath(String? filepath) => throw('Unimplemented');
  static bool folderExists(String folder) => throw('Unimplemented');
  static bool fileExists(String filepath) => throw('Unimplemented');
  static Future<dynamic> readFile(String? filepath, {bool asBytes = false}) async => throw('Unimplemented');
  static Future<String?> createFolder(String? folder) async => throw('Unimplemented');
  static Future<bool> writeFile(String? filepath, dynamic content) async => throw('Unimplemented');
  static Future<bool> deleteFile(String filepath) async => throw('Unimplemented');
  static Future<bool> goBackPages(int pages) async => throw('Unimplemented');
  static int getNavigationType() => throw('Unimplemented');
}
