// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:fml/application/application_model.dart';
import 'package:fml/template/template.dart';
import 'package:fml/widgets/framework/framework_model.dart';
import 'package:fml/widgets/overlay/overlay_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/navigation/page.dart';
import 'package:fml/navigation/navigation_observer.dart';
import 'package:fml/navigation/transition.dart';
import 'package:fml/phrase.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/framework/framework_view.dart' ;
import 'package:fml/store/store_view.dart';
import 'package:fml/page404/page404_view.dart';
import 'package:fml/widgets/overlay/overlay_view.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/helper/common_helpers.dart';

class NavigationManager extends RouterDelegate<PageConfiguration> with ChangeNotifier, PopNavigatorRouterDelegateMixin<PageConfiguration>
{
  // singleton
  static final NavigationManager _singleton = NavigationManager._internal();
  factory NavigationManager() => _singleton;

  // holds the navigation stack
  final _pages = <Page>[];
  List<Page> get pages => List.unmodifiable(_pages);
  MaterialPage? dummyPage;

  NavigationManager._internal()
  {
    dummyPage = _buildPage("/", child: Offstage());
    _addPage(dummyPage!);
  }

  Future<void> _initialize() async
  {
    // clear all pages
    _pages.clear();

    // set default app
    if (isWeb || appType == ApplicationTypes.SingleApp)
    {
      var domain = defaultDomain;

      // replace default for testing
      if (isWeb && kDebugMode)
      {
        var uri = Uri.tryParse(Uri.base.toString());
        if (uri != null && !uri.host.toLowerCase().startsWith("localhost")) domain = uri.url;
      }

      // set default app
      ApplicationModel app = await ApplicationModel.load(url: domain) ?? ApplicationModel(System(), url: domain);

      // wait for it to initialize
      await app.initialized;

      // start the app
      System().launchApplication(app);
    }

    // get home page
    String? homePage = System.app?.homePage ?? "store";
    if (!isWeb && appType == ApplicationTypes.MultiApp) homePage = "store";

    // get start page
    String startPage = System.app?.startPage ?? homePage;

    // start page is different than home page?
    if (homePage.split("?")[0].toLowerCase() != startPage.split("?")[0].toLowerCase())
    {
      // fetch the template
      Template? template = await Template.fetch(url: startPage, refresh: true);

      // document is linkable?
      // default - if singlePageApplication then false, otherwise true
      bool linkable = S.toBool(Xml.attribute(node: template.document!.rootElement, tag: "linkable")) ?? System.app?.singlePage ?? false;

      // set start page = home page if not linkable
      if (!linkable) startPage = homePage;

      // single page applications always load the home page
      if (System.app?.singlePage ?? true) startPage = homePage;
    }

    //  web browser - user hit refresh?
    //if ((System().getNavigationType() == 1) && (!System().singlePageApplication)) page = System().requestedPage;

    // open the page
    setNewRoutePath(PageConfiguration(url: startPage), source: "splash");
  }

  Future<void> onPageLoaded() async
  {
    // open the requested page
    if (System.app?.startPage != null && System.app?.started == false)
    {
      // open the requested page
      _open(System.app?.startPage);

      // clear requested page so we don't continually
      // open the same page on refresh or reload
      System.app?.started = true;
    }
  }

  @override
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  PageConfiguration? get currentConfiguration
  {
    return _pages.isNotEmpty ? _pages.last.arguments as PageConfiguration? : PageConfiguration(url: "/", title: "Dummy");
  }

  FrameworkView? frameworkOf()
  {
    if (pages.isNotEmpty)
    {
      var page = pages.last;
      if (page is MaterialPage && page.child is OverlayManager)
      {
         var manager  = page.child as OverlayManager;
         if (manager.child is FrameworkView) return manager.child as FrameworkView;
      }
    }
    return null;
  }

