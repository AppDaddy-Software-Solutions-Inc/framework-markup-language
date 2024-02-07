import 'dart:html';
import 'package:fml/log/manager.dart';

class Internet
{
  static Future<bool> isConnected() async
  {
    try
    {
      bool online = (window.navigator.onLine == true);
      return online;
    }
    catch(e)
    {
      Log().info("Error checking navigator online status. Error is ${e}");
      return false;
    }
  }
}