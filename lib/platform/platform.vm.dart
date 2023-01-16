// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:fml/dialog/service.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/phrase.dart';
import 'package:fml/system.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cross_connectivity/cross_connectivity.dart';
import 'package:fml/helper/helper_barrel.dart';
import 'dart:io' as io;

class Platform
{
  static bool connected = false;

  static String? get useragent
  {
    if (io.Platform.isIOS)     return  "ios";
    if (io.Platform.isAndroid) return  "android";
    if (io.Platform.isMacOS)   return  "macos";
    if (io.Platform.isWindows) return  "windows";
    if (io.Platform.isLinux)   return  "linux";
    if (io.Platform.isFuchsia) return  "fuchsia";
    return null;
  }

  // fully qualified file path
  static String rootFolder(String filename) => join(_rootFolder ?? "",  filename);
  static String? _rootFolder;
  static Future<String?> _initRootFolder() async
  {
    try
    {
      // desktop platform
      if (isDesktop)
      {
        _rootFolder = dirname(io.Platform.resolvedExecutable);
        return _rootFolder;
      }

      // mobile platform
      if (isMobile)
      {
        Directory directory = await getApplicationSupportDirectory();
        _rootFolder = directory.path;
        return _rootFolder;
      }

      return null;
    }
    catch (e)
    {
      Log().error("Failed to get application support directory");
    }

    try
    {
      Directory directory = await getApplicationDocumentsDirectory();
      _rootFolder = directory.path;
      return _rootFolder;
    }
    catch (e)
    {
      Log().error("Failed to get application documents directory");
    }

    try
    {
      Directory? directory = await getExternalStorageDirectory();
      if (directory?.path != null)
      {
        _rootFolder = directory!.path;
        return _rootFolder;
      }
    }
    catch (e)
    {
      Log().error("Failed to get external storage directory");
    }

    // cannot get root folder
    Log().debug('******************************************************************************************************');
    Log().debug('* Unable to run FML Engine, is the system trying to run on a web browser when set as a mobile build? *');
    Log().debug('******************************************************************************************************');

    return null;
  }

  static init() async
  {
    // initialize the app root folder
    await _initRootFolder();

    // initialize connection state
    await _initConnectivity();
  }

  static Connectivity _connection = Connectivity();
  static _initConnectivity() async {
    try
    {
      ConnectivityStatus initialConnection = await _connection.checkConnectivity();
      if (initialConnection == ConnectivityStatus.none) System.toast(Phrases().checkConnection, duration: 3);

      // Add connection listener
      _connection.isConnected.listen((onData)
      {
        if (System().domain != null)
        {
          checkInternetConnection(System().domain);
        }
        connected = onData;
      });

      // For the initial connectivity test we want to give checkConnection some time
      // but it still needs to run synchronous so we give it a second
      await Future.delayed(Duration(seconds: 1));
      Log().debug('initConnectivity status: $connected');
    }
    catch (e)
    {
      connected = false;
      Log().debug('Error initializing connectivity');
      Log().exception(e, caller: 'system.mobile.dart => _init_connectivity() async');
    }
  }

  //Timer? _connectionTimer;
  static Future<bool> checkInternetConnection(String? domain) async
  {
    return true; // now done with isConnected.listen(), leaving code for ease of revert
    // bool connected = this.connected;
    // try {
    //   if (!S.isNullOrEmpty(domain)) {
    //     if ((_connectionTimer != null) && (_connectionTimer!.isActive))
    //       _connectionTimer!.cancel();
    //     Uri? uri = Url.parse(domain!);
    //     if (uri != null) {
    //       Socket socket =
    //           await Socket.connect(uri.host, 80, timeout: Duration(seconds: 5));
    //       socket.destroy();
    //       connected = true;
    //       print('Network: Connected');
    //     } else {
    //       connected = false;
    //       print('Network: Failed to connect to socket');
    //     }
    //   } else {
    //     print('Network: No domain to check connection');
    //   }
    // } catch (e) {
    //   connected = false;
    // }
    // if (connected == false)
    //   _connectionTimer =
    //       Timer(Duration(seconds: 5), () => checkInternetConnection(domain));
    // this.connected = connected;
    // return connected;
  }