  @override
  Future<void> setNewRoutePath(PageConfiguration configuration, {String source = "system"}) async
  {
    // initialize
    if (pages.isNotEmpty && pages.first == dummyPage) return _initialize();

    // deeplink specified
    String? url = configuration.url;
    if ((!isWeb) && (source == "system"))
    {
      url = await _buildDeeplinkUrl(url);
      if (url == null) return;
    }

    // page in navigation history?
    var page;
    if ((url == "/") && (_pages.isNotEmpty))
         page = _pages.first;
    else page = _pages.reversed.firstWhereOrNull((page) => (page.name == url));

    // navigate back to the page if found in the navigation history
    if (page != null)
    {
      while ((_pages.isNotEmpty) && (_pages.last != page)) _pages.removeLast();
      notifyListeners();
    }
    
    // open a new page
    else _open(url, transition: configuration.transition);
  }

  @override
  Widget build(BuildContext context)
  {
    TransitionDelegate transitionDelegate = Transition();
    return Navigator(key: navigatorKey, pages: List.of(_pages), onPopPage: _onPopPage,  transitionDelegate: transitionDelegate, observers: [NavigationObserver()],);
  }

  @override
  Future<bool> popRoute()
  {
    // this only fires on mobile
    if (_pages.length > 1)
         return _goback(1);
    else return _confirmAppExit();
  }

  Future<String?> _buildDeeplinkUrl(String? url) async
  {
    // empty url?
    if (url == null) return null;
    if (url.startsWith("/")) url = url.replaceFirst("/", "");
    if (url.isEmpty) return null;

    Uri? uri = Uri.tryParse(url);
    if (uri == null) return null;

    // deep links must be fully qualified
    if (!uri.hasScheme) return null;

    // clear all pages
    _pages.clear();

    // set fqdn
    // String fqdn = "${uri.scheme}://${uri.host}";

    // set default domain
    //await System().setDomain(fqdn);

    // default home page
    //if (uri.pathSegments.isEmpty) url = Application?.homePage;

    return url;
  }

  bool _onPopPage(Route route, dynamic result)
  {
    if (!route.didPop(result)) return false;
    popRoute();
    return true;
  }

  MaterialPage _buildPage(String url, {required child, transition})
  {
    if (!url.startsWith("/")) url = "/$url";

    var configuration = PageConfiguration(url: url, transition: transition);
    var page = MaterialPage(child: child, name: url, arguments: configuration);

    return page;
  }

  void _addPage(MaterialPage page, {int? index})
  {
    PageConfiguration? args = page.arguments as PageConfiguration?;

    // if you open the exact same page as was on the top of the stack, simply return
    if ((_pages.isNotEmpty) && (_pages.last.arguments is PageConfiguration) && ((_pages.last.arguments as PageConfiguration).url == args!.url)) return;

    if (index != null)
    {
           if (index >= _pages.length) _pages.add(page);
      else if (index < (_pages.length * -1)) _pages.insert(0, page);
      else if (index >= 0) _pages.insert(index, page);
      else if (index < 0)  _pages.insert(_pages.length + index, page);
      else Log().error('Unable to add page at index: $index name: ${args!.title}, url: ${args.url}', caller: 'delegate.dart');
    }
    else _pages.add(page);
    notifyListeners();
  }

  Future<bool> _goback(int pages) async
  {
    // set absolute
    pages = pages.abs();

    // anything more than the stack size, set to stack size - 1
    if (_pages.length - pages < 1) pages = _pages.length - 1;

    // cannot go past the end of the nav stack
    if (pages == 0) return false;

    // web?
    bool ok = await Platform.goBackPages(pages);
    if (ok) return true;

    for (int i = 0; i < pages; i++) _pages.removeLast();
    notifyListeners();
    return true;
  }

  int? positionInStack(BuildContext context)
  {
    int? index;
    try
    {
      Page? page;

      var route = ModalRoute.of(context);
      if ((route?.settings != null) && (route!.settings is Page)) page = (route.settings as Page);

      // position 0 implies top of stack, 1 page before, ... etc
      if (page != null && _pages.contains(page)) index = (_pages.length - _pages.indexOf(page) - 1).abs();
    }
    catch(e){}
    return index;
  }

