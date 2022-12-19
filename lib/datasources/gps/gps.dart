// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'iGpsListener.dart';
import 'gps.mobile.dart'
if (dart.library.io)   'gps.mobile.dart'
if (dart.library.html) 'gps.web.dart';

abstract class Gps
{
  factory Gps() => getReceiver();
  registerListener(IGpsListener listener);
  removeListener(IGpsListener listener);
}