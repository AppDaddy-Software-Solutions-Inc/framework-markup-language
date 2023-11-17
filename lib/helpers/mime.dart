import 'package:mime/mime.dart' deferred as mime;

class Mime
{
  static bool _libraryLoaded = false;

  static Future<String> type(String path, {String defaultType = ""}) async {
    String type;
    try {
      if (!_libraryLoaded) {
        await mime.loadLibrary();
        _libraryLoaded = true;
      }
      type = mime.lookupMimeType(path) ?? defaultType;
    } catch (e) {
      type = defaultType;
    }
    return type;
  }

  /// makes a filename safe
  static String toSafeFileName(String filename,
      {String separator = '-',
        bool withSpaces = false,
        bool lowercase = false,
        bool onlyAlphanumeric = false}) {
    final List<String> reservedCharacters = [
      '?',
      ':',
      '"',
      '*',
      '|',
      '/',
      '\\',
      '<',
      '>',
      '+',
      '[',
      ']'
    ];
    final RegExp onlyAlphanumericRegex = RegExp(r'''[^a-zA-Z0-9\s.]''');
    String returnString = filename;
    if (onlyAlphanumeric) {
      returnString = returnString.replaceAll(onlyAlphanumericRegex, '');
    } else {
      for (var c in reservedCharacters) {
        returnString = returnString.replaceAll(c, separator);
      }
    }
    if (!withSpaces) returnString = returnString.replaceAll(' ', separator);
    return lowercase ? returnString.toLowerCase() : returnString;
  }
}