  Page? getPage(BuildContext context)
  {
    Page? page;
    try
    {
      var route = ModalRoute.of(context);
      if ((route?.settings != null) && (route!.settings is Page)) page = (route.settings as Page);
    }
    catch(e){}
    return page;
  }

  Future<bool> open(Map<String, String?>? parameters, {bool? refresh = false, WidgetModel? model, String? dependency}) async
  {
    bool ok = true;
    if (parameters == null) parameters = Map<String, String>();

    String url         = S.mapVal(parameters,'url',defaultValue: "");
    bool?   modal      = S.mapBoo(parameters,'modal', defaultValue: false);
    String? transition = S.mapVal(parameters,'transition');
    String? width      = S.mapVal(parameters,'width');
    String? height     = S.mapVal(parameters,'height');
    int?  index        = S.mapInt(parameters,'index');
    bool? replace      = S.mapBoo(parameters,'replace', defaultValue: false);
    bool? replaceAll   = S.mapBoo(parameters,'replaceall', defaultValue: false);

    var uri = URI.parse(url);
    if (uri == null) return false;

    var d1 = uri.host.toLowerCase();
    var d2 = System.app?.host?.toLowerCase();

    bool sameDomain = d1 == d2;
    bool xmlFile    = uri.pageExtension == "xml";
    bool local      = sameDomain && xmlFile;

    // We need to keep the file:// prefix as an indicator for fetch() that its a local file
    String? template = uri.domain.toLowerCase();

    // missing template?
    if (S.isNullOrEmpty(template))
    {
      //await DialogService().show(type: DialogType.error, title: phrase.missingTemplate, description: url, buttons: [Text(phrase.ok)]);
      return ok;
    }

    // open external url in browser?
    if (!local) return _openBrowser(url);

    // open new page in modal window?
    if (modal == true)
    {
      FrameworkModel model = FrameworkModel.fromUrl(System.app!, url, refresh: refresh ?? false, dependency: dependency);
      FrameworkView  view  = FrameworkView(model);
      return openModal(view, NavigationManager().navigatorKey.currentContext, modal: false, width: width, height: height) != null;
    }

    /* replace */
    if (replace! && _pages.isNotEmpty) _pages.removeLast();

    /* replace all */
    if (replaceAll!) _pages.clear();

    /* open a new page */
    _open(url, transition: transition, index: index, dependency: dependency);

    return ok;
  }

  Future<void> _open(String? url,{String? transition, bool refresh = false, int? index, String? dependency}) async
  {
    if (url == null) return;

    Widget view;
    switch(url)
    {
      case "store":
        view = StoreView();
        break;

      case "missing":
        view = Page404View(url);
        break;

      default:
        view =  OverlayManager(child: FrameworkView(FrameworkModel.fromUrl(System.app!, url, refresh: refresh, dependency: dependency)));
        break;
    }

    // build page
    MaterialPage page = _buildPage(url, child: view, transition: transition);

    // push the page
    _addPage(page, index: index);
  }

  Future<bool> back(dynamic until) async
  {
    bool ok = true;

    // determine number of pages to go back
    int? pages;
    if (until is int) pages = until;
    if (until is String)
    {
      // match by index
      if (until.startsWith('[') && until.endsWith(']'))
      {
        pages = S.toInt(until.substring(1, until.length - 1)) ?? -1;
      }

      // match by name
      else
      {
        if (!until.startsWith("/")) until = "/$until";
        Page? page = _pages.lastWhereOrNull((page) {
          // make sure we leave args off for the comparison
          String name = page.name ?? '';
          return name.split('?')[0] == until;
        });
        if ((page != null) && (_pages.last != page)) pages = _pages.length - _pages.indexOf(page) - 1;
      }
    }

    // go back
    if (pages != null) ok = await _goback(pages);

    return ok;
  }

