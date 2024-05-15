import 'package:flutter/material.dart';
import 'package:fml/helpers/helpers.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/widgets/form/form_field_model.dart';
import 'package:xml/xml.dart';

class DecoratedInputModel extends FormFieldModel {
  // override padding
  @override
  double? get marginTop => super.marginTop ?? (dense ? 0 : 4);

  @override
  double? get marginBottom => super.marginBottom ?? (dense ? 0 : 4);

  @override
  double? get marginLeft => super.marginLeft ?? (dense ? 0 : 4);

  @override
  double? get marginRight => super.marginRight ?? (dense ? 0 : 4);

  /// If the input excludes the label above, and minimises the vertical space it takes up.
  BooleanObservable? _dense;
  set dense(dynamic v) {
    if (_dense != null) {
      _dense!.set(v);
    } else if (v != null) {
      _dense = BooleanObservable(Binding.toKey(id, 'dense'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  bool get dense => _dense?.get() ?? false;

  /// The hint that sits inside of the input, and floats above if not dense and filled.
  StringObservable? _hint;
  set hint(dynamic v) {
    if (_hint != null) {
      _hint!.set(v);
    } else if (v != null) {
      _hint = StringObservable(Binding.toKey(id, 'hint'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String? get hint => _hint?.get();

  /// The font size of the text.
  DoubleObservable? _textSize;
  set textSize(dynamic v) {
    if (_textSize != null) {
      _textSize!.set(v);
    } else {
      if (v != null) {
        _textSize = DoubleObservable(Binding.toKey(id, 'size'), v,
            scope: scope, listener: onPropertyChange);
      }
    }
  }
  double get textSize => _textSize?.get() ?? 14;

  /// The color of the text. Can be an array of 3 colors seperated by commas for enabled, disabled, and error.
  ColorObservable? _textColor;
  set textColor(dynamic v) {
    if (_textColor != null) {
      _textColor!.set(v);
    } else if (v != null) {
      _textColor = ColorObservable(Binding.toKey(id, 'textcolor'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  Color? get textColor => _textColor?.get();

  /// The weight of the font
  StringObservable? _textWeight;
  set textWeight(dynamic v) {
    if (_textWeight != null) {
      _textWeight!.set(v);
    } else if (v != null) {
      _textWeight = StringObservable(Binding.toKey(id, 'weight'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String? get textWeight => _textWeight?.get();

  /// The style of the font. Will override weight and size.
  StringObservable? _textStyle;
  set textStyle(dynamic v) {
    if (_textStyle != null) {
      _textStyle!.set(v);
    } else if (v != null) {
      _textStyle = StringObservable(Binding.toKey(id, 'style'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get textStyle => _textStyle?.get();

  /// The prefix icon within the input
  IconObservable? _icon;
  set icon(dynamic v) {
    if (_icon != null) {
      _icon!.set(v);
    } else if (v != null) {
      _icon = IconObservable(Binding.toKey(id, 'icon'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  IconData? get icon => _icon?.get();

  /// The border choice, can be `all`, `none`, `top`, `left`, `right`, `bottom`, `vertical`, or `horizontal`
  StringObservable? _border;
  set border(dynamic v) {
    if (_border != null) {
      _border!.set(v);
    } else if (v != null) {
      _border = StringObservable(Binding.toKey(id, 'border'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String get border => _border?.get()?.toLowerCase() ?? 'all';

  /// The color of the border for box, defaults to black54
  ColorObservable? _borderColor;
  set borderColor(dynamic v) {
    if (_borderColor != null) {
      _borderColor!.set(v);
    } else if (v != null) {
      _borderColor = ColorObservable(Binding.toKey(id, 'bordercolor'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  Color? get borderColor => _borderColor?.get();

  /// The width of the containers border, defaults to 1
  DoubleObservable? _borderWidth;
  set borderWidth(dynamic v) {
    if (_borderWidth != null) {
      _borderWidth!.set(v);
    } else if (v != null) {
      _borderWidth = DoubleObservable(Binding.toKey(id, 'borderwidth'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  double get borderWidth => _borderWidth?.get() ?? 1;

  /// The radius of the containers border, defaults to 5
  DoubleObservable? _radius;
  set radius(dynamic v) {
    if (_radius != null) {
      _radius!.set(v);
    } else if (v != null) {
      _radius = DoubleObservable(Binding.toKey(id, 'radius'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  double get radius => _radius?.get() ?? 5;

  BooleanObservable? _expand;
  set expand(dynamic v) {
    if (_expand != null) {
      _expand!.set(v);
    } else if (v != null) {
      _expand = BooleanObservable(Binding.toKey(id, 'expand'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  bool get expand => _expand?.get() ?? false;

  DecoratedInputModel(
    super.parent,
    super.id, {
    dynamic width,
    dynamic hint,
    dynamic expand,
    dynamic color,
    dynamic textSize,
    dynamic textColor,
    dynamic textWeight,
    dynamic textStyle,
    dynamic padding,
    dynamic icon,
    dynamic dense,
    dynamic border,
    dynamic radius,
    dynamic borderColor,
    dynamic borderWidth,
    dynamic label,
  }) {

    if (width != null) this.width = width;
    if (hint != null) this.hint = hint;
    if (expand != null) this.expand = expand;
    if (color != null) this.color = color;

    // text properties
    if (textSize != null) this.textSize = textSize;
    if (textColor != null) this.textColor = textColor;
    if (textWeight != null) this.textWeight = textWeight;
    if (textStyle != null) this.textStyle = textStyle;

    if (padding != null) margins = padding;
    if (icon != null) this.icon = icon;
    if (dense != null) this.dense = dense;

    // border properties
    if (border != null) this.border = border;
    if (radius != null) this.radius = radius;
    if (borderColor != null) this.borderColor = borderColor;
    if (borderWidth != null) this.borderWidth = borderWidth;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {

    // deserialize
    super.deserialize(xml);

    // font properties
    textSize   = Xml.get(node: xml, tag: 'textsize') ?? Xml.get(node: xml, tag: 'size');
    textColor  = Xml.get(node: xml, tag: 'textcolor');
    textWeight = Xml.get(node: xml, tag: 'textweight') ?? Xml.get(node: xml, tag: 'weight');
    textStyle  = Xml.get(node: xml, tag: 'textstyle') ?? Xml.get(node: xml, tag: 'style');

    // border / shape properties
    border = Xml.get(node: xml, tag: 'border');
    borderColor = Xml.get(node: xml, tag: 'bordercolor');
    borderWidth = Xml.get(node: xml, tag: 'borderwidth');
    radius = Xml.get(node: xml, tag: 'radius');

    // visual properties
    hint = Xml.get(node: xml, tag: 'hint');
    icon = Xml.get(node: xml, tag: 'icon');
    dense = Xml.get(node: xml, tag: 'dense');
  }

  // set the field color based on the error state
  Color getFieldColor(BuildContext context) {
    // user defined
    if (color != null) return color!;

    if (enabled && border != 'all') {
      return color ?? Theme.of(context).colorScheme.surfaceContainerHighest;
    }

    if (border == 'all') {
      return color ?? Colors.transparent;
    }

    return color ?? Theme.of(context).colorScheme.primary.withOpacity(0.5);
  }

  //set the field color based on the error state
  Color getErrorHintColor(BuildContext context, {Color? color}) {
    // disabled
    if (!enabled) return Theme.of(context).colorScheme.primary.withOpacity(0.5);

    // alarm
    if (!isNullOrEmpty(alarm)) return Theme.of(context).colorScheme.error;

    // user defined
    if (color != null) return color;

    // default color
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }
}