  static Future<dynamic> fileSaveAs(List<int> bytes, String filename) async
  {
    // make the file name safe
    filename = S.toSafeFileName(filename);

    String? folder;
    try
    {
      if (folder == null)
      {
        Directory? directory = await getDownloadsDirectory();
        if (directory != null) folder = directory.path;
      }
    }
    catch(e){}

    try
    {
      if (folder == null)
      {
        Directory? directory = await getTemporaryDirectory();
        folder = directory.path;
      }
    }
    catch(e){}

    try
    {
      if (folder == null)
      {
        Directory? directory = await getExternalStorageDirectory();
        if (directory != null) folder = directory.path;
      }
    }
    catch(e){}

    if (folder != null)
    {
      String path = join(folder,filename);
      File file = new File(path);
      await file.writeAsBytes(bytes);
      OpenFilex.open(path);
      return file;
    }
    else System.toast("Unable to save file");
  }

  static dynamic fileSaveAsFromBlob(dynamic blob, String filename)
  {
    DialogService().show(type: DialogType.error, title: "File Save As Blob not supported on Mobile");
  }

  static void openPrinterDialog()
  {
    Log().warning('openPrinterDialog() Unimplemented for system.mobile.dart');
  }

  static File? getFile(String? filename)
  {
    if (filename == null) return null;

    try
    {
      // qualify file name
      filename = rootFolder(filename);

      if (_fileExists(filename)) return File(filename);
    }
    catch (e)
    {
      Log().exception(e, caller: 'system.mobile.dart => bool file($filename)');
    }
    return null;
  }

  static bool _folderExists(String? folder)
  {
    try
    {
      if (folder == null) return false;
      return (FileSystemEntity.typeSync(folder) != FileSystemEntityType.notFound);
    }
    catch (e)
    {
      Log().exception(e, caller: 'system.desktop.dart => bool folderExists($folder)');
      return false;
    }
  }

  static bool fileExists(String filename) => _fileExists(rootFolder(filename));
  static bool _fileExists(String filename)
  {
    try
    {
      if (extension(filename).trim() == "") return false;
      return (FileSystemEntity.typeSync(filename) != FileSystemEntityType.notFound);
    }
    catch (e)
    {
      Log().exception(e, caller: 'system.desktop.dart => bool fileExists($filename)');
      return false;
    }
  }

  static Future<dynamic> readFile(String filename, {bool asBytes = false}) async
  {
    try
    {
      // qualify file name
      filename = rootFolder(filename);
      if (_fileExists(filename))
      {
        File file = File(filename);
        return (asBytes == true) ? await file.readAsBytes() : await file.readAsString();
      }
      return null;
    }
    catch (e)
    {
      Log().exception(e, caller: 'system.mobile.dart => bool readFile($filename)');
      return null;
    }
  }

  static Future<String?> createFolder(String folder) async
  {
    try
    {
      // qualify folder name
      folder = rootFolder(folder);
      if (basename(folder).contains(".")) folder = dirname(folder);

      if (!_folderExists(folder))
      {
        Log().info('Creating folder $folder');
        await Directory(folder).create(recursive: true);
      }
      return folder;
    }
    catch (e)
    {
      Log().exception(e, caller: 'system.mobile.dart => bool fileWriteBytes($folder)');
      return null;
    }
  }

  static Future<bool> writeFile(String filename, dynamic content) async
  {
    bool ok = true;
    try
    {
      // qualify file name
      filename = rootFolder(filename);

      // create the folder
      String? folder = await createFolder(filename);

      // write the file
      if (folder != null)
      {
        if (content is ByteData)  await File(filename).writeAsBytes(content.buffer.asUint8List());
        if (content is Uint8List) await File(filename).writeAsBytes(content);
        if (content is String)    await File(filename).writeAsString(content);
      }
    }
    catch (e)
    {
      Log().exception(e, caller: 'system.desktop.dart => bool fileWriteBytes($filename)');
      ok = false;
    }
    return ok;
  }

  static Future<bool> deleteFile(String filename) async
  {
    try
    {
      // qualify file name
      filename = rootFolder(filename);

      // delete the file
      if (_fileExists(filename)) File(filename).delete();
      return true;
    }
    catch (e)
    {
      Log().exception(e, caller: 'system.mobile.dart => bool deleteFile(' + filename + ')');
      return false;
    }
  }

  static Future<bool> goBackPages(int pages) async
  {
    return false;
  }

  static int getNavigationType()
  {
    return 0;
  }
}
