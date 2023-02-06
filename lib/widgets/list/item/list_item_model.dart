// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/datasources/iDataSource.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/form/iFormField.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/decorated_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:xml/xml.dart';
import 'package:fml/widgets/form/form_model.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class ListItemModel extends DecoratedWidgetModel
{
  Map? map;

  String? type;
  List<IFormField>? fields;

  // posting source source
  List<String>? _postbrokers;
  set postbrokers(dynamic v)
  {
    if (v is String)
    {
      List<String> values = v.split(",");
      _postbrokers = [];
      values.forEach((e)
      {
        if (!S.isNullOrEmpty(e)) _postbrokers!.add(e.trim());
      });
    }
  }
  List<String>? get postbrokers => _postbrokers;

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
    if (fields != null)
      for (IFormField field in fields!)
      {
        if ((field.dirty ?? false))
        {
          isDirty = true;
          break;
        }
      }
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

  bool selected = false;

  ListItemModel(WidgetModel parent, String?  id, {dynamic data, String?  type, dynamic backgroundcolor, dynamic margin}) : super(parent, id, scope: Scope(parent: parent.scope))
  {
    this.data             = data;
    this.type             = type;
    this.backgroundcolor  = backgroundcolor;
    this.dirty            = false;
    this.margin           = margin;
    this.title            = title;
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

    // find all descendants
    List<dynamic>? fields = findDescendantsOfExactType(null);
    if (fields != null)
      fields.forEach((field)
      {
        // form field?
        if (field is IFormField)
        {
          // Build Fields
          if (this.fields == null) this.fields = [];
          this.fields!.add(field);

          // Register Listener to Dirty Field
          if (field.dirtyObservable != null) field.dirtyObservable!.registerListener(onDirtyListener);
        }
      });
  }

  Future<bool> complete() async
  {
    busy = true;

    bool ok = true;

    //////////////////
    /* Post the Row */
    //////////////////
    if (ok) ok = await _post();

    ////////////////
    /* Mark Clean */
    ////////////////
    if ((ok) && (fields != null)) fields!.forEach((field) => field.dirty = false);

    busy = false;

    return ok;
  }

  Future<bool> _post() async
  {
    if (dirty == false) return true;

    bool ok = true;
    if ((scope != null) && (postbrokers != null))
      for (String id in postbrokers!)
      {
        IDataSource? source = scope!.getDataSource(id);
        if ((source != null) && (ok))
        {
          if (source.custombody != true) source.body = await FormModel.buildPostingBody(fields, rootname: source.root ?? "FORM");
          ok = await source.start();
        }
        if (!ok) break;
      }
    else ok = false;
    return ok;
  }

  @override
  dispose()
  {
    Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
    scope?.dispose();
  }
}