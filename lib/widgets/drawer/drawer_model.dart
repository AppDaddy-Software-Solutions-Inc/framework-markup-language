// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/decorated/decorated_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/widgets/drawer/drawer_view.dart';
import 'package:fml/widgets/drawer/item/drawer_item_model.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

class DrawerModel extends DecoratedWidgetModel {
  //////////
  /* Side */
  //////////
  StringObservable? _side;
  set side(dynamic v) {
    if (_side != null) {
      _side!.set(v);
    } else if (v != null) {
      _side = StringObservable(Binding.toKey(id, 'side'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String? get side => _side?.get();

  //////////////////
  /* Curved Edges */
  //////////////////
  BooleanObservable? _rounded;
  set rounded(dynamic v) {
    if (_rounded != null) {
      _rounded!.set(v);
    } else if (v != null) {
      _rounded = BooleanObservable(Binding.toKey(id, 'rounded'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool get rounded => _rounded?.get() ?? false;

  //////////////////
  /* Edge Handles */
  //////////////////
  BooleanObservable? _handle;
  set handle(dynamic v) {
    if (_handle != null) {
      _handle!.set(v);
    } else if (v != null) {
      _handle = BooleanObservable(Binding.toKey(id, 'handle'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool get handle => _handle?.get() ?? false;

  DrawerItemModel? top;
  DrawerItemModel? bottom;
  DrawerItemModel? left;
  DrawerItemModel? right;
  bool? handleLeft;
  bool? handleRight;
  bool? handleTop;
  bool? handleBottom;
  double? sizeLeft;
  double? sizeRight;
  double? sizeTop;
  double? sizeBottom;
  String? idLeft;
  String? idRight;
  String? idTop;
  String? idBottom;

  DrawerModel(
    WidgetModel super.parent,
    super.id, {
    dynamic side,
    dynamic rounded,
    dynamic handle,
    this.handleLeft,
    this.handleRight,
    this.handleTop,
    this.handleBottom,
    this.sizeLeft,
    this.sizeRight,
    this.sizeTop,
    this.sizeBottom,
    this.idLeft,
    this.idRight,
    this.idTop,
    this.idBottom,
  }) {
    this.side = side;
    this.rounded = rounded;
    this.handle = handle;
  }

  // I built this to replace fromXml so that we can take in multiple <DRAWER> elements
  // and consolidate them into a single DrawerModel that handles them all (important)
  static DrawerModel? fromXmlList(
      WidgetModel parent, List<XmlElement> elements) {
    DrawerModel? model;
    try {
      bool handleLeft = false;
      bool handleRight = false;
      bool handleTop = false;
      bool handleBottom = false;
      double? sizeLeft;
      double? sizeRight;
      double? sizeTop;
      double? sizeBottom;
      String? idLeft;
      String? idRight;
      String? idTop;
      String? idBottom;

      XmlElement xml = XmlElement(
          XmlName.fromString('DRAWER')); // create a single drawer element
      for (var element in elements) {
        XmlElement node = element.copy();

        String? side =
            Xml.attribute(node: node, tag: 'side')?.trim().toLowerCase();
        if (side != null) {
          // build the drawer elements
          XmlElement drawer = XmlElement(
              XmlName(side.toUpperCase())); // create a sidedrawer from template

          // add attributes
          for (var attribute in node.attributes) {
            var name = attribute.localName.toLowerCase();
            if (name != "width" && name != "height" && name != "side") {
              drawer.attributes
                  .add(XmlAttribute(XmlName(name), attribute.value));
            }
          }

          // Assign ids
          switch (side) {
            case 'left':
              idLeft = Xml.attribute(node: node, tag: 'id');
              handleLeft =
                  toBool(Xml.attribute(node: node, tag: 'handle')) == true;
              sizeLeft = toDouble(Xml.attribute(node: node, tag: 'size'));
              break;

            case 'right':
              idRight = Xml.attribute(node: node, tag: 'id');
              handleRight =
                  toBool(Xml.attribute(node: node, tag: 'handle')) == true;
              sizeRight = toDouble(Xml.attribute(node: node, tag: 'size'));
              break;

            case 'top':
              idTop = Xml.attribute(node: node, tag: 'id');
              handleTop =
                  toBool(Xml.attribute(node: node, tag: 'handle')) == true;
              sizeTop = toDouble(Xml.attribute(node: node, tag: 'size'));
              break;

            case 'bottom':
              idBottom = Xml.attribute(node: node, tag: 'id');
              handleBottom =
                  toBool(Xml.attribute(node: node, tag: 'handle')) == true;
              sizeBottom = toDouble(Xml.attribute(node: node, tag: 'size'));
              break;
          }

          List<XmlElement> nodes = [];
          for (var node in node.children) {
            if (node.nodeType == XmlNodeType.ELEMENT) {
              nodes.add(node.copy() as XmlElement);
            }
          }

          drawer.children.addAll(nodes);
          xml.children.add(drawer);
        } else {
          Log().error('Unable to parse a drawer attributes',
              caller: 'drawer.Model => Model.fromXmlList()');
        }
      }

      // Create View Model
      model = DrawerModel(parent, Xml.get(node: xml, tag: 'id'),
          handleLeft: handleLeft,
          handleRight: handleRight,
          handleTop: handleTop,
          handleBottom: handleBottom,
          sizeLeft: sizeLeft,
          sizeRight: sizeRight,
          sizeTop: sizeTop,
          sizeBottom: sizeBottom,
          idLeft: idLeft,
          idRight: idRight,
          idTop: idTop,
          idBottom: idBottom);

      // Deserialize
      model.deserialize(xml);
    } catch (e) {
      Log().error('Unable to parse a drawer element',
          caller: 'drawer.Model => Model.fromXmlList()');
      Log().exception(e, caller: 'drawer.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {
    // deserialize
    super.deserialize(xml);

    /// Build Drawers

    // This grabs the deserializes xml generated from fromXmlList()
    element = Xml.getChildElement(node: xml, tag: "TOP");
    if (element != null) {
      top = DrawerItemModel.fromXml(this, element, DrawerPositions.top);
    }

    element = Xml.getChildElement(node: xml, tag: "BOTTOM");
    if (element != null) {
      bottom = DrawerItemModel.fromXml(this, element, DrawerPositions.bottom);
    }

    element = Xml.getChildElement(node: xml, tag: "LEFT");
    if (element != null) {
      left = DrawerItemModel.fromXml(this, element, DrawerPositions.left);
    }

    element = Xml.getChildElement(node: xml, tag: "RIGHT");
    if (element != null) {
      right = DrawerItemModel.fromXml(this, element, DrawerPositions.right);
    }

    // properties
    side = Xml.get(node: xml, tag: 'side');
    rounded = Xml.get(node: xml, tag: 'rounded');
  }

  bool drawerExists(String drawer) {
    if (drawer == 'top') {
      return top != null;
    } else if (drawer == 'bottom') {
      return bottom != null;
    } else if (drawer == 'left') {
      return left != null;
    } else if (drawer == 'right') {
      return right != null;
    } else {
      Log().warning('No matching drawer type of: $drawer',
          caller: 'Drawer.model -> drawerExists(String drawer)');
      return false;
    }
  }

  @override
  Widget getView({Key? key}) => getReactiveView(DrawerView(this, Container()));
}