  Future<bool> refresh() async
  {
    bool ok = true;
    try
    {
      var context = NavigationManager().navigatorKey.currentContext;
      if (context == null) return ok;

      // remove last page from pages list
      if (_pages.isNotEmpty)
      {
        // get last page
        Page page = _pages.last;
        PageConfiguration configuration = (page.arguments as PageConfiguration);

        // remove last page
        _pages.removeLast();

        // reload the same page
        _open(configuration.url, transition: configuration.transition, refresh: true);
      }
    }
    catch(e)
    {
      Log().exception(e);
    }
    return ok;
  }

  Future<bool> _confirmAppExit() async
  {
    final result;
    if (navigatorKey.currentContext != null) {
      result = await showDialog<bool>(
          context: navigatorKey.currentContext!,
          builder: (context) {
            return AlertDialog(
              title: const Text('Exit App'),
              content: const Text('Are you sure you want to exit the app?'),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context, true),
                ),
                TextButton(
                  child: const Text('Confirm'),
                  onPressed: () => Navigator.pop(context, false),
                ),
              ],
            );
          });}
    else
      result = true;
    return result;
  }

  OverlayView? openModal(Widget view, BuildContext? context, {bool modal = true, bool resizeable = true, bool closeable = true, bool draggable = true, String? width, String? height})
  {
    OverlayView? overlay;
    OverlayManager? manager = context != null ? context.findAncestorWidgetOfExactType<OverlayManager>() : null;
    if (manager != null)
    {
      overlay = OverlayView(child: view, modal: modal, resizeable: resizeable, closeable: closeable, draggable: draggable, width: _toWidth(width), height: _toHeight(height));
      manager.overlays.add(overlay);
      manager.refresh();
    }
    return overlay;
  }

  bool closeModal(OverlayView? overlay, BuildContext? context)
  {
    if ((overlay == null) || (overlay.closeable == false)) return true;
    overlay.close();
    OverlayManager? manager = context != null ? context.findAncestorWidgetOfExactType<OverlayManager>() : null;
    if (manager != null) manager.refresh();
    return true;
  }

  Future<bool> _openBrowser(String url) async
  {
      bool ok = true;
      try
      {
        // parse url
        Uri? uri = Uri.tryParse(url);

        // launch the browser
        if (uri != null) await launchUrl(uri);
      }
      catch(e)
      {
        await System.toast("${phrase.cannotLaunchURL} $url");
        Log().error("${phrase.cannotLaunchURL} $url");
        ok = false;
      }
      return ok;
  }

  double? _toWidth(String? value)
  {
    if (S.isNullOrEmpty(value)) return null;
    double? width;
    try
    {
      if (value!.endsWith("%"))
      {
        width = S.toDouble(value.substring(0, value.length - 1));
        if (navigatorKey.currentContext != null && width != null)
        {
          var size = MediaQuery.of(navigatorKey.currentContext!).size.width;
          width = size * (width / 100);
        }
      }
      else width = S.toDouble(value);
    }
    catch(e)
    {
      Log().error("Error getting width. Error is $e");
    }
    return width;
  }

  double? _toHeight(String? value)
  {
    if (S.isNullOrEmpty(value)) return null;
    double? height;
    try
    {
      if (value!.endsWith("%"))
      {
        height = S.toDouble(value.substring(0, value.length - 1));
        if (navigatorKey.currentContext != null && height != null)
        {
          var size = MediaQuery.of(navigatorKey.currentContext!).size.height;
          height   = size * (height / 100);
        }
      }
      else height = S.toDouble(value);
    }
    catch(e)
    {
      Log().error("Error getting height. Error is $e");
    }
    return height;
  }


 void setPageTitle(BuildContext context, String? title)
  {
    if (!S.isNullOrEmpty(title))
    {
      Page? page = getPage(context);
      if ((page is MaterialPage) && (page.arguments is PageConfiguration)) (page.arguments as PageConfiguration).title = title;
    }
  }
}
