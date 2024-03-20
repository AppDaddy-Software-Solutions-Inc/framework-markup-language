// // © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
// import 'dart:async';
// import 'dart:isolate';
// import 'package:fml/log/manager.dart';
//
// class PostMaster
// {
//   static final PostMaster _singleton = PostMaster._initialize();
//
//   SendPort? _sendPort;
//   ReceivePort _receivePort = ReceivePort();
//
//   Isolate?  isolate;
//
//   factory PostMaster()
//   {
//     return _singleton;
//   }
//
//   PostMaster._initialize()
//   {
//     _init();
//   }
//
//   Future<bool> _init() async
//   {
//     _create();
//     return true;
//   }
//
//   void _create() async
//   {
//     ////////////////////
//     /* Create Isolate */
//     ////////////////////
//     isolate = await Isolate.spawn(PostMasterService.main, _receivePort.sendPort);
//
//     //////////////////////////////////////////////
//     /* Retrieve the port to be used for further */
//     /* communication                            */
//     //////////////////////////////////////////////
//     _sendPort = _receivePort.first as SendPort?;
//
//     /////////////////////////
//     /* Listen for Messages */
//     /////////////////////////
//     _receivePort.listen(onMessage);
//   }
//
//   onMessage(dynamic message)
//   {
//     Log().debug(message);
//   }
//
//   void dispose()
//   {
//     isolate?.kill(priority: Isolate.immediate);
//     isolate = null;
//   }
//
//   void send(String message) async
//   {
//     if (_sendPort != null)
//     {
//       _sendPort!.send(Message<String>(transaction: "Start", message: message));
//     }
//   }
// }
//
// class PostMasterService
// {
//   static late SendPort  _sendPort;
//   static ReceivePort _receivePort = ReceivePort();
//
//   static void main(SendPort applicationReceivePort)
//   {
//     _receivePort.listen(onMessage);
//     _sendPort = applicationReceivePort;
//     _sendPort.send(_receivePort.sendPort);
//   }
//
//   static onMessage(dynamic message)
//   {
//     // Message msg = message as Message;
//     doPost();
//     _receivePort.listen(onMessage);
//   }
//
//   static doPost() async
//   {
//     //List<Form> list = await FormList.findForms();
//   }
// }
//
// class Message<T>
// {
//   final T transaction;
//   final T? message;
//   Message({required this.transaction, this.message});
// }
