// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:collection/collection.dart';
import 'package:flutter/animation.dart';
import 'package:fml/data/data.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/scope.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/dragdrop/drag_drop_interface.dart';
import 'package:fml/widgets/dragdrop/dragdrop.dart';
import 'package:fml/widgets/form/form_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:xml/xml.dart';
import 'package:fml/helpers/helpers.dart';

class PrototypeModel extends BoxModel
{
  // data sourced prototype
  XmlElement? prototype;

  // IDataSource
  IDataSource? myDataSource;

  @override
  bool get expand => false;

  PrototypeModel(WidgetModel parent, String? id) : super(parent, id, scope: parent.scope);

  static PrototypeModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    PrototypeModel? model;
    try
    {
      // build model
      model = PrototypeModel(parent, null);
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e, caller: 'prototype.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {
    // make a copy of the element
    var root  = XmlElement(XmlName("PROTOTYPE"));
    var child = xml.copy();
    root.children.add(child);

    // add the datasource attribute to the root node
    root.attributes.add(XmlAttribute(XmlName("datasource"), Xml.attribute(node: xml, tag: 'data') ?? Xml.attribute(node: xml, tag: 'datasource') ?? "missing"));

    // remove the datasource attribute from the child
    Xml.removeAttribute(child, "data");
    Xml.removeAttribute(child, "datasource");

    // deserialize the outer root
    // this is necessary since lower level child nodes may also
    // use the prototypeOf() method and change
    // necessary "data.xxx" references.
    super.deserialize(root);

    // register listener
    if (datasource != null && scope != null)
    {
      IDataSource? source = scope!.getDataSource(datasource);
      source?.register(this);
    }

    // build the prototype
    prototype = prototypeOf(child);

    // dispose of all children
    children?.forEach((child) => child.dispose());
    children?.clear();
  }

  @override
  Future<bool> onDataSourceSuccess(IDataSource source, Data? list) async
  {
    if (prototype == null || source.id != datasource) return super.onDataSourceSuccess(source, list);

    // save pointer to data source
    myDataSource = source;

    // set busy
    busy = true;

    // build children from datasource
    List<WidgetModel> models = [];
    if (list != null)
    {
      for (var data in list)
      {
        // find model from list
        WidgetModel? model = children?.firstWhereOrNull((child)
        {
          if (child.data == data) return true;
          if (child.data is List && (child.data as List).isNotEmpty && (child.data as List).first == data) return true;
          return false;
        });

        // create the model if it doesn't already exist
        model ??= WidgetModel.fromXml(this, prototype!.copy(), scope: Scope(parent: parent?.scope), data: data);

        // add model to the list
        if (model != null)
        {
          models.add(model);
        }
      }
    }

    // dispose of unused children
    children ??= [];
    for (var child in children!)
    {
      if (!models.contains(child))
      {
        child.dispose();
      }
    }
    children!.clear();

    // add back all models
    children!.addAll(models);

    // notify of data changes
    // this forces an index change
    // for (var child in children!)
    // {
    //   // child.onDataChange();
    // }

    // rebuild form fields
    // this could be done differently
    var form = findAncestorOfExactType(FormModel);
    if (form is FormModel)
    {
      form.setFormFields();
    }

    // clear busy
    busy = false;

    return true;
  }

  void onDragDrop(IDragDrop droppable, IDragDrop draggable, {Offset? dropSpot}) async
  {
    // fire onDrop event
    await DragDrop.onDrop(droppable, draggable, dropSpot: dropSpot);

    // get drag and drop index
    var dragIndex = children?.contains(draggable as WidgetModel) ?? false ? children?.indexOf(draggable as WidgetModel) : null;
    var dropIndex = children?.contains(droppable as WidgetModel) ?? false ? children?.indexOf(droppable as WidgetModel) : null;

    // move the cell in the items list
    if (dragIndex != null && dropIndex != null && dragIndex != dropIndex)
    {
      // move the cell in the dataset
      myDataSource?.move(dragIndex, dropIndex, notifyListeners: true);
    }
  }
}
