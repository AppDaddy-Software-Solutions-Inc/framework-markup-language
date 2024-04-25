// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:collection/collection.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/table/table_model.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/widgets/table/table_footer_cell_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

class TableFooterModel extends BoxModel {
  @override
  String? get layout => super.layout ?? "column";

  // rendered cell models
  final List<TableFooterCellModel> cells = [];

  // dynamic cells
  bool get isDynamic => prototypes.isNotEmpty;
  List<XmlElement> prototypes = [];

  // cell by index
  TableFooterCellModel? cell(int index) =>
      index >= 0 && index < cells.length ? cells[index] : null;

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

  TableFooterModel(Model super.parent, super.id)
      : super(scope: Scope(parent: parent.scope));

  static TableFooterModel? fromXml(Model parent, XmlElement xml,
      {Map<dynamic, dynamic>? data}) {
    TableFooterModel? model;
    try {
      model = TableFooterModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'tableFooter.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {
    // deserialize
    super.deserialize(xml);

    // get header cells
    cells.addAll(
        findDescendantsOfExactType(TableFooterCellModel, breakOn: TableModel)
            .cast<TableFooterCellModel>());

    // remove cells from child list
    removeChildrenOfExactType(TableFooterCellModel);

    // build dynamic prototypes
    _buildDynamicPrototypes();
  }

  void _buildDynamicPrototypes() {
    bool hasDynamicCells =
        cells.firstWhereOrNull((cell) => cell.isDynamic) != null;
    if (hasDynamicCells) {
      for (var cell in cells) {
        var e = cell.element!.copy();
        if (cell.isDynamic) {
          e.attributes.add(XmlAttribute(XmlName("dynamic"), ""));
        }
        prototypes.add(e);
      }
    }
  }

  @override
  dispose() {
    super.dispose();

    // dispose of cells
    for (var cell in cells) {
      cell.dispose();
    }
  }
}
