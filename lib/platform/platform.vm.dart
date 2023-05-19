// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:fml/log/manager.dart';
import 'package:fml/system.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fml/helper/common_helpers.dart';
import 'dart:io' as io;

class Platform
{
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

  // application root path
  static Future<String?> get path async
  {
    // initialize the app root folder
    if (isWeb) return null;
    if (isMobile || (isDesktop && useragent == "macos")) return (await getApplicationDocumentsDirectory()).path;
    return dirname(io.Platform.resolvedExecutable);
  }

  static init() async {}

  static Future<dynamic> fileSaveAs(List<int> bytes, String filepath) async
  {
    // make the file name safe
    filepath = S.toSafeFileName(filepath);

    String? folder;
    try
    {
        Directory? directory = await getDownloadsDirectory();
        if (directory != null) folder = directory.path;
    }
    catch(e){
      Log().debug('$e');
    }

    try
    {
      if (folder == null)
      {
        Directory? directory = await getTemporaryDirectory();
        folder = directory.path;
      }
    }
    catch(e){
      Log().debug('$e');
    }

    try
    {
      if (folder == null)
      {
        Directory? directory = await getExternalStorageDirectory();
        if (directory != null) folder = directory.path;
      }
    }
    catch(e){
      Log().debug('$e');
    }

    if (folder != null)
    {
      String path = join(folder,filepath);
      File file = File(path);
      await file.writeAsBytes(bytes);
      OpenFilex.open(path);
      return file;
    }
    else {
      System.toast("Unable to save file");
    }
  }

  static dynamic fileSaveAsFromBlob(dynamic blob, String filepath)
  {
    System.toast("File Save As Blob not supported on Mobile");
  }

  static void openPrinterDialog()
  {
    Log().warning('openPrinterDialog() Unimplemented for platform.vm.dart');
  }

  static File? getFile(String? filepath)
  {
    if (filepath == null) return null;
    try
    {
      if (_fileExists(filepath)) return File(filepath);
    }
    catch(e)
    {
      Log().exception(e, caller: 'platform.vm.dart => bool file($filepath)');
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
    catch(e)
    {
      Log().exception(e, caller: 'platform.vm.dart => bool folderExists($folder)');
      return false;
    }
  }

  static bool fileExists(String filepath) => _fileExists(filepath);
  static bool _fileExists(String filepath)
  {
    try
    {
      if (extension(filepath).trim() == "") return false;
      return (FileSystemEntity.typeSync(filepath) != FileSystemEntityType.notFound);
    }
    catch(e)
    {
      Log().exception(e, caller: 'platform.vm.dart => bool fileExists($filepath)');
      return false;
    }
  }

  static Future<String?> readFile(String? filepath) async
  {
    if (filepath == null) return null;
    try
    {
      // qualify file name
      if (_fileExists(filepath))
      {
        File file = File(filepath);
        return await file.readAsString();
      }
      return null;
    }
    catch(e)
    {
      Log().exception(e, caller: 'platform.vm.dart => bool readFile($filepath)');
      return null;
    }
  }

  static Future<Uint8List?> readFileBytes(String? filepath) async
  {
    if (filepath == null) return null;
    try
    {
      // qualify file name
      if (_fileExists(filepath))
      {
        File file = File(filepath);
        return await file.readAsBytes();
      }
      return null;
    }
    catch(e)
    {
      Log().exception(e, caller: 'platform.vm.dart => bool readFileBytes($filepath)');
      return null;
    }
  }

  static Future<String?> createFolder(String folder) async
  {
    try
    {
      // qualify folder name
      if (basename(folder).contains(".")) folder = dirname(folder);

      if (!_folderExists(folder))
      {
        Log().info('Creating folder $folder');
        await Directory(folder).create(recursive: true);
      }
      return folder;
    }
    catch(e)
    {
      Log().exception(e, caller: 'platform.vm.dart => bool createFolder($folder)');
      return null;
    }
  }

  static Future<bool> writeFile(String? filepath, dynamic content) async
  {
    bool ok = true;
    if (filepath == null) return false;
    try
    {
      // create the folder
      String? folder = await createFolder(filepath);

      // write the file
      if (folder != null)
      {
        if (content is ByteData)  await File(filepath).writeAsBytes(content.buffer.asUint8List());
        if (content is Uint8List) await File(filepath).writeAsBytes(content);
        if (content is String)    await File(filepath).writeAsString(content);
      }
    }
    catch(e)
    {
      Log().exception(e, caller: 'platform.vm.dart => bool fileWriteBytes($filepath)');
      ok = false;
    }
    return ok;
  }

  static Future<bool> deleteFile(String filepath) async
  {
    try
    {
      // qualify file name
      filepath = filepath;

      // delete the file
      if (_fileExists(filepath)) File(filepath).delete();
      return true;
    }
    catch(e)
    {
      Log().exception(e, caller: 'platform.vm.dart => bool deleteFile($filepath)');
      return false;
    }
  }

  static Future<bool> goBackPages(int pages) async => false;

  static int getNavigationType() => 0;

  static String get title => applicationTitle;
}
