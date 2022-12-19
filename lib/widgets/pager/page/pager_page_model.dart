// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/decorated_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/helper_barrel.dart';

class PagerPageModel extends DecoratedWidgetModel
{
  /////////
  /* url */
  /////////
  StringObservable? _url;
  set url (dynamic v)
  {
    if (_url != null)
    {
      _url!.set(v);
    }
    else if (v != null)
    {
      _url = StringObservable(Binding.toKey(id, 'url'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get url => _url?.get();

  PagerPageModel(WidgetModel? parent, String? id, {dynamic data, dynamic url}) : super(parent, id, scope: Scope(id))
  {
    this.data = data;
    this.url = url;
  }

  static PagerPageModel? fromXml(WidgetModel? parent, XmlElement? xml, {dynamic data, dynamic onTap, dynamic onLongPress})
  {
    PagerPageModel? model;
    try
    {
      // build model
      model = PagerPageModel(parent, Xml.get(node: xml, tag: 'id'), data: data);
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'pager.page.Model');
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
    url = Xml.get(node: xml, tag: 'url');
  }

  @override
  dispose()
  {
    Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }
}