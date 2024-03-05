import 'package:flutter/material.dart';
import 'package:fml/helpers/helpers.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/widgets/form/form_field_model.dart';
import 'package:xml/xml.dart';

class DecoratedInputModel extends FormFieldModel
{
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
  set hint(dynamic v)
  {
    if (_hint != null)
    {
      _hint!.set(v);
    }
    else if (v != null)
    {
      _hint = StringObservable(Binding.toKey(id, 'hint'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get hint => _hint?.get();

  /// The color of the text. Can be an array of 3 colors seperated by commas for enabled, disabled, and error.
  ColorObservable? _textcolor;
  set textcolor(dynamic v) {
    if (_textcolor != null) {
      _textcolor!.set(v);
    } else if (v != null) {
      _textcolor = ColorObservable(Binding.toKey(id, 'textcolor'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  Color? get textcolor => _textcolor?.get();

  /// The weight of the font
  StringObservable? _weight;
  set weight(dynamic v)
  {
    if (_weight != null)
    {
      _weight!.set(v);
    }
    else if (v != null)
    {
      _weight = StringObservable(Binding.toKey(id, 'weight'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get weight => _weight?.get();

  /// The style of the font. Will override weight and size.
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

  /// The radius of the border if all.
  DoubleObservable? _radius;
  set radius(dynamic v)
  {
    if (_radius != null)
    {
      _radius!.set(v);
    }
    else if (v != null)
    {
      _radius = DoubleObservable(Binding.toKey(id, 'radius'), v, scope: scope, listener: onPropertyChange);
    }
  }
  double get radius => _radius?.get() ?? 5;

  /// The color of the border for input, defaults to black54. Accepts 4 colors positionally. Enabled, disabled, focused, and error colors.
  ColorObservable? _borderColor;
  set borderColor(dynamic v)
  {
    if (_borderColor != null) {
      _borderColor!.set(v);
    } else if (v != null) {
      _borderColor = ColorObservable(Binding.toKey(id, 'bordercolor'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  Color? get borderColor => _borderColor?.get();

  /// The width of the containers border, defaults to 2
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
  String? get border {
    if (_border == null) return 'all';
    return _border!.get()?.toLowerCase();
  }

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

  // label
  StringObservable? _label;
  set label(dynamic v) {
    if (_label != null) {
      _label!.set(v);
    } else if (v != null) {
      _label = StringObservable(Binding.toKey(id, 'label'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String? get label => _label?.get();

  // font size
  DoubleObservable? _size;
  set size(dynamic v) {
    if (_size != null) {
      _size!.set(v);
    } else {
      if (v != null) {
        _size = DoubleObservable(Binding.toKey(id, 'size'), v,
            scope: scope, listener: onPropertyChange);
      }
    }
  }
  double? get size => _size?.get() ?? 14;

  DecoratedInputModel(super.parent, super.id,
  {
    dynamic width,
    dynamic hint,
    dynamic expand,
    dynamic color,
    dynamic size,
    dynamic weight,
    dynamic style,
    dynamic padding,
    dynamic icon,
    dynamic dense,
    dynamic border,
    dynamic radius,
    dynamic borderColor,
    dynamic borderWidth,
    dynamic textcolor,
    dynamic label,

  })
  {
    if (width != null) this.width = width;
    if (hint != null) this.hint = hint;
    if (expand != null) this.expand = expand;
    if (color != null) this.color = color;
    if (width != null) this.width = width;
    if (hint != null) this.hint = hint;
    if (size != null) this.size = size;
    if (weight != null) this.weight = weight;
    if (style != null) this.style = style;
    if (padding != null) margins = padding;
    if (icon != null) this.icon = icon;
    if (dense != null) this.dense = dense;
    if (border != null) this.border = border;
    if (radius != null) this.radius = radius;
    if (borderColor != null) this.borderColor = borderColor;
    if (borderWidth != null) this.borderWidth = borderWidth;
    if (textcolor != null) this.textcolor = textcolor;
    if (label != null) this.label = label;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {
    // deserialize
    super.deserialize(xml);

    hint = Xml.get(node: xml, tag: 'hint');
    border = Xml.get(node: xml, tag: 'border');
    borderColor = Xml.get(node: xml, tag: 'bordercolor');
    borderWidth = Xml.get(node: xml, tag: 'borderwidth');
    radius = Xml.get(node: xml, tag: 'radius');
  }

  //set the field color based on the error state

  Color getFieldColor(BuildContext context) {
    // user defined
    if (color != null) return color!;

    if (enabled && border != 'all')
    {
      return color ?? Theme.of(context).colorScheme.surfaceVariant;
    }

    if (border == 'all')
    {
      return color ?? Colors.transparent;
    }

    return color ?? Theme.of(context).colorScheme.primary.withOpacity(0.5);
  }

  //set the field color based on the error state
  Color getErrorHintColor(BuildContext context, {Color? color})
  {
    // disabled
    if (!enabled) return Theme.of(context).colorScheme.primary.withOpacity(0.5);

    // alarm
    if (!isNullOrEmpty(alarmText)) return Theme.of(context).colorScheme.error;

    // user defined
    if (color != null) return color;

    // default color
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }
}