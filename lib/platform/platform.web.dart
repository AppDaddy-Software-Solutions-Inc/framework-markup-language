// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'dart:html';
import 'package:flutter/foundation.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/system.dart';
import 'dart:js';
import 'package:fml/helper/common_helpers.dart';

class Platform
{
  // application root path
  static Future<String?> get path async => null;

  static String? get useragent
  {
    const appleType   = "ios";
    const androidType = "android";
    const desktopType = "desktop";

    final userAgent = window.navigator.userAgent.toString().toLowerCase();

    // smartphone
    if( userAgent.contains("iphone"))   return appleType;
    if( userAgent.contains("android"))  return androidType;

    // tablet
    if( userAgent.contains("ipad")) return appleType;
    if( window.navigator.platform!.toLowerCase().contains("macintel") && window.navigator.maxTouchPoints! > 0 ) return appleType;

    return desktopType;
  }

  static final dynamic iframe = window.document.getElementById('invisible');

  static init() async
  {
    try
    {
      window.document.getElementById("logo")!.style.visibility = "hidden";
    }
    catch(e){}
  }

  static Future<dynamic> fileSaveAs(List<int> bytes, String filename) async
  {
    try
    {
      // make the file name safe
      filename = S.toSafeFileName(filename);

      final blob   = Blob([bytes]);
      final url    = Url.createObjectUrlFromBlob(blob);
      final anchor = document.createElement('a') as AnchorElement;

      anchor.href = url;
      anchor.style.display = 'none';
      anchor.download = filename;
      document.body!.children.add(anchor);

      anchor.click();

      document.body!.children.remove(anchor);
      Url.revokeObjectUrl(url);
    }
    catch(e)
    {
      System.toast("Unable to save file");
      Log().error('Error writing file');
      Log().exception(e);
      return null;
    }

    return null;
  }

  static dynamic fileSaveAsFromBlob(Blob blob, String? filename)
  {
    final url    = Url.createObjectUrlFromBlob(blob);
    final anchor = document.createElement('a') as AnchorElement;

    anchor.href = url;
    anchor.style.display = 'none';
    anchor.download = filename;
    document.body!.children.add(anchor);

    anchor.click();

    document.body!.children.remove(anchor);
    Url.revokeObjectUrl(url);
  }

  static void openPrinterDialog()
  {
    window.print();
  }

  static dynamic getFile(String? filename) => null;
  static String? folderPath(String folder) => null;
  static String? filePath(String? filename) => null;
  static bool folderExists(String folder) => false;
  static bool fileExists(String filename) => false;
  static Future<String?> readFile(String? filepath) async => null;
  static Future<Uint8List?> readFileBytes(String? filepath) async => null;
  static Future<String?> createFolder(String? folder) async => null;
  static Future<bool> writeFile(String? filename, dynamic content) async => true;
  static Future<bool> deleteFile(String filename) async => true;

  static Future<bool> goBackPages(int pages) async
  {
    try
    {
      String id = "fmlGo2";
      if (document.getElementById(id) == null)
      {
        var script = document.createElement("script");
        script.id = id;
        script.innerText = "function $id(i) { window.history.go(i); }";
        document.head!.append(script);
      }
      context.callMethod(id, [-1 * pages]);
      return true;
    }
    catch(e)
    {
      return false;
    }
  }

  static int getNavigationType()
  {
    try
    {
      return window.performance.navigation.type ?? 0;
    }
    catch(e)
    {
      return 0;
    }
  }
}
