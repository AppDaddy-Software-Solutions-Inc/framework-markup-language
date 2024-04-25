// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/observable/observables/boolean.dart';
import 'package:fml/observable/observables/double.dart';
import 'package:fml/observable/observables/integer.dart';
import 'package:fml/observable/observables/string.dart';
import 'package:fml/widgets/tooltip/v2/tooltip_view.dart';
import 'package:fml/widgets/viewable/viewable_model.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:xml/xml.dart';
import 'package:fml/helpers/helpers.dart';

enum OpenMethods { tap, longpress, hover, manual }

class TooltipModel extends ViewableModel {

  OpenMethods? openMethod;

  /// [padding] Padding within the tooltip.
  DoubleObservable? _padding;
  set padding(dynamic v) {
    if (_padding != null) {
      _padding!.set(v);
    } else if (v != null) {
      _padding = DoubleObservable(Binding.toKey(id, 'padding'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  double get padding => _padding?.get() ?? 10.0;
  
  // position of the tooltip display
  StringObservable? _position;
  set position(dynamic v) {
    if (_position != null) {
      _position!.set(v);
    } else if (v != null) {
      _position =
          StringObservable(Binding.toKey(id, 'position'), v, scope: scope);
    }
  }
  String? get position => _position?.get();

  /// [distance] Space between the tooltip and the trigger.
  DoubleObservable? _distance;
  set distance(dynamic v) {
    if (_distance != null) {
      _distance!.set(v);
    } else if (v != null) {
      _distance = DoubleObservable(Binding.toKey(id, 'distance'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  double get distance => _distance?.get() ?? 8.0;

  /// [radius] Border radius around the tooltip.
  DoubleObservable? _radius;
  set radius(dynamic v) {
    if (_radius != null) {
      _radius!.set(v);
    } else if (v != null) {
      _radius = DoubleObservable(Binding.toKey(id, 'radius'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  double get radius => _radius?.get() ?? 8.0;

  /// [modal] Shows a dark layer behind the tooltip.
  BooleanObservable? _modal;
  set modal(dynamic v) {
    if (_modal != null) {
      _modal!.set(v);
    } else if (v != null) {
      _modal = BooleanObservable(Binding.toKey(id, 'modal'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  bool get modal => _modal?.get() ?? false;

  /// [arrow] Show the tip arrow?
  BooleanObservable? _arrow;
  set arrow(dynamic v) {
    if (_arrow != null) {
      _arrow!.set(v);
    } else if (v != null) {
      _arrow = BooleanObservable(Binding.toKey(id, 'arrow'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool get arrow => _arrow?.get() ?? true;

  /// [timeout] Number of seconds until the tooltip disappears automatically
  /// The default value is 0 (zero) which means it never disappears.
  // timeout
  IntegerObservable? _timeout;
  set timeout(dynamic v) {
    if (_timeout != null) {
      _timeout!.set(v);
    } else if (v != null) {
      _timeout = IntegerObservable(Binding.toKey(id, 'timeout'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  int get timeout => _timeout?.get() ?? 0;

  TooltipModel(Model super.parent, super.id);

  static TooltipModel? fromXml(Model parent, XmlElement xml) {
    TooltipModel? model;
    try {
      model = TooltipModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'tooltip.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {
    // deserialize
    super.deserialize(xml);

    // properties
    color = Xml.attribute(node: xml, tag: 'color');
    radius = Xml.attribute(node: xml, tag: 'radius');
    position = Xml.attribute(node: xml, tag: 'position');
    modal = Xml.attribute(node: xml, tag: 'modal');
    timeout = Xml.get(node: xml, tag: 'timeout');
    distance = Xml.get(node: xml, tag: 'distance');
    arrow = Xml.get(node: xml, tag: 'arrow');
    openMethod =
        toEnum(Xml.get(node: xml, tag: 'openmethod'), OpenMethods.values);
  }

  @override
  Future<bool?> execute(
      String caller, String propertyOrFunction, List<dynamic> arguments) async {
    /// setter
    if (scope == null) return null;
    var function = propertyOrFunction.toLowerCase().trim();

    switch (function) {
      case "open":
        var view = findListenerOfExactType(TooltipViewState);
        if (view is TooltipViewState &&
            context != null &&
            view.overlayEntry == null) view.showOverlay(context!);
        return true;

      case "close":
        var view = findListenerOfExactType(TooltipViewState);
        if (view is TooltipViewState && view.overlayEntry != null) {
          view.hideOverlay();
        }
        return true;
    }
    return super.execute(caller, propertyOrFunction, arguments);
  }
}
