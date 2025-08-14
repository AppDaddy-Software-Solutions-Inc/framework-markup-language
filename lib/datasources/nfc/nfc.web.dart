// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'nfc_listener_interface.dart';
import 'payload.dart';

class Reader {

  static final Reader _singleton = Reader._initialize();
  bool stop = false;

  List<INfcListener>? _listeners;

  factory Reader() {
    return _singleton;
  }

  Reader._initialize();

  bool polling = false;
  int a = 0;

  read() async {
      polling = false;
  }

  registerListener(INfcListener listener) {
    _listeners ??= [];
    if (!_listeners!.contains(listener)) _listeners!.add(listener);
    read();
  }

  removeListener(INfcListener listener) {
    if ((_listeners != null) && (_listeners!.contains(listener))) {
      _listeners!.remove(listener);
      if (_listeners!.isEmpty) _listeners = null;
    }
  }

  notifyListeners(Payload data) {
    if (_listeners != null) {
      var listeners = _listeners!.where((element) => true);
      for (var listener in listeners) {
        listener.onMessage(data);
      }
    }
  }

  Future<String?> readNFCTag(dynamic tag) async {
    return null;
  }
}

class Writer {
  Function? callback;
  String value;
  Writer(this.value, {this.callback});

  Future<bool> write() async {
    return false;
  }
}

class CustomException {
  final int? code;
  final String? message;
  const CustomException({this.code, this.message = ""});
}
