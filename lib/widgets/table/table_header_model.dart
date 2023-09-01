// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/table/table_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/widgets/table/table_header_cell_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class TableHeaderModel extends BoxModel
{
  @override
  String? get layout => super.layout ?? "column";

  // cells
  final List<TableHeaderCellModel> cells = [];

  // cell by index
  TableHeaderCellModel? cell(int index) => index >= 0 && index < cells.length ? cells[index] : null;

  // table
  TableModel? get table => parent is TableModel ? parent as TableModel : null;

  @override
  double? get paddingTop => super.paddingTop ?? table?.paddingTop;

  @override
  double? get paddingRight => super.paddingRight ?? table?.paddingRight;

  @override
  double? get paddingBottom => super.paddingBottom ?? table?.paddingBottom;

  @override
  double? get paddingLeft => super.paddingLeft ?? table?.paddingLeft;

  @override
  String? get halign => super.halign ?? table?.halign;

  @override
  String? get valign => super.valign ?? table?.valign;

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
  bool get sortable => _sortable?.get() ?? table?.sortable ?? true;
  
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
  bool get draggable => _draggable?.get() ?? table?.draggable ?? true;

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
  bool get resizeable => _resizeable?.get() ?? table?.resizeable ?? true;

  // editable - used on non row prototype only
  BooleanObservable? _editable;
  set editable(dynamic v)
  {
    if (_editable != null)
    {
      _editable!.set(v);
    }
    else if (v != null)
    {
      _editable = BooleanObservable(Binding.toKey(id, 'editable'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool? get editable => _editable?.get() ?? table?.editable;

  // allow filtering
  BooleanObservable? _filter;
  set filter(dynamic v)
  {
    if (_filter != null)
    {
      _filter!.set(v);
    }
    else if (v != null)
    {
      _filter = BooleanObservable(Binding.toKey(id, 'filter'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get filter => _filter?.get() ?? table?.filter ?? false;
  
  TableHeaderModel(WidgetModel parent, String? id) : super(parent, id, scope: Scope(parent: parent.scope));

  static TableHeaderModel? fromXml(WidgetModel parent, XmlElement xml, {Map<dynamic, dynamic>? data})
  {
    TableHeaderModel? model;
    try
    {
      model = TableHeaderModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e, caller: 'tableHeader.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {
    // deserialize
    super.deserialize(xml);

    // properties
    sortable   = Xml.get(node: xml, tag: 'sortable');
    draggable  = Xml.get(node: xml, tag: 'draggable');
    resizeable = Xml.get(node: xml, tag: 'resizeable');
    editable   = Xml.get(node: xml, tag: 'editable');
    filter     = Xml.get(node: xml, tag: 'filter');

    // get cells
    List<TableHeaderCellModel> cells = findChildrenOfExactType(TableHeaderCellModel).cast<TableHeaderCellModel>();
    for (TableHeaderCellModel model in cells)
    {
      this.cells.add(model);
    }
  }

  @override
  dispose()
  {
    // Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
    scope?.dispose();
  }
}
