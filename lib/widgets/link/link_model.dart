// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/column/column_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xml/xml.dart';
import 'package:fml/event/handler.dart' ;
import 'package:fml/widgets/link/link_view.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class LinkModel extends ColumnModel
{
  @override
  bool get expand => false;
  
  // url
  StringObservable? _url;
  set url(dynamic v)
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
  String? get url
  {
    return _url?.get();
  }

  // onclick
  StringObservable? _onclick;
  set onclick(dynamic v)
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
  String? get onclick
  {
    return _onclick?.get();
  }

  // onlongpress
  StringObservable? _onlongpress;
  set onlongpress(dynamic v)
  {
    if (_onlongpress != null)
    {
      _onlongpress!.set(v);
    }
    else if (v != null)
    {
      _onlongpress = StringObservable(Binding.toKey(id, 'onlongpress'), v, scope: scope, listener: onPropertyChange, lazyEval: true);
    }
  }
  String? get onlongpress {
    return _onlongpress?.get();
  }

  // ondoubletap
  StringObservable? _ondoubletap;
  set ondoubletap(dynamic v)
  {
    if (_ondoubletap != null)
    {
      _ondoubletap!.set(v);
    }
    else if (v != null)
    {
      _ondoubletap = StringObservable(Binding.toKey(id, 'ondoubletap'), v, scope: scope, listener: onPropertyChange, lazyEval: true);
    }
  }
  String? get ondoubletap
  {
    return _ondoubletap?.get();
  }

  // hint
  StringObservable? _hint;
  set hint(dynamic v)
  {
    if (_hint != null)
    {
      _hint!.set(v);
    }
    else if (v != null)
    {
      _hint = StringObservable(Binding.toKey(id, 'hint'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get hint => _hint?.get();

  LinkModel(
    WidgetModel parent,
    String? id, {
      dynamic url,
    dynamic onclick,
    dynamic enabled,
    dynamic ondoubletap,
    dynamic hint,
    dynamic onlongpress,
  }) : super(parent, id) {
    this.url = url;
    this.onclick = onclick;
    this.enabled = enabled;
    this.hint = hint;
    this.onlongpress = onlongpress;
    this.ondoubletap = ondoubletap;
  }

  static LinkModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    LinkModel? model;
    try
    {
      // build model
      model = LinkModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      model = null;
      Log().exception(e,  caller: 'link.Model');
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
    enabled     = Xml.get(node: xml, tag: 'enabled');
    hint        = Xml.get(node: xml, tag: 'hint');
    onlongpress = Xml.get(node: xml, tag: 'onlongpress');
    ondoubletap = Xml.get(node: xml, tag: 'ondoubletap');
    url         = Xml.get(node: xml, tag: 'url');
    onclick     = Xml.get(node: xml, tag: 'onclick');
  }

  @override
  dispose()
  {
// Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  Future<bool> onClick(BuildContext context) async {
    if (!S.isNullOrEmpty(url))
    {
      if (url!.startsWith('tel:') || url!.startsWith('geo:') ||
          url!.startsWith('mailto:') || url!.startsWith('smsto:') ||
          url!.startsWith('facetime:') || url!.startsWith('facetime-audio:'))
      {
        Uri? uri = Uri.tryParse(url!);
        if (uri != null) launchUrl(uri);
      }
    }
    if (onclick == null) return true;
    return await EventHandler(this).execute(_onclick);
  }

  Future<bool> onLongPress(BuildContext context) async {
    if (onlongpress == null) return true;
    return await EventHandler(this).execute(_onlongpress);
  }

  Future<bool> onDoubleTap(BuildContext context) async {
    if (ondoubletap == null) return true;
    return await EventHandler(this).execute(_ondoubletap);
  }

  @override
  Widget getView({Key? key}) => getReactiveView(LinkView(this));
}
