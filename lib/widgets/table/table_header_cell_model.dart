// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/event/handler.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/observable/observables/boolean.dart';
import 'package:fml/observable/observables/string.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/table/table_header_group_model.dart';
import 'package:fml/widgets/table/table_header_model.dart';
import 'package:fml/widgets/table/table_model.dart';
import 'package:fml/widgets/text/text_model.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:xml/xml.dart';
import 'package:fml/helpers/helpers.dart';

enum ColumnTypes { string, numeric, date, time }

class TableHeaderCellModel extends BoxModel {
  // header
  TableHeaderModel? get hdr => parent is TableHeaderModel
      ? parent as TableHeaderModel
      : parent is TableHeaderGroupModel
          ? (parent as TableHeaderGroupModel).hdr
          : null;

  // cell is dynamic?
  bool get isDynamic =>
      ((element?.toString().contains(TableModel.dynamicTableValue1) ?? false) ||
          (element?.toString().contains(TableModel.dynamicTableValue2) ??
              false)) &&
      (hdr?.table?.hasDataSource ?? false);

  // column has a user defined layout
  bool usesRenderer = false;

  // column render contains enterable fields (input, etc)
  bool hasEnterableFields = false;

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

  @override
  String? get layout => super.layout ?? "column";

  // column type
  StringObservable? _type;
  set type(dynamic v) {
    if (_type != null) {
      _type!.set(v);
    } else if (v != null) {
      _type = StringObservable(Binding.toKey(id, 'type'), v, scope: scope);
    }
  }

  String? get type => _type?.get();

  // allow sorting
  BooleanObservable? _menu;
  set menu(dynamic v) {
    if (_menu != null) {
      _menu!.set(v);
    } else if (v != null) {
      _menu = BooleanObservable(Binding.toKey(id, 'menu'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool get menu => _menu?.get() ?? hdr?.menu ?? true;

  // allow sorting
  BooleanObservable? _sortable;
  set sortable(dynamic v) {
    if (_sortable != null) {
      _sortable!.set(v);
    } else if (v != null) {
      _sortable = BooleanObservable(Binding.toKey(id, 'sortable'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool get sortable => _sortable?.get() ?? hdr?.sortable ?? true;

  // allow resizing
  BooleanObservable? _resizeable;
  set resizeable(dynamic v) {
    if (_resizeable != null) {
      _resizeable!.set(v);
    } else if (v != null) {
      _resizeable = BooleanObservable(Binding.toKey(id, 'resizeable'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool get resizeable => _resizeable?.get() ?? hdr?.resizeable ?? true;

  // column uses editable
  bool get maybeEditable => _editable != null;

  // editable - used on non row prototype only
  BooleanObservable? _editable;
  set editable(dynamic v) {
    if (_editable != null) {
      _editable!.set(v);
    } else if (v != null) {
      _editable = BooleanObservable(Binding.toKey(id, 'editable'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  bool get editable => _editable?.get() ?? hdr?.editable ?? false;

  // allow filtering
  BooleanObservable? _filter;
  set filter(dynamic v) {
    if (_filter != null) {
      _filter!.set(v);
    } else if (v != null) {
      _filter = BooleanObservable(Binding.toKey(id, 'filter'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool get filter => _filter?.get() ?? hdr?.filter ?? false;

  // name - used by grid display
  StringObservable? _title;
  set title(dynamic v) {
    if (_title != null) {
      _title!.set(v);
    } else if (v != null) {
      _title = StringObservable(Binding.toKey(id, 'title'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String? get title => _title?.get();

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

  // position in row
  int get index => hdr?.cells.indexOf(this) ?? -1;

  // onChange - only used for simple data grid
  StringObservable? _onChange;
  set onChange(dynamic v) {
    if (_onChange != null) {
      _onChange!.set(v);
    } else if (v != null) {
      _onChange =
          StringObservable(Binding.toKey(id, 'onchange'), v, scope: scope);
    }
  }

  String? get onChange => _onChange?.get();

  TableHeaderCellModel(Model super.parent, super.id);

  static TableHeaderCellModel? fromXml(Model parent, XmlElement xml) {
    TableHeaderCellModel? model;
    try {
      model = TableHeaderCellModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'column.Model');
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
    title = Xml.get(node: xml, tag: 'title');
    if (_title == null) {
      title = Xml.get(node: xml, tag: 'sort')
          ?.split(",")[0]
          .replaceFirst(RegExp('data.', caseSensitive: false), "");
    }
    if (_title == null) {
      TextModel? text = findChildOfExactType(TextModel);
      title = text?.value;
    }

    // field - used to drive simple tables for performance
    field = Xml.get(node: xml, tag: 'field') ?? title;

    //type - denotes the field type. used for sorting
    type = Xml.get(node: xml, tag: 'type');

    // context menu
    menu = Xml.get(node: xml, tag: 'menu');
    sortable = Xml.get(node: xml, tag: 'sortable');
    resizeable = Xml.get(node: xml, tag: 'resizeable');
    editable = Xml.get(node: xml, tag: 'editable');
    filter = Xml.get(node: xml, tag: 'filter');
    onChange = Xml.get(node: xml, tag: 'onchange');

    // build default cell
    if (children?.isEmpty ?? true) _buildDefaultBody();
  }

  void _buildDefaultBody() {
    var node = XmlElement(XmlName("TEXT"));
    Xml.setAttribute(node, "value", field);
    var text = TextModel.fromXml(this, node);
    if (text != null) {
      children ??= [];
      children!.add(text);
    }
  }

  // on change handler - fired on cell edit
  Future<bool> onChangeHandler() async =>
      _onChange != null ? await EventHandler(this).execute(_onChange) : true;
}
