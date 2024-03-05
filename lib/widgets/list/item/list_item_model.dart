// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/event/handler.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/dragdrop/drag_drop_interface.dart';
import 'package:fml/widgets/form/form_field_interface.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/list/list_model.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:xml/xml.dart';
import 'package:fml/widgets/form/form_model.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

class ListItemModel extends BoxModel
{
  Map? map;

  String? type;
  List<IFormField>? fields;

  // table
  ListModel? get list => parent is ListModel ? parent as ListModel : null;

  // posting source source
  List<String>? _postbrokers;
  set postbrokers(dynamic v)
  {
    if (v is String)
    {
      List<String> values = v.split(",");
      _postbrokers = [];
      for (var e in values) {
        if (!isNullOrEmpty(e)) _postbrokers!.add(e.trim());
      }
    }
  }
  List<String>? get postbrokers => _postbrokers;

  // indicates if this item has been selected
  BooleanObservable? _selected;
  set selected (dynamic v)
  {
    if (_selected != null)
    {
      _selected!.set(v);
    }
    else if (v != null)
    {
      _selected = BooleanObservable(Binding.toKey(id, 'selected'), v, scope: scope);
    }
  }
  bool? get selected =>  _selected?.get();

  // indicates that this item can be selected
  // by clicking it
  BooleanObservable? _selectable;
  set selectable (dynamic v)
  {
    if (_selectable != null)
    {
      _selectable!.set(v);
    }
    else if (v != null)
    {
      _selectable = BooleanObservable(Binding.toKey(id, 'selectable'), v, scope: scope);
    }
  }
  bool get selectable =>  _selectable?.get() ?? true;


  /// [Event]s to execute when the item is clicked
  StringObservable? _onclick;
  set onclick (dynamic v)
  {
    if (_onclick != null)
    {
      _onclick!.set(v);
    }
    else if (v != null)
    {
      _onclick = StringObservable(Binding.toKey(id, 'onclick'), v, scope: scope, listener: onPropertyChange, lazyEval: true);
    }
  }
  String? get onclick => _onclick?.get();

  // dataset  index
  // This property indicates your position on the dataset, 0 being the top
  IntegerObservable? get indexObservable => _index;
  IntegerObservable? _index;
  set index (dynamic v)
  {
    if (_index != null)
    {
      _index!.set(v);
    }
    else if (v != null)
    {
      _index = IntegerObservable(Binding.toKey(id, 'index'), v, scope: scope);
    }
  }
  int? get index
  {
    if (_index == null) return -1;
    return _index?.get();
  }

  ///////////
  /* dirty */
  ///////////
  BooleanObservable? get dirtyObservable => _dirty;
  BooleanObservable? _dirty;
  set dirty (dynamic v)
  {
    if (_dirty != null)
    {
      _dirty!.set(v);
    }
    else if (v != null)
    {
      _dirty = BooleanObservable(Binding.toKey(id, 'dirty'), v, scope: scope);
    }
  }
  bool get dirty =>  _dirty?.get() ??  false;

  void onDirtyListener(Observable property)
  {
    bool isDirty = false;
    if (fields != null){
      for (IFormField field in fields!)
      {
        if ((field.dirty ?? false))
        {
          isDirty = true;
          break;
        }
      }}
    dirty = isDirty;
  }

