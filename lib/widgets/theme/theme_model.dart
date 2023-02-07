// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/decorated_widget_model.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/theme/theme_view.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class ThemeModel extends DecoratedWidgetModel implements IViewableWidget
{
  static String defaultBrightness = "light";
  static String defaultColor = "lightblue";

  static String myId = 'THEME';

  static const Color colorDefault = Color(0xffb2dd4c);

  StringObservable? _brightness;
  set brightness(dynamic v) {
    if (_brightness != null)
      _brightness!.set(v);
    else if (v != null)
      _brightness = StringObservable(Binding.toKey('brightness'), v, scope: scope, listener: onPropertyChange);
  }
  String? get brightness => _brightness?.get();

  StringObservable? _colorscheme;
  set colorscheme(dynamic v) {
    if (_colorscheme != null)
      _colorscheme!.set(v);
    else if (v != null)
      _colorscheme = StringObservable(Binding.toKey('colorscheme'), v, scope: scope, listener: onPropertyChange);
  }
  String? get colorscheme => _colorscheme?.get();

  StringObservable? _font;
  set font(dynamic v) {
    if (_font != null)
      _font!.set(v);
    else if (v != null)
      _font = StringObservable(Binding.toKey('font'), v, scope: scope, listener: onPropertyChange);
  }
  String get font => _font?.get() ?? 'Roboto';

  StringObservable? _background;
  set background(dynamic v) {
    if (_background != null)
      _background!.set(v);
    else if (v != null)
      _background = StringObservable(Binding.toKey('background'), v, scope: scope, listener: onPropertyChange);
  }
  String? get background => _background?.get();

  StringObservable? _onbackground;
  set onbackground(dynamic v) {
    if (_onbackground != null)
      _onbackground!.set(v);
    else if (v != null)
      _onbackground = StringObservable(Binding.toKey('onbackground'), v, scope: scope, listener: onPropertyChange);
  }
  String? get onbackground => _onbackground?.get();

  StringObservable? _shadow;
  set shadow(dynamic v) {
    if (_shadow != null)
      _shadow!.set(v);
    else if (v != null)
      _shadow = StringObservable(Binding.toKey('shadow'), v, scope: scope, listener: onPropertyChange);
  }
  String? get shadow => _shadow?.get();

  StringObservable? _outline;
  set outline(dynamic v) {
    if (_outline != null)
      _outline!.set(v);
    else if (v != null)
      _outline = StringObservable(Binding.toKey('outline'), v, scope: scope, listener: onPropertyChange);
  }
  String? get outline => _outline?.get();

  StringObservable? _surface;
  set surface(dynamic v) {
    if (_surface != null)
      _surface!.set(v);
    else if (v != null)
      _surface = StringObservable(Binding.toKey('surface'), v, scope: scope, listener: onPropertyChange);
  }
  String? get surface => _surface?.get();

  StringObservable? _onsurface;
  set onsurface(dynamic v) {
    if (_onsurface != null)
      _onsurface!.set(v);
    else if (v != null)
      _onsurface = StringObservable(Binding.toKey('onsurface'), v, scope: scope, listener: onPropertyChange);
  }
  String? get onsurface => _onsurface?.get();

  StringObservable? _surfacevariant;
  set surfacevariant(dynamic v) {
    if (_surfacevariant != null)
      _surfacevariant!.set(v);
    else if (v != null)
      _surfacevariant = StringObservable(Binding.toKey('surfacevariant'), v, scope: scope, listener: onPropertyChange);
  }
  String? get surfacevariant => _surfacevariant?.get();

  StringObservable? _onsurfacevariant;
  set onsurfacevariant(dynamic v) {
    if (_onsurfacevariant != null)
      _onsurfacevariant!.set(v);
    else if (v != null)
      _onsurfacevariant = StringObservable(Binding.toKey('onsurfacevariant'), v, scope: scope, listener: onPropertyChange);
  }
  String? get onsurfacevariant => _onsurfacevariant?.get();

  StringObservable? _inversesurface;
  set inversesurface(dynamic v) {
    if (_inversesurface != null)
      _inversesurface!.set(v);
    else if (v != null)
      _inversesurface = StringObservable(Binding.toKey('inversesurface'), v, scope: scope, listener: onPropertyChange);
  }
  String? get inversesurface => _inversesurface?.get();

  StringObservable? _oninversesurface;
  set oninversesurface(dynamic v) {
    if (_oninversesurface != null)
      _oninversesurface!.set(v);
    else if (v != null)
      _oninversesurface = StringObservable(Binding.toKey('oninversesurface'), v, scope: scope, listener: onPropertyChange);
  }
  String? get oninversesurface => _oninversesurface?.get();

  StringObservable? _primary;
  set primary(dynamic v) {
    if (_primary != null)
      _primary!.set(v);
    else if (v != null)
      _primary = StringObservable(Binding.toKey('primary'), v, scope: scope, listener: onPropertyChange);
  }
  String? get primary => _primary?.get();

  StringObservable? _onprimary;
  set onprimary(dynamic v) {
    if (_onprimary != null)
      _onprimary!.set(v);
    else if (v != null)
      _onprimary = StringObservable(Binding.toKey('onprimary'), v, scope: scope, listener: onPropertyChange);
  }
  String? get onprimary => _onprimary?.get();

  StringObservable? _primarycontainer;
  set primarycontainer(dynamic v) {
    if (_primarycontainer != null)
      _primarycontainer!.set(v);
    else if (v != null)
      _primarycontainer = StringObservable(Binding.toKey('primarycontainer'), v, scope: scope, listener: onPropertyChange);
  }
  String? get primarycontainer => _primarycontainer?.get();

  StringObservable? _onprimarycontainer;
  set onprimarycontainer(dynamic v) {
    if (_onprimarycontainer != null)
      _onprimarycontainer!.set(v);
    else if (v != null)
      _onprimarycontainer = StringObservable(Binding.toKey('onprimarycontainer'), v, scope: scope, listener: onPropertyChange);
  }
  String? get onprimarycontainer => _onprimarycontainer?.get();

  StringObservable? _inverseprimary;
  set inverseprimary(dynamic v) {
    if (_inverseprimary != null)
      _inverseprimary!.set(v);
    else if (v != null)
      _inverseprimary = StringObservable(Binding.toKey('inverseprimary'), v, scope: scope, listener: onPropertyChange);
  }
  String? get inverseprimary => _inverseprimary?.get();

  StringObservable? _secondary;
  set secondary(dynamic v) {
    if (_secondary != null)
      _secondary!.set(v);
    else if (v != null)
      _secondary = StringObservable(Binding.toKey('secondary'), v, scope: scope, listener: onPropertyChange);
  }
  String? get secondary => _secondary?.get();

  StringObservable? _onsecondary;
  set onsecondary(dynamic v) {
    if (_onsecondary != null)
      _onsecondary!.set(v);
    else if (v != null)
      _onsecondary = StringObservable(Binding.toKey('onsecondary'), v, scope: scope, listener: onPropertyChange);
  }
  String? get onsecondary => _onsecondary?.get();

  StringObservable? _secondarycontainer;
  set secondarycontainer(dynamic v) {
    if (_secondarycontainer != null)
      _secondarycontainer!.set(v);
    else if (v != null)
      _secondarycontainer = StringObservable(Binding.toKey('secondarycontainer'), v, scope: scope, listener: onPropertyChange);
  }
  String? get secondarycontainer => _secondarycontainer?.get();

  StringObservable? _onsecondarycontainer;
  set onsecondarycontainer(dynamic v) {
    if (_onsecondarycontainer != null)
      _onsecondarycontainer!.set(v);
    else if (v != null)
      _onsecondarycontainer = StringObservable(Binding.toKey('onsecondarycontainer'), v, scope: scope, listener: onPropertyChange);
  }
  String? get onsecondarycontainer => _onsecondarycontainer?.get();

  StringObservable? _tertiarycontainer;
  set tertiarycontainer(dynamic v) {
    if (_tertiarycontainer != null)
      _tertiarycontainer!.set(v);
    else if (v != null)
      _tertiarycontainer = StringObservable(Binding.toKey('tertiarycontainer'), v, scope: scope, listener: onPropertyChange);
  }
  String? get tertiarycontainer => _tertiarycontainer?.get();

  StringObservable? _ontertiarycontainer;
  set ontertiarycontainer(dynamic v) {
    if (_ontertiarycontainer != null)
      _ontertiarycontainer!.set(v);
    else if (v != null)
      _ontertiarycontainer = StringObservable(Binding.toKey('ontertiarycontainer'), v, scope: scope, listener: onPropertyChange);
  }
  String? get ontertiarycontainer => _ontertiarycontainer?.get();

  StringObservable? _error;
  set error(dynamic v) {
    if (_error != null)
      _error!.set(v);
    else if (v != null)
      _error = StringObservable(Binding.toKey('error'), v, scope: scope, listener: onPropertyChange);
  }
  String? get error => _error?.get();

  StringObservable? _onerror;
  set onerror(dynamic v) {
    if (_onerror != null)
      _onerror!.set(v);
    else if (v != null)
      _onerror = StringObservable(Binding.toKey('onerror'), v, scope: scope, listener: onPropertyChange);
  }
  String? get onerror => _onerror?.get();

  StringObservable? _errorcontainer;
  set errorcontainer(dynamic v) {
    if (_errorcontainer != null)
      _errorcontainer!.set(v);
    else if (v != null)
      _errorcontainer = StringObservable(Binding.toKey('errorcontainer'), v, scope: scope, listener: onPropertyChange);
  }
  String? get errorcontainer => _errorcontainer?.get();

  StringObservable? _onerrorcontainer;
  set onerrorcontainer(dynamic v) {
    if (_onerrorcontainer != null)
      _onerrorcontainer!.set(v);
    else if (v != null)
      _onerrorcontainer = StringObservable(Binding.toKey('onerrorcontainer'), v, scope: scope, listener: onPropertyChange);
  }
  String? get onerrorcontainer => _onerrorcontainer?.get();

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
    background  = Xml.get(node: xml, tag: 'background');
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

  Widget getView({Key? key}) => ThemeView(this);
}