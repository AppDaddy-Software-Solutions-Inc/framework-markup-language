// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:cross_connectivity/cross_connectivity.dart';
import 'package:fml/phrase.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dialog/service.dart';
import 'log/manager.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/helper_barrel.dart';

class SystemPlatform extends WidgetModel
{
  static String platform = "desktop";

  get useragent => null;

  bool nfc = false;
  bool camera = false;

  // connected
  BooleanObservable? _connected;
  set connected(dynamic v)
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

  // fully qualified file path
  static String rootFolder(String filename) => join(_rootFolder ?? "",  filename);
  static String? _rootFolder;
  static Future<String?> _initRootFolder() async
  {
    try
    {
        String directory = dirname(Platform.resolvedExecutable);
        _rootFolder = join(directory,"data","flutter_assets");
        return _rootFolder;
    }
    catch (e)
    {
      Log().error("Failed to get external storage directory");
      return null;
    }
  }

  SystemPlatform() : super(null, "SYSTEM", scope: Scope("SYSTEM"));

  init() async
  {
    // initialize the app root folder
    await _initRootFolder();

    // initialize connection state
    await _initConnectivity();
  }

  Connectivity _connection = Connectivity();
  _initConnectivity() async {
    try
    {
      ConnectivityStatus initialConnection = await _connection.checkConnectivity();
      if (initialConnection == ConnectivityStatus.none) System.toast(Phrases().checkConnection, duration: 3);

      // Add connection listener
      _connection.isConnected.listen((onData)
      {
        connected = onData;
      });

      // For the initial connectivity test we want to give checkConnection some time
      // but it still needs to run synchronous so we give it a second
      await Future.delayed(Duration(seconds: 1));
      Log().debug('initConnectivity status: ${System().connected}');
    }
    catch (e)
    {
      connected = false;
      Log().debug('Error initializing connectivity');
      Log().exception(e, caller: 'system.desktp[.dart => _init_connectivity() async');
    }
  }


  void openPrinterDialog() 
  {
    Log().warning('openPrinterDialog() Unimplemented for system.desktop.dart');
  }

  Future<dynamic> fileSaveAs(List<int> bytes, String filename) async
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
    catch(e) {}

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
    catch(e) {}

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

  dynamic fileSaveAsFromBlob(dynamic blob, String filename) 
  {
    DialogService().show(type: DialogType.error, title: "File Save As Blob not supported on Desktop");
  }

  File? getFile(String filename) 
  {
    try 
    {
      // qualify file name
      filename = rootFolder(filename);

      if (_fileExists(filename)) return File(filename);
    }
    catch (e)
    {
      Log().exception(e, caller: 'system.desktop.dart => bool file($filename)');
    }
    return null;
  }

  bool _folderExists(String? folder)
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

  bool fileExists(String filename) => _fileExists(rootFolder(filename));
  bool _fileExists(String filename)
  {
    try
    {
      if (!basename(filename).contains(".")) return false;
      return (FileSystemEntity.typeSync(filename) != FileSystemEntityType.notFound);
    }
    catch (e)
    {
      Log().exception(e, caller: 'system.desktop.dart => bool fileExists($filename)');
      return false;
    }
  }

  Future<dynamic> readFile(String filename, {bool asBytes = false}) async
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
      Log().exception(e, caller: 'system.desktop.dart => bool readFile($filename)');
      return null;
    }
  }

  Future<String?> createFolder(String folder) async
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
      Log().exception(e, caller: 'system.desktop.dart => createFolder($folder)');
    }
    // macOS
    try {
      final appDocumentDirectory = await getApplicationDocumentsDirectory();
      return appDocumentDirectory.path;
    }
    catch(e) {
      Log().exception(e, caller: 'system.desktop.dart => createFolder($folder)');
    }
    return null;
  }

  Future<bool> writeFile(String filename, dynamic content) async 
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

  Future<bool> deleteFile(String filename) async
  {
    try
    {
      // qualify file name
      filename = rootFolder(filename);

      // delete the file
      if (_fileExists(filename)) await File(filename).delete();
      return true;
    }
    catch (e)
    {
      Log().exception(e, caller: 'system.desktop.dart => bool deleteFile($filename)');
      return false;
    }
  }

  Future<bool> goBackPages(int pages) async
  {
    return false;
  }

  int getNavigationType()
  {
    return 0;
  }
}
