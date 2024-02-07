// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/observable/observables/string.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/table/table_header_cell_model.dart';
import 'package:fml/widgets/table/table_header_model.dart';
import 'package:fml/widgets/text/text_model.dart';
import 'package:fml/widgets/viewable/viewable_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:xml/xml.dart';
import 'package:fml/helpers/helpers.dart';

class TableHeaderGroupModel extends BoxModel
{
  // rendered group models
  List<TableHeaderGroupModel> get groups => findChildrenOfExactType(TableHeaderGroupModel).cast<TableHeaderGroupModel>();

  // rendered cell models
  List<TableHeaderCellModel> get cells => findChildrenOfExactType(TableHeaderCellModel).cast<TableHeaderCellModel>();

  // header
  TableHeaderModel? get hdr => parent is TableHeaderModel ? parent as TableHeaderModel : parent is TableHeaderGroupModel ? (parent as TableHeaderGroupModel).hdr : null;

  // column has a user defined layout
  bool usesRenderer = false;

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

  @override
  double? get width => null;
  double? get widthOuter => super.width;

  @override
  double? get height => null;
  double? get heightOuter => super.height;

  // onChange - only used for simple data grid
  StringObservable? _onChange;
  set onChange(dynamic v)
  {
    if (_onChange != null)
    {
      _onChange!.set(v);
    }
    else if (v != null)
    {
      _onChange = StringObservable(Binding.toKey(id, 'onchange'), v, scope: scope);
    }
  }
  String? get onChange => _onChange?.get();

  // onInsert
  StringObservable? _onInsert;
  set onInsert(dynamic v)
  {
    if (_onInsert != null)
    {
      _onInsert!.set(v);
    }
    else if (v != null)
    {
      _onInsert = StringObservable(Binding.toKey(id, 'oninsert'), v, scope: scope, lazyEval: true);
    }
  }
  String? get onInsert => _onInsert?.get();

  // onDelete
  StringObservable? _onDelete;
  set onDelete(dynamic v)
  {
    if (_onDelete != null)
    {
      _onDelete!.set(v);
    }
    else if (v != null)
    {
      _onDelete = StringObservable(Binding.toKey(id, 'ondelete'), v, scope: scope, lazyEval: true);
    }
  }
  String? get onDelete => _onDelete?.get();

  // name - used by grid display
  StringObservable? _title;
  set title(dynamic v)
  {
    if (_title != null)
    {
      _title!.set(v);
    }
    else if (v != null)
    {
      _title = StringObservable(Binding.toKey(id, 'title'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get title => _title?.get();

  TableHeaderGroupModel(WidgetModel parent, String? id) : super(parent, id);

  static TableHeaderGroupModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    TableHeaderGroupModel? model;
    try
    {
      model = TableHeaderGroupModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e, caller: 'column.Model');
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
    title = Xml.get(node:xml, tag: 'title');
    if (_title == null)
    {
      TextModel? text = findChildOfExactType(TextModel);
      title = text?.value;
    }

    // events
    onInsert    = Xml.get(node: xml, tag: 'oninsert');
    onDelete    = Xml.get(node: xml, tag: 'ondelete');
    onChange    = Xml.get(node:xml, tag: 'onchange');
  }

  bool hasDescendantCells()
  {
    if (cells.isNotEmpty) return true;
    for (var group in groups){
      if (group.hasDescendantCells()) return true;
    }
    return false;
  }

  @override
  List<ViewableWidgetModel> get viewableChildren
  {
    // we dont want to render TD and TG cells in the table group header
    List<ViewableWidgetModel> list = super.viewableChildren;
    list.removeWhere((child) => child is TableHeaderCellModel || child is TableHeaderGroupModel);
    return list;
  }
}
