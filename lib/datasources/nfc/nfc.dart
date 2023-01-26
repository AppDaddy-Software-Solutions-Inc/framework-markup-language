// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/services.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:fml/models/custom_exception.dart';
import 'package:ndef/ndef.dart' as ndef;
import 'package:fml/log/manager.dart';
import 'iNfcListener.dart';
import 'payload.dart';

class Reader
{
  static final Reader _singleton = new Reader._initialize();
  bool stop = false;

  List<INfcListener>? _listeners;

  factory Reader()
  {
    return _singleton;
  }

  Reader._initialize();

  bool polling = false;
  int a = 0;

  read() async
  {
    bool stopPoll = false;
    while (_listeners != null && _listeners!.isNotEmpty && !polling && !stopPoll)
    {
      try {
        Log().debug('NFC READ: Polling...');
        polling = true;
        NFCTag tag = await FlutterNfcKit.poll();
        Log().debug('NFC: Done Polling...');

        // read the tag
        String? result = await readNFCTag(tag);

        if (result != null)
        {
          // ??
          await FlutterNfcKit.finish(iosAlertMessage: "Finished!");

          // debug
          Log().debug('NFC: Read Result'
              '\nID: ${tag.id}'
              '\nStandard: ${tag.standard}'
              '\nType: ${tag.type}'
              '\nATQA: ${tag.atqa}'
              '\nSAK: ${tag.sak}'
              '\nHistorical Bytes: ${tag.historicalBytes}'
              '\nProtocol Info: ${tag.protocolInfo}'
              '\nApplication Data: ${tag.applicationData}'
              '\nHigher Layer Response: ${tag.hiLayerResponse}'
              '\nManufacturer: ${tag.manufacturer}'
              '\nSystem Code: ${tag.systemCode}'
              '\nDSF ID: ${tag.dsfId}'
              '\nNDEF Available: ${tag.ndefAvailable}'
              '\nNDEF Type: ${tag.ndefType}'
              '\nNDEF Writable: ${tag.ndefWritable}'
              '\nNDEF Can Make Read Only: ${tag.ndefCanMakeReadOnly}'
              '\nNDEF Capacity: ${tag.ndefCapacity}'
              '\nTransceive Result:\n$result');

          // format result
          if (result.indexOf("text=") >= 0) result = result.substring(result.indexOf('text=')+5);

          // notify
          notifyListeners(Payload(id: tag.id, message: result));
        }
        else
          Log().debug('NFC: result is null');
      }
        catch(e)
      {
        if (e.toString() == '408' && e.toString() == 'Polling tag timeout')
          Log().debug('NFC: ...Timeout');
        else if (e.toString() == '409') {
          Log().debug('Polling Loop Ended via result or cancel');
          stopPoll = true;
        }
        else
          Log().debug('NFC ERROR: $e');
      }
      polling = false;
    }
  }

  registerListener(INfcListener listener)
  {
    if (_listeners == null) _listeners = [];
    if (!_listeners!.contains(listener)) _listeners!.add(listener);
    read();
  }

  removeListener(INfcListener listener)
  {
    if ((_listeners != null) && (_listeners!.contains(listener)))
    {
      _listeners!.remove(listener);
      if (_listeners!.isEmpty) _listeners = null;
    }
  }

  notifyListeners(Payload data)
  {
    if (_listeners != null)
    {
      var listeners = _listeners!.where((element) => true);
      listeners.forEach((listener) => listener.onMessage(data));
    }
  }

  Future<String?> readNFCTag(NFCTag tag) async {
    try {
      await FlutterNfcKit.setIosAlertMessage(
          "Working on it...");
      if (tag.type == NFCTagType.iso15693) {
        var ndefRecords = await FlutterNfcKit.readNDEFRecords();
        var ndefString = ndefRecords
            .map((r) => r.toString())
            .reduce((value, element) => value + "\n" + element);
        return ndefString;
      } else if (tag.standard == "ISO 14443-4 (Type B)") {
        String result1 = await FlutterNfcKit.transceive("00B0950000");
        String result2 = await FlutterNfcKit.transceive("00A4040009A00000000386980701");
          return '$result1 $result2';
      } else if (tag.type == NFCTagType.iso18092) {
        return await FlutterNfcKit.transceive("060080080100");
      } else if (tag.type == NFCTagType.mifare_ultralight ||
          tag.type == NFCTagType.mifare_classic) {
        var ndefRecords = await FlutterNfcKit.readNDEFRecords();
        var ndefString = ndefRecords
            .map((r) => r.toString())
            .reduce((value, element) => value + "\n" + element);
        return ndefString;
      } else if (tag.type == NFCTagType.webusb) {
        return await FlutterNfcKit.transceive("00A4040006D27600012401");
      }
    }
    catch (e)
    {
      Log().exception(e, caller: 'nfc.dart: Reader.readNFCTag()');
      return null;
    }
    Log().debug('Unhandled NFC tag type');
    Log().warning('Unhandled NFC tag type', caller: 'nfc.dart: Reader.readNFCTag()');
    return null;
  }

}

class Writer
{
  bool stop = false;

  Function? callback;
  String value;
  Writer(this.value, {this.callback});

  Future<bool> write() async
  {
    stop = false;
    Log().debug("Attempting Write to NDEF NFC Tag");
    ndef.NDEFRecord record = ndef.TextRecord(encoding: ndef.TextEncoding.values[0], language: 'en', text: value);
    try {
      NFCTag tag = await FlutterNfcKit.poll(timeout: Duration(seconds: 60));
      if (tag.type == NFCTagType.mifare_ultralight || tag.type == NFCTagType.mifare_classic || tag.type == NFCTagType.iso15693)
      {
        Log().debug('Writing $value to NFC Tag...');
        try
        {
          await FlutterNfcKit.writeNDEFRecords([record]);
          await FlutterNfcKit.finish();
          Log().debug('NFC Write Successful');
          return true;
        }
        catch(e)
        {
          Log().error('NFC Write Unsuccessful');
          Log().exception(e, caller: 'nfc.dart: Writer.write() - write fail');
          return false;
        }
      }
      return false;
    } on PlatformException catch(e){
      // throw a custom exception on timeout with a message.
      if (e.code == "408") throw CustomException(code: 408, message: 'Poll Timed Out');
      else return false;
    }
    return false;

  }
}
