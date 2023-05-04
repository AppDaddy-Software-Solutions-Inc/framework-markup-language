// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
abstract class ISocketListener
{
  onMessage(String message);
  onConnected();
  onDisconnected(int? code, String? message);
  onError(String error);
}