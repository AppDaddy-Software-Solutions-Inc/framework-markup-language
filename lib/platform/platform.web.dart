// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'dart:html';
import 'package:fml/helper/string.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'dart:js';
import 'log/manager.dart';
import 'package:fml/observable/observable_barrel.dart';

class SystemPlatform extends WidgetModel
{
  static String platform = "web";

  String? get useragent
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

  bool nfc    = true;
  bool camera = false;

  static final dynamic iframe = window.document.getElementById('invisible');

  ///////////////
  /* connected */
  ///////////////
  BooleanObservable? _connected;
  set connected (dynamic v)
  {
    if (_connected != null)
    {
      _connected!.set(v);
    }
    else if (v != null)
    {
      _connected = BooleanObservable(Binding.toKey("SYSTEM", 'connected'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get connected => _connected?.get() ?? false;

  SystemPlatform() : super(null, "SYSTEM", scope: Scope("SYSTEM"))
  {
    //////////////////////////////
    /* Hide Splash Logo on Index */
    //////////////////////////////
    try
    {
      window.document.getElementById("logo")!.style.visibility = "hidden";
    }
    catch(e){}
  }


  init() async
  {
    /////////////////////////////////
    /* Initialize Connection State */
    /////////////////////////////////
    await _initConnectivity();
  }

  _initConnectivity() async
  {
    try
    {
      connected = true;
    }
    catch(e)
    {
      connected = true;
      Log().exception(e, caller: 'system.web.dart => _init_connectivity() async');
    }
  }

  Future<bool> checkInternetConnection(String? domain) async
  {
    return true;
  }

  Future<dynamic> fileSaveAs(List<int> bytes, String filename) async
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

  dynamic fileSaveAsFromBlob(Blob blob, String? filename)
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

  void openPrinterDialog()
  {
    window.print();
  }

  dynamic getFile(String? filename)
  {
    return null;
  }

  String? folderPath(String folder)
  {
    return null;
  }

  String? filePath(String? filename)
  {
    return null;
  }

  bool folderExists(String folder)
  {
    return false;
  }

  bool fileExists(String filename)
  {
    return false;
  }

  Future<dynamic> readFile(String? filename, {bool asBytes = false}) async
  {
    return null;
  }

  Future<String?> createFolder(String? folder) async
  {
    return null;
  }

  Future<bool> writeFile(String? filename, dynamic content) async
  {
    return true;
  }

  Future<bool> deleteFile(String filename) async
  {
    return true;
  }

  Future<bool> goBackPages(int pages) async
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

  int getNavigationType()
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
