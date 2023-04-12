// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/decorated/decorated_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class GridItemModel extends DecoratedWidgetModel
{
  Map? map;

  String? type;

  bool selected = false;

  ///////////
  /* dirty */
  ///////////
  BooleanObservable? _dirty;
  BooleanObservable? get dirtyObservable  => _dirty;
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
  bool get dirty => _dirty?.get() ?? false;

  GridItemModel(WidgetModel parent, String?  id, {dynamic data, String?  type, dynamic backgroundcolor}) : super(parent, id, scope: Scope(parent: parent.scope))
  {
    this.data = data;
    this.type = type;
  }

  static GridItemModel? fromXml(WidgetModel parent, XmlElement? xml, {dynamic data})
  {
    GridItemModel? model;
    try
    {
      // build model
      model = GridItemModel(parent, Xml.get(node: xml, tag: 'id'), data: data);
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e, caller: 'grid.item.Model');
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
    type       = Xml.get(node: xml, tag: 'type');
  }

  @override
  dispose()
  {
    // Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
    scope?.dispose();
  }
}