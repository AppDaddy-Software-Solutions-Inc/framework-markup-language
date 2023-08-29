// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/widgets/table/table_header_cell_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class TableHeaderModel extends BoxModel
{
  // cells
  final List<TableHeaderCellModel> cells = [];

  // cell by index
  TableHeaderCellModel? cell(int index) => index >= 0 && index < cells.length ? cells[index] : null;

  /// Allows header to be resized by dragging
  /// Defaults to true
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
  bool get draggable => _draggable?.get() ?? true;

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
    bordercolor = Xml.get(node: xml, tag: 'bordercolor');
    borderwidth = Xml.get(node: xml, tag: 'borderwidth');

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
