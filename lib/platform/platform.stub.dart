// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
class Platform
{
  static String? get useragent => "unimplemented";
  static bool connected = false;
  static init() async => throw('Unimplemented');
  static Future<bool> checkInternetConnection(String? domain) async => throw('Unimplemented');
  static Future<dynamic> fileSaveAs(List<int> bytes, String filename) async => throw('Unimplemented');
  static dynamic fileSaveAsFromBlob(dynamic blob, String? filename) => throw('Unimplemented');
  static void openPrinterDialog() => throw('Unimplemented');
  static dynamic getFile(String? filename) => throw('Unimplemented');
  static String? folderPath(String folder) => throw('Unimplemented');
  static String? filePath(String? filename) => throw('Unimplemented');
  static bool folderExists(String folder) => throw('Unimplemented');
  static bool fileExists(String filename) => throw('Unimplemented');
  static Future<dynamic> readFile(String? filename, {bool asBytes = false}) async => throw('Unimplemented');
  static Future<String?> createFolder(String? folder) async => throw('Unimplemented');
  static Future<bool> writeFile(String? filename, dynamic content) async => throw('Unimplemented');
  static Future<bool> deleteFile(String filename) async => throw('Unimplemented');
  static Future<bool> goBackPages(int pages) async => throw('Unimplemented');
  static int getNavigationType() => throw('Unimplemented');
}
