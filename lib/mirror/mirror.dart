// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/datasources/http/http.dart';
import 'package:fml/log/manager.dart';
import 'asset.dart';
import 'package:fml/helpers/helpers.dart';

// platform
import 'package:fml/platform/platform.web.dart'
if (dart.library.io)   'package:fml/platform/platform.vm.dart'
if (dart.library.html) 'package:fml/platform/platform.web.dart';

class Mirror
{
  final String url;

  Mirror(this.url);

  bool abort = false;

  void dispose()
  {
    abort = true;
  }

  void execute() async
  {
    if (isNullOrEmpty(url)) return;

    // load assets from the remote
    Assets assets = Assets();
    await assets.load(url);

    for (Asset asset in assets.list) {
      if (asset.type == "file" && !abort)
    {
      var uri = URI.parse(asset.uri);
      if (uri != null && uri.pageExtension != null)
      {
        // file exists?
        var filepath = uri.asFilePath();
        bool exists = (filepath != null && Platform.fileExists(filepath));

        // check the age
        bool downloadRequired = true;
        if (exists)
        {
          var file = Platform.getFile(filepath);
          if (file != null)
          {
            var modified = await file.lastModified();
            var epoch = modified.millisecondsSinceEpoch;
            if (epoch >= (asset.epoch ?? 0)) downloadRequired = false;
            if (downloadRequired) Log().debug('File on disk is out of date [${asset.name}]', caller: "Mirror");
          }
        }

        // get the asset from the server
        if (downloadRequired && filepath != null && !abort) await _copyAssetFromServer(asset, filepath);
      }
    }
    }

    Log().debug('Inventory Check Complete', caller: "Mirror");
  }

  static Future<bool> _copyAssetFromServer(Asset asset, String filepath) async
  {
    if (asset.uri == null) return false;

    Log().debug('Getting file from server [${asset.name}]', caller: "Mirror");

    // query the asset
    var response = await Http.get(asset.uri!);

    // error in response?
    if (!response.ok)
    {
      Log().error('Error copying asset from ${asset.uri}. Error is ${response.statusMessage}', caller: "Mirror");
      return false;
    }

    // write asset to disk
    return await Platform.writeFile(filepath, response.bytes);
  }
}
