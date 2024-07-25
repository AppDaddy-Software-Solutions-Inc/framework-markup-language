// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/observable/observables/string.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/table/table_footer_model.dart';
import 'package:fml/widgets/table/table_model.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:xml/xml.dart';
import 'package:fml/helpers/helpers.dart';

enum ColumnTypes { string, numeric, date, time }

class TableFooterCellModel extends BoxModel {
  // header
  TableFooterModel? get hdr =>
      parent is TableFooterModel ? parent as TableFooterModel : null;

  // cell is dynamic?
  bool get isDynamic =>
      ((element?.toString().contains(TableModel.dynamicTableValue1) ?? false) ||
          (element?.toString().contains(TableModel.dynamicTableValue2) ??
              false)) &&
      (hdr?.table?.hasDataSource ?? false);

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

  // position in row
  int get index => hdr?.cells.indexOf(this) ?? -1;


  // field - name of field in data set (non row prototype only)
  StringObservable? _field;
  set field(dynamic v) {
    if (_field != null) {
      _field!.set(v);
    } else if (v != null) {
      _field = StringObservable(Binding.toKey(id, 'field'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String? get field => _field?.get();

  TableFooterCellModel(Model super.parent, super.id);

  static TableFooterCellModel? fromXml(Model parent, XmlElement xml) {
    TableFooterCellModel? model;
    try {
      model = TableFooterCellModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'column.Model');
      model = null;
    }
    return model;
  }

  static TableFooterCellModel? fromXmlString(Model parent, String xml) {
    XmlDocument? document = Xml.tryParse(xml);
    return (document != null)
        ? TableFooterCellModel.fromXml(parent, document.rootElement)
        : null;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {

    // field - used to drive simple tables for performance
    field = Xml.get(node: xml, tag: 'field');

    // deserialize
    super.deserialize(xml);
  }
}
