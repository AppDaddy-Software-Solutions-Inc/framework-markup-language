// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/observable/observables/boolean.dart';
import 'package:fml/observable/observables/string.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/table/table_header_model.dart';
import 'package:fml/widgets/text/text_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:xml/xml.dart';
import 'package:fml/helper/common_helpers.dart';

enum ColumnTypes {string, numeric, date, time}

class TableHeaderCellModel extends BoxModel
{
  // header
  TableHeaderModel? get hdr => parent is TableHeaderModel ? parent as TableHeaderModel : null;

  @override
  double? get paddingTop => super.paddingTop ?? hdr?.paddingTop;

  @override
  double? get paddingRight => super.paddingRight ?? hdr?.paddingRight;

  @override
  double? get paddingBottom => super.paddingBottom ?? hdr?.paddingBottom;

  @override
  double? get paddingLeft => super.paddingLeft ?? hdr?.paddingLeft;

  @override
  String? get halign => super.halign ?? hdr?.halign;

  @override
  String? get valign => super.valign ?? hdr?.valign;

  // column type
  StringObservable? _type;
  set type(dynamic v)
  {
    if (_type != null)
    {
      _type!.set(v);
    }
    else if (v != null)
    {
      _type = StringObservable(Binding.toKey(id, 'type'), v, scope: scope);
    }
  }
  String? get type => _type?.get();

  // allow sorting
  BooleanObservable? _sortable;
  set sortable(dynamic v)
  {
    if (_sortable != null)
    {
      _sortable!.set(v);
    }
    else if (v != null)
    {
      _sortable = BooleanObservable(Binding.toKey(id, 'sortable'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get sortable => _sortable?.get() ?? hdr?.sortable ?? true;

  // allow reordering
  BooleanObservable? _draggable;
  set draggable(dynamic v)
  {
    if (_draggable != null)
    {
      _draggable!.set(v);
    }
    else if (v != null)
    {
      _draggable = BooleanObservable(Binding.toKey(id, 'draggable'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get draggable => _draggable?.get() ?? hdr?.draggable ?? true;

  // allow resizing
  BooleanObservable? _resizeable;
  set resizeable(dynamic v)
  {
    if (_resizeable != null)
    {
      _resizeable!.set(v);
    }
    else if (v != null)
    {
      _resizeable = BooleanObservable(Binding.toKey(id, 'resizeable'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get resizeable => _resizeable?.get() ?? hdr?.resizeable ?? true;

  // name - used by grid display
  StringObservable? _name;
  set name(dynamic v)
  {
    if (_name != null)
    {
      _name!.set(v);
    }
    else if (v != null)
    {
      _name = StringObservable(Binding.toKey(id, 'name'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get name => _name?.get();
  
  // position in row
  int? get index => hdr?.cells.indexOf(this);

  TableHeaderCellModel(WidgetModel parent, String? id) : super(parent, id);

  static TableHeaderCellModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    TableHeaderCellModel? model;
    try
    {
      model = TableHeaderCellModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e, caller: 'column.Model');
      model = null;
    }
    return model;
  }

  static TableHeaderCellModel? fromXmlString(WidgetModel parent, String xml)
  {
    XmlDocument? document = Xml.tryParse(xml);
    return (document != null) ? TableHeaderCellModel.fromXml(parent, document.rootElement) : null;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {
    // deserialize
    super.deserialize(xml);

    // properties
    name = Xml.get(node:xml, tag: 'name');
    if (name == null)
    {
      TextModel? text = findChildOfExactType(TextModel);
      name = text?.value;
    }

    type       = Xml.get(node:xml, tag: 'type');
    sortable   = Xml.get(node:xml, tag: 'sortable');
    draggable  = Xml.get(node:xml, tag: 'draggable');
    resizeable = Xml.get(node:xml, tag: 'resizeable');
  }
}
