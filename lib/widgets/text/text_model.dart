// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:math';

import 'package:fml/log/manager.dart';
import 'package:flutter/material.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/reactive/reactive_view.dart';
import 'package:fml/widgets/span/span_model.dart';
import 'package:fml/widgets/viewable/viewable_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/widgets/text/text_view.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

class TextModel extends ViewableModel {
  @override
  FlexFit? get flexFit {
    return super.flexFit ?? FlexFit.loose;
  }

  String? markup;

  // value
  StringObservable? _value;

  set value(dynamic v) {
    if (_value != null) {
      _value!.set(v);
    } else {
      if ((v != null) ||
          (Model.isBound(this, Binding.toKey(id, 'value')))) {
        _value = StringObservable(Binding.toKey(id, 'value'), v,
            scope: scope, listener: onPropertyChange);
      }
    }
  }

  String? get value => _value?.get();
  bool addWhitespace = false;

  // size
  bool _sizeIsPercent = false;
  DoubleObservable? _size;
  set size(dynamic v) {
    if (_size != null) {
      _size!.set(v);
      width = v;
    } else if (v != null) {
      if (isPercent(v)) {
        _sizeIsPercent = true;
        v = v.split("%")[0];
      }
      _size = DoubleObservable(Binding.toKey(id, 'size'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double? get size {
    double? s = _size?.get();
    if (s == null) return null;
    if (_sizeIsPercent == true) {
      var width = calculatedMaxHeightForPercentage * (s / 100.0);
      var height = myMaxWidthForPercentage * (s / 100.0);
      s = max(width, height);
    }
    return s;
  }

  // outline color
  ColorObservable? _outlinecolor;

  set outlinecolor(dynamic v) {
    if (_outlinecolor != null) {
      _outlinecolor!.set(v);
    } else if (v != null) {
      _outlinecolor = ColorObservable(Binding.toKey(id, 'outlinecolor'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  Color? get outlinecolor => _outlinecolor?.get();

  // outline size
  DoubleObservable? _outline;

  set outline(dynamic v) {
    if (_outline != null) {
      _outline!.set(v);
    } else if (v != null) {
      _outline = DoubleObservable(Binding.toKey(id, 'outline'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double get outline => _outline?.get() ?? 1;

  /// shadow attributes
  ///
  /// the color of the elevation shadow, defaults to black26
  ColorObservable? _shadowcolor;

  set shadowcolor(dynamic v) {
    if (_shadowcolor != null) {
      _shadowcolor!.set(v);
    } else if (v != null) {
      _shadowcolor = ColorObservable(Binding.toKey(id, 'shadowcolor'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  Color? get shadowcolor => _shadowcolor?.get();

  /// the elevation of the box. The blur radius is 2* the elevation. This is combined with the offsets when constraining the size.
  DoubleObservable? _elevation;

  set elevation(dynamic v) {
    if (_elevation != null) {
      _elevation!.set(v);
    } else if (v != null) {
      _elevation = DoubleObservable(Binding.toKey(id, 'elevation'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double get elevation => _elevation?.get() ?? 0;

  /// The x offset of the box FROM the shadow. 0,0 is center. This is combined with `elevation` when determining the size.
  DoubleObservable? _shadowx;
  set shadowx(dynamic v) {
    if (_shadowx != null) {
      _shadowx!.set(v);
    } else if (v != null) {
      _shadowx = DoubleObservable(Binding.toKey(id, 'shadowx'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double? get shadowx => _shadowx?.get() ?? 2;

  /// The x offset of the box FROM the shadow. 0,0 is center. This is combined with `elevation` when determining the size.
  DoubleObservable? _shadowy;

  set shadowy(dynamic v) {
    if (_shadowy != null) {
      _shadowy!.set(v);
    } else if (v != null) {
      _shadowy = DoubleObservable(Binding.toKey(id, 'shadowy'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double? get shadowy => _shadowy?.get() ?? 2;

  // font
  StringObservable? _font;

  set font(dynamic v) {
    if (_font != null) {
      _font!.set(v);
    } else if (v != null) {
      _font = StringObservable(Binding.toKey(id, 'font'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String? get font => _font?.get() ?? System.theme.font;

  // weight
  IntegerObservable? _weight;
  set weight(dynamic v) {
    if (_weight != null) {
      _weight!.set(v);
    } else if (v != null) {
      _weight = IntegerObservable(Binding.toKey(id, 'weight'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  int? get weight => _weight?.get();

  // If the text is raw or uses special chars
  BooleanObservable? _raw;
  set raw(dynamic v) {
    if (_raw != null) {
      _raw!.set(v);
    } else if (v != null) {
      _raw = BooleanObservable(Binding.toKey(id, 'raw'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool get raw => _raw?.get() ?? false;

  // If the text is selectable defaults to false
  BooleanObservable? _selectable;
  set selectable(dynamic v) {
    if (_selectable != null) {
      _selectable!.set(v);
    } else if (v != null) {
      _selectable = BooleanObservable(Binding.toKey(id, 'selectable'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool get selectable => _selectable?.get() ?? false;

  // bold font
  BooleanObservable? _bold;
  set bold(dynamic v) {
    if (_bold != null) {
      _bold!.set(v);
    } else if (v != null) {
      _bold = BooleanObservable(Binding.toKey(id, 'bold'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool get bold => _bold?.get() ?? false;

  // italic font
  BooleanObservable? _italic;
  set italic(dynamic v) {
    if (_italic != null) {
      _italic!.set(v);
    } else if (v != null) {
      _italic = BooleanObservable(Binding.toKey(id, 'italic'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool get italic => _italic?.get() ?? false;

  // font theme
  StringObservable? _theme;
  set theme(dynamic v) {
    if (_theme != null) {
      _theme!.set(v);
    } else if (v != null) {
      _theme = StringObservable(Binding.toKey(id, 'theme'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String? get theme => _theme?.get();

  // font style
  StringObservable? _style;
  set style(dynamic v) {
    if (_style != null) {
      _style!.set(v);
    } else if (v != null) {
      _style = StringObservable(Binding.toKey(id, 'style'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String? get style => _style?.get();

  // font decoration
  StringObservable? _decoration;
  set decoration(dynamic v) {
    if (_decoration != null) {
      _decoration!.set(v);
    } else if (v != null) {
      _decoration = StringObservable(Binding.toKey(id, 'decoration'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String? get decoration => _decoration?.get();

  // decorationweight
  DoubleObservable? _decorationweight;
  set decorationweight(dynamic v) {
    if (_decorationweight != null) {
      _decorationweight!.set(v);
    } else if (v != null) {
      _decorationweight = DoubleObservable(
          Binding.toKey(id, 'decorationweight'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double? get decorationweight => _decorationweight?.get();

  // decoration color
  ColorObservable? _decorationcolor;
  set decorationcolor(dynamic v) {
    if (_decorationcolor != null) {
      _decorationcolor!.set(v);
    } else if (v != null) {
      _decorationcolor = ColorObservable(
          Binding.toKey(id, 'decorationcolor'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  Color? get decorationcolor => _decorationcolor?.get();

  // decorationstyle
  StringObservable? _decorationstyle;
  set decorationstyle(dynamic v) {
    if (_decorationstyle != null) {
      _decorationstyle!.set(v);
    } else if (v != null) {
      _decorationstyle = StringObservable(
          Binding.toKey(id, 'decorationstyle'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String? get decorationstyle => _decorationstyle?.get();

  // wordspacing
  DoubleObservable? _wordspace;

  set wordspace(dynamic v) {
    if (_wordspace != null) {
      _wordspace!.set(v);
    } else if (v != null) {
      _wordspace = DoubleObservable(Binding.toKey(id, 'wordspace'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double? get wordspace => _wordspace?.get();

  // letterspacing
  DoubleObservable? _letterspace;
  set letterspace(dynamic v) {
    if (_letterspace != null) {
      _letterspace!.set(v);
    } else if (v != null) {
      _letterspace = DoubleObservable(Binding.toKey(id, 'letterspace'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double get letterspace => _letterspace?.get() ?? 0;

  // lineheight
  DoubleObservable? _lineheight;

  set lineheight(dynamic v) {
    if (_lineheight != null) {
      _lineheight!.set(v);
    } else if (v != null) {
      _lineheight = DoubleObservable(Binding.toKey(id, 'lineheight'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double? get lineheight => _lineheight?.get();

  // overflow
  StringObservable? _overflow;
  set overflow(dynamic v) {
    if (_overflow != null) {
      _overflow!.set(v);
    } else if (v != null) {
      _overflow = StringObservable(Binding.toKey(id, 'overflow'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String? get overflow => _overflow?.get();

  TextModel(
    super.parent,
    super.id, {
    dynamic value,
    dynamic size,
    dynamic color,
    dynamic outline,
    dynamic outlinecolor,
    dynamic elevation,
    dynamic shadowcolor,
    dynamic shadowx,
    dynamic shadowy,
    dynamic font,
    dynamic weight,
    dynamic bold,
    dynamic italic,
    dynamic width,
    dynamic theme,
    dynamic decoration,
    dynamic decorationcolor,
    dynamic decorationstyle,
    dynamic decorationweight,
    dynamic wordspace,
    dynamic letterspace,
    dynamic lineheight,
    dynamic raw,
    dynamic selectable,
    dynamic valign,
    dynamic overflow,
    dynamic halign,
    dynamic style,
  }) {
    if (value != null) this.value = value;
    if (size != null) this.size = size;
    if (color != null) this.color = color;
    if (outline != null) this.outline = outline;
    if (outlinecolor != null) this.outlinecolor = outlinecolor;
    if (elevation != null) this.elevation = elevation;
    if (shadowcolor != null) this.shadowcolor = shadowcolor;
    if (shadowx != null) this.shadowx = shadowx;
    if (shadowy != null) this.shadowy = shadowy;
    if (font != null) this.font = font;
    if (weight != null) this.weight = weight;
    if (bold != null) this.bold = bold;
    if (italic != null) this.italic = italic;
    if (width != null) this.width = width;
    if (theme != null) this.theme = theme;
    if (decoration != null) this.decoration = decoration;
    if (decorationcolor != null) this.decorationcolor = decorationcolor;
    if (decorationstyle != null) this.decorationstyle = decorationstyle;
    if (decorationweight != null) this.decorationweight = decorationweight;
    if (wordspace != null) this.wordspace = wordspace;
    if (letterspace != null) this.letterspace = letterspace;
    if (lineheight != null) this.lineheight = lineheight;
    if (valign != null) this.valign = valign;
    if (overflow != null) this.overflow = overflow;
    if (halign != null) this.halign = halign;
    if (style != null) this.style = style;
    if (raw != null) this.raw = raw;
    if (selectable != null) this.selectable = selectable;
  }

  static TextModel? fromXml(Model parent, XmlElement xml) {
    TextModel? model;
    try {
      model = TextModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'text.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {
    // deserialize
    super.deserialize(xml);

    String? textvalue = Xml.get(node: xml, tag: 'value');
    textvalue ??= Xml.get(node: xml, tag: 'label');
    textvalue ??= Xml.getText(xml);

    // properties
    value = textvalue;
    size = Xml.get(node: xml, tag: 'size');
    outlinecolor = Xml.get(node: xml, tag: 'outlinecolor');
    outline = Xml.get(node: xml, tag: 'outline');

    shadowcolor = Xml.get(node: xml, tag: 'shadowcolor');
    elevation = Xml.get(node: xml, tag: 'elevation');
    shadowx = Xml.get(node: xml, tag: 'shadowx');
    shadowy = Xml.get(node: xml, tag: 'shadowy');

    font = Xml.get(node: xml, tag: 'font');
    weight = Xml.get(node: xml, tag: 'weight');
    bold = Xml.get(node: xml, tag: 'bold');
    italic = Xml.get(node: xml, tag: 'italic');
    theme = Xml.get(node: xml, tag: 'theme');

    decoration = Xml.get(node: xml, tag: 'decoration');
    decorationcolor = Xml.get(node: xml, tag: 'decorationcolor');
    decorationstyle = Xml.get(node: xml, tag: 'decorationstyle');
    decorationweight = Xml.get(node: xml, tag: 'decorationweight');

    wordspace = Xml.get(node: xml, tag: 'wordspace');
    letterspace = Xml.get(node: xml, tag: 'letterspace');
    lineheight = Xml.get(node: xml, tag: 'lineheight');

    overflow = Xml.get(node: xml, tag: 'overflow');
    style = Xml.get(node: xml, tag: 'style');
    raw = Xml.get(node: xml, tag: 'raw');
    selectable = Xml.get(node: xml, tag: 'selectable');
  }

  bool get isSpan => (parent is SpanModel);

  @override
  Widget getView({Key? key}) {
    var view = TextView(this);
    return isReactive ? ReactiveView(this, view) : view;
  }
}
