// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/datasources/transforms/sort.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/table/table_header_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:xml/xml.dart';
import 'package:fml/helper/common_helpers.dart';

class TableHeaderCellModel extends BoxModel
{
  @override
  LayoutType get layoutType => LayoutType.column;

  // position in row
  int? get index
  {
    if ((parent != null) && (parent is TableHeaderModel))
    {
      return (parent as TableHeaderModel).cells.indexOf(this);
    }
    return null;
  }

  // sort
  String? sortBy;
  SortTypes sortType = SortTypes.none;

  // field
  String? field;

  TableHeaderCellModel(WidgetModel parent, String? id) : super(parent, id);

  static TableHeaderCellModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    TableHeaderCellModel? model;
    try
    {
      model = TableHeaderCellModel(parent, null);
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
    field  = Xml.get(node: xml, tag: 'field');

    var sortString = Xml.get(node: xml, tag: 'sort');
    if (!S.isNullOrEmpty(sortString))
    {
      var s = sortString!.split(',');
      if (s.isNotEmpty && !S.isNullOrEmpty(s[0]))
      {
        sortBy = s[0];
      }
    }
  }
}
