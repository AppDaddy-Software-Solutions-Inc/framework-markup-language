// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:ui';
import 'package:fml/log/manager.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart' as mlkit;
import 'text_detector.dart';

class LineRow {
  List<mlkit.TextElement> words = [];

  LineRow(List<mlkit.TextElement> e) {
    words = e;
  }
}

TextDetector getDetector() => TextDetector();

class TextDetector implements ITextDetector {
  static final TextDetector _singleton = TextDetector._initialize();

  static late dynamic _detector;

  factory TextDetector() {
    return _singleton;
  }

  TextDetector._initialize();

  @override
  Future<Payload?> detect(dynamic detectable) async {
    try {
      Payload? result;

      if (detectable?.image is mlkit.InputImage) {
        var image = detectable.image;

        // process the image
        var text = await _detector.processImage(image);

        // return result
        result = payload(text);
      }

      return result;
    } catch (e) {
      Log().exception(e);
      return null;
    }
  }

  Payload payload(mlkit.RecognizedText vtext) {
    List<Line> lines = [];
    // BASIC LINE DETECTION
    // for (TextBlock block in vtext.blocks)
    // {
    //   final Rect         boundingBox  = block.boundingBox;
    //   final List<Offset> cornerPoints = block.cornerPoints;
    //   final String       text = block.text;
    //   final List<RecognizedLanguage> languages = block.recognizedLanguages;
    //   for (TextLine line in block.lines)
    //   {
    //     Line oLine = Line(text: line.text);
    //     lines.add(oLine);
    //     for (TextElement element in line.elements) oLine.words.add(element.text);
    //   }
    // }

    // ADVANCED LINE DETECTION
    List<LineRow> ocrLines = [];

    // Go through all the blocks
    for (mlkit.TextBlock block in vtext.blocks) {
      // Go through all lines
      for (mlkit.TextLine line in block.lines) {
        // Go through all elements(words)
        for (mlkit.TextElement element in line.elements) {
          // String text = element.text;
          Rect box = element.boundingBox;
          // Offset topLeft = box.topLeft;
          // Offset topRight = box.topRight;
          // Offset bottomLeft = box.bottomLeft;
          // Offset bottomRight = box.bottomRight;
          double y1 = box.top;
          double y2 = box.bottom;
          // double x1 = box.left;
          double x2 = box.right;

          bool foundLine = false;
          // loop through ocrLines > LineRow
          // see if element belongs vertically in the index or before it
          // if so add it and then find where it belongs horizontally
          // within the line elements left of each index or added to the end

          for (int i = 0; i < ocrLines.length; i++) {
            // Determine which line the element belongs to
            double y1Ocr = ocrLines[i].words[0].boundingBox.top;
            double y2Ocr = ocrLines[i].words[0].boundingBox.bottom;
            // ensure the top is above the lowest line point and the bottom is below the highest line point
            if (y1 < y2Ocr && y2 > y1Ocr) {
              foundLine = true;
              // Determine where to place the element in the line
              if (ocrLines[i].words.isEmpty) {
                ocrLines[i].words.add(element);
              } else {
                bool foundWord = false;
                for (int j = 0; j < ocrLines[i].words.length; j++) {
                  double x1Ocr = ocrLines[i].words[j].boundingBox.left;
                  // double x2Ocr = ocrLines[i].words[j].boundingBox.right;
                  // Determine if the element comes before the current word
                  if (x2 < x1Ocr) {
                    foundWord = true;
                    ocrLines[i].words.insert(j, element);
                    j = ocrLines[i].words.length + 1;
                  }
                }
                if (foundWord == false) {
                  ocrLines[i].words.add(element);
                }
                i = ocrLines.length + 1;
              }
            }
            // If our bottom is less than this line's top we need a new LineRow entry
            else if (y2 < y1Ocr) {
              foundLine = true;
              ocrLines.insert(i, LineRow([element]));
              i = ocrLines.length + 1;
            }
          }
          // Line didn't fit between so add new
          if (foundLine == false) {
            ocrLines.add(LineRow([element]));
          }
        }
      }
    }

    String body = '';
    for (var l in ocrLines) {
      String text = '';
      List<String> words = [];
      for (var t in l.words) {
        words.add(t.text.trim());
        text += ' ${t.text}';
      }
      text.replaceAll('  ', ' ');
      text.trim();
      body += '\n$text';
      Line line = Line(text: text);
      line.words.addAll(words);
      lines.add(line);
    }

    return Payload(body: body, lines: lines);
  }
}
