// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/data/data.dart';
import 'package:fml/datasources/iDataSource.dart';
import 'package:fml/widgets/decorated/decorated_widget_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/widgets/pager/pager_view.dart';
import 'package:fml/widgets/pager/page/pager_page_model.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class PagerModel extends DecoratedWidgetModel 
{
  PageController? controller;

  // prototype
  String? prototype;

  // pages
  List<PagerPageModel> pages = [];

  ///////////
  /* pager */
  ///////////
  BooleanObservable? _pager;
  set pager (dynamic v)
  {
    if (_pager != null)
    {
      _pager!.set(v);
    }
    else if (v != null)
    {
      _pager = BooleanObservable(Binding.toKey(id, 'pager'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get pager => _pager?.get() ?? true;

  /////////////////
  /* initialpage */
  /////////////////
  IntegerObservable? _initialpage;
  set initialpage (dynamic v)
  {
    if (_initialpage != null)
    {
      _initialpage!.set(v);
    }
    else if (v != null)
    {
      _initialpage = IntegerObservable(Binding.toKey(id, 'initialpage'), v, scope: scope, listener: onPropertyChange);
    }
  }
  int? get initialpage
  {
    int v = _initialpage?.get() ?? 1;
    if (v <= 0) v = 1;
    return v;
  }

  /////////////////
  /* currentpage */
  /////////////////
  IntegerObservable? _currentpage;
  set currentpage (dynamic v)
  {
    if (_currentpage != null)
    {
      if (pages.isNotEmpty && v > pages.length) {
        _currentpage!.set(pages.length);
      } else if (v < 1 || v == null) {
        _currentpage!.set(1);
      } else {
        _currentpage!.set(v ?? initialpage ?? 1);
      }
    }
    else if (v != null)
    {
      _currentpage = IntegerObservable(Binding.toKey(id, 'currentpage'), v, scope: scope, listener: onPropertyChange);
    }
  }
  int get currentpage
  {
    int v = _currentpage?.get() ?? 1;
    if (v <= 0) v = 1;
    return v;
  }

  PagerModel(WidgetModel parent, String? id,
  {
    dynamic pager,
    dynamic initialpage,
    dynamic currentpage,
    dynamic color,
  }) : super(parent, id)
  {
    // instantiate busy observable
    busy = false;

    this.pager = pager;
    this.initialpage = initialpage;
    this.currentpage = currentpage;
    this.color = color;
  }

  static PagerModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    PagerModel? model;
    try
    {
      model = PagerModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'pager.Model');
      model = null;
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
    pager = Xml.get(node: xml, tag: 'pager');

    // build pages
    List<PagerPageModel> pages = findChildrenOfExactType(PagerPageModel).cast<PagerPageModel>();

      // set prototype
      if ((!S.isNullOrEmpty(datasource)) && (pages.isNotEmpty))
      {
        prototype = S.toPrototype(pages[0].element.toString());
        pages.removeAt(0);
      }

      // build items
      for (var page in pages) {
        this.pages.add(page);
      }


    if (pages.isEmpty)
    {
      XmlDocument missingXml = XmlDocument.parse('<PAGE><CENTER><TEXT value="Missing <Page /> Element" /></CENTER></PAGE>');
      var page = PagerPageModel.fromXml(this, missingXml.rootElement);
      if (page != null) this.pages.add(page);
    }

    initialpage = Xml.get(node: xml, tag: 'initialpage');
    currentpage = Xml.get(node: xml, tag: 'currentpage');
  }

  @override
  Future<bool> onDataSourceSuccess(IDataSource source, Data? list) async
  {
    busy = true;

    // build pages
    int i = 0;
    if ((list != null))
    {
      // clear pages
      for (var model in pages) {
        model.dispose();
      }
      pages.clear();

      for (var row in list) {
        XmlElement? prototype = S.fromPrototype(this.prototype, "$id-$i");
        i = i + 1;

        var model = PagerPageModel.fromXml(parent, prototype, data: row);
        if (model != null) pages[i] = model;
      }

      notifyListeners('list', pages);
    }

    busy = false;

    return true;
  }

  @override
  dispose()
  {
    // Log().debug ('dispose called on' + elementName);

    // clear pages
    for (var model in pages) {
      model.dispose();
    }
    pages.clear();

    super.dispose();
  }
  
  @override
  Widget getView({Key? key}) => getReactiveView(PagerView(this));
}
