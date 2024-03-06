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

  ColorObservable? _colorScheme;
  set colorScheme(dynamic v) {
    if (_colorScheme != null) {
      _colorScheme!.set(v);
    } else if (v != null) {
      _colorScheme = ColorObservable(Binding.toKey('colorscheme'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get colorScheme => _colorScheme?.get();

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

  ColorObservable? _onBackground;
  set onBackground(dynamic v) {
    if (_onBackground != null) {
      _onBackground!.set(v);
    } else if (v != null) {
      _onBackground = ColorObservable(Binding.toKey('onbackground'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get onBackground => _onBackground?.get();

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

  ColorObservable? _onSurface;
  set onSurface(dynamic v) {
    if (_onSurface != null) {
      _onSurface!.set(v);
    } else if (v != null) {
      _onSurface = ColorObservable(Binding.toKey('onsurface'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get onSurface => _onSurface?.get();

  ColorObservable? _surfaceVariant;
  set surfaceVariant(dynamic v) {
    if (_surfaceVariant != null) {
      _surfaceVariant!.set(v);
    } else if (v != null) {
      _surfaceVariant = ColorObservable(Binding.toKey('surfacevariant'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get surfaceVariant => _surfaceVariant?.get();

  ColorObservable? _onSurfaceVariant;
  set onSurfaceVariant(dynamic v) {
    if (_onSurfaceVariant != null) {
      _onSurfaceVariant!.set(v);
    } else if (v != null) {
      _onSurfaceVariant = ColorObservable(Binding.toKey('onsurfacevariant'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get onSurfaceVariant => _onSurfaceVariant?.get();

  ColorObservable? _inverseSurface;
  set inverseSurface(dynamic v) {
    if (_inverseSurface != null) {
      _inverseSurface!.set(v);
    } else if (v != null) {
      _inverseSurface = ColorObservable(Binding.toKey('inversesurface'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get inverseSurface => _inverseSurface?.get();

  ColorObservable? _onInverseSurface;
  set onInverseSurface(dynamic v) {
    if (_onInverseSurface != null) {
      _onInverseSurface!.set(v);
    } else if (v != null) {
      _onInverseSurface = ColorObservable(Binding.toKey('oninversesurface'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get onInverseSurface => _onInverseSurface?.get();

  ColorObservable? _primary;
  set primary(dynamic v) {
    if (_primary != null) {
      _primary!.set(v);
    } else if (v != null) {
      _primary = ColorObservable(Binding.toKey('primary'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get primary => _primary?.get();

  ColorObservable? _onPrimary;
  set onPrimary(dynamic v) {
    if (_onPrimary != null) {
      _onPrimary!.set(v);
    } else if (v != null) {
      _onPrimary = ColorObservable(Binding.toKey('onprimary'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get onPrimary => _onPrimary?.get();

  ColorObservable? _primaryContainer;
  set primaryContainer(dynamic v) {
    if (_primaryContainer != null) {
      _primaryContainer!.set(v);
    } else if (v != null) {
      _primaryContainer = ColorObservable(Binding.toKey('primarycontainer'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get primaryContainer => _primaryContainer?.get();

  ColorObservable? _onPrimaryContainer;
  set onPrimaryContainer(dynamic v) {
    if (_onPrimaryContainer != null) {
      _onPrimaryContainer!.set(v);
    } else if (v != null) {
      _onPrimaryContainer = ColorObservable(Binding.toKey('onprimarycontainer'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get onPrimaryContainer => _onPrimaryContainer?.get();

  ColorObservable? _inversePrimary;
  set inversePrimary(dynamic v) {
    if (_inversePrimary != null) {
      _inversePrimary!.set(v);
    } else if (v != null) {
      _inversePrimary = ColorObservable(Binding.toKey('inverseprimary'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get inversePrimary => _inversePrimary?.get();

  ColorObservable? _secondary;
  set secondary(dynamic v) {
    if (_secondary != null) {
      _secondary!.set(v);
    } else if (v != null) {
      _secondary = ColorObservable(Binding.toKey('secondary'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get secondary => _secondary?.get();

  ColorObservable? _onSecondary;
  set onSecondary(dynamic v) {
    if (_onSecondary != null) {
      _onSecondary!.set(v);
    } else if (v != null) {
      _onSecondary = ColorObservable(Binding.toKey('onsecondary'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get onSecondary => _onSecondary?.get();

  ColorObservable? _secondaryContainer;
  set secondaryContainer(dynamic v) {
    if (_secondaryContainer != null) {
      _secondaryContainer!.set(v);
    } else if (v != null) {
      _secondaryContainer = ColorObservable(Binding.toKey('secondarycontainer'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get secondaryContainer => _secondaryContainer?.get();

  ColorObservable? _onSecondaryContainer;
  set onSecondaryContainer(dynamic v) {
    if (_onSecondaryContainer != null) {
      _onSecondaryContainer!.set(v);
    } else if (v != null) {
      _onSecondaryContainer = ColorObservable(Binding.toKey('onsecondarycontainer'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get onSecondaryContainer => _onSecondaryContainer?.get();

  ColorObservable? _tertiaryContainer;
  set tertiaryContainer(dynamic v) {
    if (_tertiaryContainer != null) {
      _tertiaryContainer!.set(v);
    } else if (v != null) {
      _tertiaryContainer = ColorObservable(Binding.toKey('tertiarycontainer'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get tertiaryContainer => _tertiaryContainer?.get();

  ColorObservable? _onTertiaryContainer;
  set onTertiaryContainer(dynamic v) {
    if (_onTertiaryContainer != null) {
      _onTertiaryContainer!.set(v);
    } else if (v != null) {
      _onTertiaryContainer = ColorObservable(Binding.toKey('ontertiarycontainer'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get onTertiaryContainer => _onTertiaryContainer?.get();

  ColorObservable? _error;
  set error(dynamic v) {
    if (_error != null) {
      _error!.set(v);
    } else if (v != null) {
      _error = ColorObservable(Binding.toKey('error'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get error => _error?.get();

  ColorObservable? _onError;
  set onError(dynamic v) {
    if (_onError != null) {
      _onError!.set(v);
    } else if (v != null) {
      _onError = ColorObservable(Binding.toKey('onerror'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get onError => _onError?.get();

  ColorObservable? _errorContainer;
  set errorContainer(dynamic v) {
    if (_errorContainer != null) {
      _errorContainer!.set(v);
    } else if (v != null) {
      _errorContainer = ColorObservable(Binding.toKey('errorcontainer'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get errorContainer => _errorContainer?.get();

  ColorObservable? _onErrorContainer;
  set onErrorContainer(dynamic v) {
    if (_onErrorContainer != null) {
      _onErrorContainer!.set(v);
    } else if (v != null) {
      _onErrorContainer = ColorObservable(Binding.toKey('onerrorcontainer'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get onErrorContainer => _onErrorContainer?.get();

  ThemeModel(WidgetModel super.parent, super.id) : super(scope: Scope(id: myId));

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
    onBackground  = Xml.get(node: xml, tag: 'onbackground');
    shadow  = Xml.get(node: xml, tag: 'shadow');
    outline = Xml.get(node: xml, tag: 'outline');
    surface = Xml.get(node: xml, tag: 'surface');
    onSurface = Xml.get(node: xml, tag: 'onsurface');
    surfaceVariant  = Xml.get(node: xml, tag: 'surfacevariant');
    onSurfaceVariant  = Xml.get(node: xml, tag: 'onsurfacevariant');
    inverseSurface  = Xml.get(node: xml, tag: 'inversesurface');
    onInverseSurface  = Xml.get(node: xml, tag: 'oninversesurface');
    primary = Xml.get(node: xml, tag: 'primary');
    onPrimary = Xml.get(node: xml, tag: 'onprimary');
    primaryContainer  = Xml.get(node: xml, tag: 'primarycontainer');
    onPrimaryContainer  = Xml.get(node: xml, tag: 'onprimarycontainer');
    inversePrimary  = Xml.get(node: xml, tag: 'inverseprimary');
    secondary = Xml.get(node: xml, tag: 'secondary');
    onSecondary = Xml.get(node: xml, tag: 'onsecondary');
    secondaryContainer  = Xml.get(node: xml, tag: 'secondarycontainer');
    onSecondaryContainer  = Xml.get(node: xml, tag: 'onsecondarycontainer');
    tertiaryContainer = Xml.get(node: xml, tag: 'tertiarycontainer');
    onTertiaryContainer = Xml.get(node: xml, tag: 'ontertiarycontainer');
    error = Xml.get(node: xml, tag: 'error');
    onError = Xml.get(node: xml, tag: 'onerror');
    errorContainer  = Xml.get(node: xml, tag: 'errorcontainer');
    onErrorContainer  = Xml.get(node: xml, tag: 'onerrorcontainer');
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