  //////////////////////
  /* background color */
  //////////////////////
  ColorObservable? _backgroundcolor;
  set backgroundcolor (dynamic v)
  {
    if (_backgroundcolor != null)
    {
      _backgroundcolor!.set(v);
    }
    else if (v != null)
    {
      _backgroundcolor = ColorObservable(Binding.toKey(id, 'backgroundcolor'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get backgroundcolor =>  _backgroundcolor?.get();

  ////////////
  /* margin */
  ////////////
  DoubleObservable? _margin;
  set margin (dynamic v)
  {
    if (_margin != null)
    {
      _margin!.set(v);
    }
    else if (v != null)
    {
      _margin = DoubleObservable(Binding.toKey(id, 'margin'), v, scope: scope);
    }
  }
  double get margin =>_margin?.get() ?? 10;

  ///////////
  /* title */
  ///////////
  StringObservable? _title;
  set title (dynamic v)
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

  ListItemModel(WidgetModel super.parent, super.id, {super.data, dynamic selected, dynamic onclick, this.type, dynamic title, dynamic backgroundcolor, dynamic margin}) : super(scope: Scope(parent: parent.scope))
  {
    this.backgroundcolor  = backgroundcolor;
    dirty                 = false;
    this.margin           = margin;
    title                 = title;
    this.selected         = selected;
    this.onclick          = onclick;
  }

  static ListItemModel? fromXml(WidgetModel parent, XmlElement? xml, {dynamic data})
  {
    ListItemModel? model;
    try
    {
      // build model
      model = ListItemModel(parent, Xml.get(node: xml, tag: 'id'), data: data);
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e, caller: 'item.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement? xml)
  {
    if (xml == null) return;

    // deserialize 
    super.deserialize(xml);

    // properties
    type            = Xml.get(node: xml, tag: 'type');
    backgroundcolor = Xml.get(node: xml, tag: 'backgroundcolor');
    margin          = Xml.get(node: xml, tag: 'margin');
    title           = Xml.get(node: xml, tag: 'title');
    postbrokers     = Xml.attribute(node: xml, tag: 'postbroker');
    selected        = Xml.get(node: xml, tag: 'selected');
    selectable      = Xml.get(node: xml, tag: 'selectable');
    onclick         = Xml.get(node: xml, tag: 'onclick');
    onInsert        = Xml.get(node: xml, tag: 'onInsert');
    onDelete        = Xml.get(node: xml, tag: 'onDelete');

    // find all descendants
    List<dynamic>? fields = findDescendantsOfExactType(null);
    for (var field in fields) {
      // form field?
      if (field is IFormField)
      {
        // Build Fields
        if (this.fields == null) this.fields = [];
        this.fields!.add(field);

        // Register Listener to Dirty Field
        if (field.dirtyObservable != null) field.dirtyObservable!.registerListener(onDirtyListener);
      }
    }
  }

  Future<bool> complete() async
  {
    busy = true;

    bool ok = true;

    // post the row
    if (ok) ok = await _post();

    // mark clean
    if ((ok) && (fields != null)){ for (var field in fields!) {
      field.dirty = false;
    }}

    busy = false;

    return ok;
  }

  Future<bool> _post() async
  {
    if (dirty == false) return true;

    bool ok = true;
    if ((scope != null) && (postbrokers != null)){
      for (String id in postbrokers!)
      {
        IDataSource? source = scope!.getDataSource(id);
        if (source != null && ok && list != null)
        {
          if (!source.custombody)
          {
            source.body = await FormModel.buildPostingBody(list!, fields, rootname: source.root ?? "FORM");
          }
          ok = await source.start();
        }
        if (!ok) break;
      }}
    else {
      ok = false;
    }
    return ok;
  }

  Future<bool> onTap() async
  {
    if (parent is ListModel)
    {
      (parent as ListModel).onTap(this);
    }
    await EventHandler(this).execute(_onclick);
    return true;
  }

  @override
  void onDrop(IDragDrop draggable, {Offset? dropSpot}) async
  {
    if (parent is ListModel)
    {
      (parent as ListModel).onDragDrop(this, draggable, dropSpot: dropSpot);
    }
  }

  Future<bool> onInsertHandler() async
  {
    // fire the onchange event
    bool ok = true;
    if (_onInsert != null)
    {
      ok = await EventHandler(this).execute(_onInsert);
    }
    return ok;
  }

  Future<bool> onDeleteHandler() async
  {
    // fire the onchange event
    bool ok = true;
    if (_onDelete != null)
    {
      ok = await EventHandler(this).execute(_onDelete);
    }
    return ok;
  }

  @override
  dispose()
  {
    // Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
    scope?.dispose();
  }
}