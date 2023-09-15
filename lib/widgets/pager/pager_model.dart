// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/data/data.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/pager/page/page_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/widgets/pager/pager_view.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class PagerModel extends BoxModel
{
  @override
  LayoutType layoutType = LayoutType.stack;

  @override
  bool get expand => true;

  @override
  bool get center => true;

  PageController? controller;

  // prototype
  XmlElement? prototype;

  List<PageModel> pages = [];
  
  // pager
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

  // currentpage
  IntegerObservable? _currentpage;
  set currentpage (dynamic v)
  {
    if (_currentpage != null)
    {
      _currentpage!.set(v);
    }
    else if (v != null)
    {
      _currentpage = IntegerObservable(Binding.toKey(id, 'currentpage'), v, scope: scope, listener: onPropertyChange, setter: _pageSetter);
    }
  }
  int get currentpage
  {
    int v = _currentpage?.get() ?? 1;
    return v;
  }

  // transition - slide or jump
  StringObservable? _transition;
  set transition (dynamic v)
  {
    if (_transition != null)
    {
      _transition!.set(v);
    }
    else if (v != null)
    {
      _transition = StringObservable(Binding.toKey(id, 'transition'), v, scope: scope);
    }
  }
  String get transition =>  _transition?.get() ?? 'jump';

  dynamic _pageSetter(dynamic value)
  {
    int? v = S.toInt(value);
    if (v == null) {
      return value;
    }
    if (pages.isNotEmpty && v > pages.length) {
      v = pages.length;
    } else if (v < 1) {
      v = 1;
    }
    return v;
  }

  PagerModel(WidgetModel parent, String? id,
  {
    dynamic pager,
    dynamic currentpage,
    dynamic color,
  }) : super(parent, id)
  {
    // instantiate busy observable
    busy = false;

    this.pager = pager;
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
    transition = Xml.get(node: xml, tag: 'transition');

    // build pages
    List<PageModel> pages = findChildrenOfExactType(PageModel).cast<PageModel>();

    // set prototype
    if ((!S.isNullOrEmpty(datasource)) && (pages.isNotEmpty))
    {
      prototype = WidgetModel.prototypeOf(pages[0].element);
      pages.removeAt(0);
    }

    // build items
    for (var page in pages) {
      this.pages.add(page);
    }


    if (pages.isEmpty)
    {
      XmlDocument missingXml = XmlDocument.parse('<PAGE><CENTER><TEXT value="Missing <Page /> Element" /></CENTER></PAGE>');
      var page = PageModel.fromXml(this, missingXml.rootElement);
      if (page != null) this.pages.add(page);
    }

    currentpage = Xml.get(node: xml, tag: 'initialpage') ?? 1;
  }

  //we need a reset function to set the controller back to 0 without ticking.
  @override
  Future<bool?> execute(
      String caller, String propertyOrFunction, List<dynamic> arguments) async {
    /// setter
    if (scope == null) return null;
    var function = propertyOrFunction.toLowerCase().trim();
    switch (function)
    {
      case "pageto":
      case "page":
        var view = findListenerOfExactType(PagerViewState);
        if (view is PagerViewState)
        {
          int page = 0;
          String transition = this.transition;

          // page
          if (arguments.isNotEmpty)
          {
            page = S.toInt(arguments[0]) ?? 0;
          }

          // transition
          if (arguments.length > 1)
          {
            transition = S.toStr(arguments[1]) ?? this.transition;
          }

          view.pageTo(page, transition);
        }
        break;

      case "jumpto":
      case "jump":
        var view = findListenerOfExactType(PagerViewState);
        if (view is PagerViewState)
        {
          int page = 0;
          String transition = "jump";

          // page
          if (arguments.isNotEmpty)
          {
            page = S.toInt(arguments[0]) ?? 0;
          }
          view.pageTo(page, transition);
        }
        break;

      case "slideto":
      case "slide":
        var view = findListenerOfExactType(PagerViewState);
        if (view is PagerViewState)
        {
          int page = 0;
          String transition = "slide";

          // page
          if (arguments.isNotEmpty)
          {
            page = S.toInt(arguments[0]) ?? 0;
          }
          view.pageTo(page, transition);
        }
        break;
    }
    return super.execute(caller, propertyOrFunction, arguments);
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

      for (var row in list)
      {
        i = i + 1;
        var model = PageModel.fromXml(parent, prototype, data: row);
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
  List<Widget> inflate()
  {
    PagerViewState? view = findListenerOfExactType(PagerViewState);
    if (view == null) return [];
    return view.inflate();
  }

  @override
  Widget getView({Key? key}) => getReactiveView(PagerView(this));
}
