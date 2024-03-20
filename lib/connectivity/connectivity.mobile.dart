import 'dart:io';
import 'package:fml/log/manager.dart';

class Internet
{
  static Future<bool> isConnected() async
  {
    try
    {
      final address = await InternetAddress.lookup('google.com');
      if (address.isNotEmpty && address.first.rawAddress.isNotEmpty) return true;
    }
    catch(e)
    {
      Log().info("Error performing Internet lookup. Error is $e");
    }
    return false;
  }
}
