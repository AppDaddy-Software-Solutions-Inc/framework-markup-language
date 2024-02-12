// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/decorated/decorated_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/theme/theme_view.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

class ThemeModel extends DecoratedWidgetModel 
{
  static String defaultBrightness = "light";
  static String defaultColor = "lightblue";

  static String myId = 'THEME';

  StringObservable? _brightness;
  set brightness(dynamic v) {
    if (_brightness != null) {
      _brightness!.set(v);
    } else if (v != null) {
      _brightness = StringObservable(Binding.toKey('brightness'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get brightness => _brightness?.get();

  ColorObservable? _colorscheme;
  set colorscheme(dynamic v) {
    if (_colorscheme != null) {
      _colorscheme!.set(v);
    } else if (v != null) {
      _colorscheme = ColorObservable(Binding.toKey('colorscheme'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get colorscheme => _colorscheme?.get();

  StringObservable? _font;
  set font(dynamic v) {
    if (_font != null) {
      _font!.set(v);
    } else if (v != null) {
      _font = StringObservable(Binding.toKey('font'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String get font => _font?.get() ?? 'Roboto';

  ColorObservable? _background;
  set background(dynamic v) {
    if (_background != null) {
      _background!.set(v);
    } else if (v != null) {
      _background = ColorObservable(Binding.toKey('background'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get background => _background?.get();

  ColorObservable? _onbackground;
  set onbackground(dynamic v) {
    if (_onbackground != null) {
      _onbackground!.set(v);
    } else if (v != null) {
      _onbackground = ColorObservable(Binding.toKey('onbackground'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get onbackground => _onbackground?.get();

  ColorObservable? _shadow;
  set shadow(dynamic v) {
    if (_shadow != null) {
      _shadow!.set(v);
    } else if (v != null) {
      _shadow = ColorObservable(Binding.toKey('shadow'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get shadow => _shadow?.get();

  ColorObservable? _outline;
  set outline(dynamic v) {
    if (_outline != null) {
      _outline!.set(v);
    } else if (v != null) {
      _outline = ColorObservable(Binding.toKey('outline'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get outline => _outline?.get();

  ColorObservable? _surface;
  set surface(dynamic v) {
    if (_surface != null) {
      _surface!.set(v);
    } else if (v != null) {
      _surface = ColorObservable(Binding.toKey('surface'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get surface => _surface?.get();

  ColorObservable? _onsurface;
  set onsurface(dynamic v) {
    if (_onsurface != null) {
      _onsurface!.set(v);
    } else if (v != null) {
      _onsurface = ColorObservable(Binding.toKey('onsurface'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get onsurface => _onsurface?.get();

  ColorObservable? _surfacevariant;
  set surfacevariant(dynamic v) {
    if (_surfacevariant != null) {
      _surfacevariant!.set(v);
    } else if (v != null) {
      _surfacevariant = ColorObservable(Binding.toKey('surfacevariant'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get surfacevariant => _surfacevariant?.get();

  ColorObservable? _onsurfacevariant;
  set onsurfacevariant(dynamic v) {
    if (_onsurfacevariant != null) {
      _onsurfacevariant!.set(v);
    } else if (v != null) {
      _onsurfacevariant = ColorObservable(Binding.toKey('onsurfacevariant'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get onsurfacevariant => _onsurfacevariant?.get();

  ColorObservable? _inversesurface;
  set inversesurface(dynamic v) {
    if (_inversesurface != null) {
      _inversesurface!.set(v);
    } else if (v != null) {
      _inversesurface = ColorObservable(Binding.toKey('inversesurface'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get inversesurface => _inversesurface?.get();

  ColorObservable? _oninversesurface;
  set oninversesurface(dynamic v) {
    if (_oninversesurface != null) {
      _oninversesurface!.set(v);
    } else if (v != null) {
      _oninversesurface = ColorObservable(Binding.toKey('oninversesurface'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get oninversesurface => _oninversesurface?.get();

  ColorObservable? _primary;
  set primary(dynamic v) {
    if (_primary != null) {
      _primary!.set(v);
    } else if (v != null) {
      _primary = ColorObservable(Binding.toKey('primary'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get primary => _primary?.get();

  ColorObservable? _onprimary;
  set onprimary(dynamic v) {
    if (_onprimary != null) {
      _onprimary!.set(v);
    } else if (v != null) {
      _onprimary = ColorObservable(Binding.toKey('onprimary'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get onprimary => _onprimary?.get();

  ColorObservable? _primarycontainer;
  set primarycontainer(dynamic v) {
    if (_primarycontainer != null) {
      _primarycontainer!.set(v);
    } else if (v != null) {
      _primarycontainer = ColorObservable(Binding.toKey('primarycontainer'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get primarycontainer => _primarycontainer?.get();

  ColorObservable? _onprimarycontainer;
  set onprimarycontainer(dynamic v) {
    if (_onprimarycontainer != null) {
      _onprimarycontainer!.set(v);
    } else if (v != null) {
      _onprimarycontainer = ColorObservable(Binding.toKey('onprimarycontainer'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get onprimarycontainer => _onprimarycontainer?.get();

  ColorObservable? _inverseprimary;
  set inverseprimary(dynamic v) {
    if (_inverseprimary != null) {
      _inverseprimary!.set(v);
    } else if (v != null) {
      _inverseprimary = ColorObservable(Binding.toKey('inverseprimary'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get inverseprimary => _inverseprimary?.get();

  ColorObservable? _secondary;
  set secondary(dynamic v) {
    if (_secondary != null) {
      _secondary!.set(v);
    } else if (v != null) {
      _secondary = ColorObservable(Binding.toKey('secondary'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get secondary => _secondary?.get();

  ColorObservable? _onsecondary;
  set onsecondary(dynamic v) {
    if (_onsecondary != null) {
      _onsecondary!.set(v);
    } else if (v != null) {
      _onsecondary = ColorObservable(Binding.toKey('onsecondary'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get onsecondary => _onsecondary?.get();

  ColorObservable? _secondarycontainer;
  set secondarycontainer(dynamic v) {
    if (_secondarycontainer != null) {
      _secondarycontainer!.set(v);
    } else if (v != null) {
      _secondarycontainer = ColorObservable(Binding.toKey('secondarycontainer'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get secondarycontainer => _secondarycontainer?.get();

  ColorObservable? _onsecondarycontainer;
  set onsecondarycontainer(dynamic v) {
    if (_onsecondarycontainer != null) {
      _onsecondarycontainer!.set(v);
    } else if (v != null) {
      _onsecondarycontainer = ColorObservable(Binding.toKey('onsecondarycontainer'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get onsecondarycontainer => _onsecondarycontainer?.get();

  ColorObservable? _tertiarycontainer;
  set tertiarycontainer(dynamic v) {
    if (_tertiarycontainer != null) {
      _tertiarycontainer!.set(v);
    } else if (v != null) {
      _tertiarycontainer = ColorObservable(Binding.toKey('tertiarycontainer'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get tertiarycontainer => _tertiarycontainer?.get();

  ColorObservable? _ontertiarycontainer;
  set ontertiarycontainer(dynamic v) {
    if (_ontertiarycontainer != null) {
      _ontertiarycontainer!.set(v);
    } else if (v != null) {
      _ontertiarycontainer = ColorObservable(Binding.toKey('ontertiarycontainer'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get ontertiarycontainer => _ontertiarycontainer?.get();

  ColorObservable? _error;
  set error(dynamic v) {
    if (_error != null) {
      _error!.set(v);
    } else if (v != null) {
      _error = ColorObservable(Binding.toKey('error'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get error => _error?.get();

  ColorObservable? _onerror;
  set onerror(dynamic v) {
    if (_onerror != null) {
      _onerror!.set(v);
    } else if (v != null) {
      _onerror = ColorObservable(Binding.toKey('onerror'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get onerror => _onerror?.get();

  ColorObservable? _errorcontainer;
  set errorcontainer(dynamic v) {
    if (_errorcontainer != null) {
      _errorcontainer!.set(v);
    } else if (v != null) {
      _errorcontainer = ColorObservable(Binding.toKey('errorcontainer'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get errorcontainer => _errorcontainer?.get();

  ColorObservable? _onerrorcontainer;
  set onerrorcontainer(dynamic v) {
    if (_onerrorcontainer != null) {
      _onerrorcontainer!.set(v);
    } else if (v != null) {
      _onerrorcontainer = ColorObservable(Binding.toKey('onerrorcontainer'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get onerrorcontainer => _onerrorcontainer?.get();

  ThemeModel(WidgetModel parent, String?  id,
  {
    dynamic brightness,
    dynamic background,
    dynamic onbackground,
    dynamic shadow,
    dynamic outline,
    dynamic surface,
    dynamic onsurface,
    dynamic surfacevariant,
    dynamic onsurfacevariant,
    dynamic inversesurface,
    dynamic oninversesurface,
    dynamic primary,
    dynamic onprimary,
    dynamic primarycontainer,
    dynamic onprimarycontainer,
    dynamic inverseprimary,
    dynamic secondary,
    dynamic onsecondary,
    dynamic secondarycontainer,
    dynamic onsecondarycontainer,
    dynamic tertiarycontainer,
    dynamic ontertiarycontainer,
    dynamic error,
    dynamic onerror,
    dynamic errorcontainer,
    dynamic onerrorcontainer,
  }) : super(parent, id, scope: Scope(id: myId)) {
    if (background != null) this.brightness = brightness;
    if (background != null) this.background = background;
    if (onbackground != null) this.onbackground = onbackground;
    if (shadow != null) this.shadow = shadow;
    if (outline != null) this.outline = outline;
    if (surface != null) this.surface = surface;
    if (onsurface != null) this.onsurface = onsurface;
    if (surfacevariant != null) this.surfacevariant = surfacevariant;
    if (onsurfacevariant != null) this.onsurfacevariant = onsurfacevariant;
    if (inversesurface != null) this.inversesurface = inversesurface;
    if (oninversesurface != null) this.oninversesurface = oninversesurface;
    if (primary != null) this.primary = primary;
    if (onprimary != null) this.onprimary = onprimary;
    if (primarycontainer != null) this.primarycontainer = primarycontainer;
    if (onprimarycontainer != null) this.onprimarycontainer = onprimarycontainer;
    if (inverseprimary != null) this.inverseprimary = inverseprimary;
    if (secondary != null) this.secondary = secondary;
    if (onsecondary != null) this.onsecondary = onsecondary;
    if (secondarycontainer != null) this.secondarycontainer = secondarycontainer;
    if (onsecondarycontainer != null) this.onsecondarycontainer = onsecondarycontainer;
    if (tertiarycontainer != null) this.tertiarycontainer = tertiarycontainer;
    if (ontertiarycontainer != null) this.ontertiarycontainer = ontertiarycontainer;
    if (error != null) this.error = error;
    if (onerror != null) this.onerror = onerror;
    if (errorcontainer != null) this.errorcontainer = errorcontainer;
    if (onerrorcontainer != null) this.onerrorcontainer = onerrorcontainer;
  } // ; {key: value}

  // Map<String, dynamic> themeValues = Map<String, dynamic>();

  static ThemeModel? fromXml(WidgetModel parent, XmlElement xml, {String? type})
  {
    ThemeModel? model;
    try
    {
      model = ThemeModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().debug(e.toString());
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) async
  {
    // deserialize
    super.deserialize(xml);

    // properties
    background = Xml.get(node: xml, tag: 'background');
    onbackground  = Xml.get(node: xml, tag: 'onbackground');
    shadow  = Xml.get(node: xml, tag: 'shadow');
    outline = Xml.get(node: xml, tag: 'outline');
    surface = Xml.get(node: xml, tag: 'surface');
    onsurface = Xml.get(node: xml, tag: 'onsurface');
    surfacevariant  = Xml.get(node: xml, tag: 'surfacevariant');
    onsurfacevariant  = Xml.get(node: xml, tag: 'onsurfacevariant');
    inversesurface  = Xml.get(node: xml, tag: 'inversesurface');
    oninversesurface  = Xml.get(node: xml, tag: 'oninversesurface');
    primary = Xml.get(node: xml, tag: 'primary');
    onprimary = Xml.get(node: xml, tag: 'onprimary');
    primarycontainer  = Xml.get(node: xml, tag: 'primarycontainer');
    onprimarycontainer  = Xml.get(node: xml, tag: 'onprimarycontainer');
    inverseprimary  = Xml.get(node: xml, tag: 'inverseprimary');
    secondary = Xml.get(node: xml, tag: 'secondary');
    onsecondary = Xml.get(node: xml, tag: 'onsecondary');
    secondarycontainer  = Xml.get(node: xml, tag: 'secondarycontainer');
    onsecondarycontainer  = Xml.get(node: xml, tag: 'onsecondarycontainer');
    tertiarycontainer = Xml.get(node: xml, tag: 'tertiarycontainer');
    ontertiarycontainer = Xml.get(node: xml, tag: 'ontertiarycontainer');
    error = Xml.get(node: xml, tag: 'error');
    onerror = Xml.get(node: xml, tag: 'onerror');
    errorcontainer  = Xml.get(node: xml, tag: 'errorcontainer');
    onerrorcontainer  = Xml.get(node: xml, tag: 'onerrorcontainer');
  }

  @override
  dispose()
  {
    // Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  @override
  Widget getView({Key? key}) => ThemeView(this);
}