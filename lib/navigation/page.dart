// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/helpers/helpers.dart';

class PageConfiguration
{
  String? title;
  final String? transition;

  Uri? uri;
  Route? route;

  String get breadcrumb
  {
    String text = title ?? uri?.toString() ?? "";
    return text.toLowerCase().split('/').last.split('.xml').first;
  }

  PageConfiguration({required this.uri, this.title, this.transition});
}

class CustomMaterialPage<T> extends MaterialPage<T>
{
  final String? transition;
  const CustomMaterialPage(this.transition, {
    required super.child,
    super.maintainState,
    super.fullscreenDialog,
    super.allowSnapshotting,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  @override
  Route<T> createRoute(BuildContext context) => CustomPageBasedMaterialPageRoute<T>(page: this, allowSnapshotting: allowSnapshotting);
}

class CustomPageBasedMaterialPageRoute<T> extends PageRoute<T> with MaterialRouteTransitionMixin<T> {

  CustomPageBasedMaterialPageRoute({required MaterialPage<T> page, super.allowSnapshotting}) : super(settings: page);

  MaterialPage<T> get _page => settings as MaterialPage<T>;

  @override
  Widget buildContent(BuildContext context) => _page.child;

  @override
  bool get maintainState => _page.maintainState;

  @override
  bool get fullscreenDialog => _page.fullscreenDialog;

  @override
  String get debugLabel => '${super.debugLabel}(${_page.name})';

  @override
  Duration get transitionDuration => duration != null ? Duration(milliseconds: duration!) : super.transitionDuration;

  @override
  Duration get reverseTransitionDuration => durationBack != null ? Duration(milliseconds: durationBack!) : super.reverseTransitionDuration;

  String? get transition
  {
    if (settings.arguments is PageConfiguration)
    {
      PageConfiguration? args = settings.arguments as PageConfiguration;
      return args.transition?.split(",")[0].toLowerCase().trim();
    }
    return null;
  }

  int? get duration
  {
    if (settings.arguments is PageConfiguration)
    {
      PageConfiguration? args = (settings.arguments as PageConfiguration);
      var parts = args.transition?.split(",") ?? [];
      if (parts.length > 1) return toInt(parts[1]);
    }
    return null;
  }

  int? get durationBack
  {
    if (settings.arguments is PageConfiguration)
    {
      PageConfiguration? args = (settings.arguments as PageConfiguration);
      var parts = args.transition?.split(",") ?? [];
      if (parts.length > 2) return toInt(parts[2]);
    }
    return null;
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child)
  {
    switch(transition) {
      case 'ios':
      case 'macos':
      case 'slide':
        return SlideTransition(position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero,).animate(animation), child: child,);

      case 'android':
        return ScaleTransition(
            scale: animation.drive(Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.ease))),
            child: FadeTransition(opacity: animation, child: child));

      case 'fade':
      case 'windows':
      case 'linux':
        return FadeTransition(opacity: animation, child: child);

      case 'slideleft':
        return SlideTransition(position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero,).animate(animation), child: child);

      case 'slide':
      case 'slideright':
        return SlideTransition(position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero,).animate(animation), child: child);

      case 'zoom':
        return ScaleTransition(scale: Tween<double>(begin: 0.0, end: 1.0,)
            .animate(CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn)), child: child,);

      case 'rotate':
        return RotationTransition(turns: Tween<double>(begin: 0.0, end: 1.0,)
            .animate(CurvedAnimation(parent: animation, curve: Curves.linear,),), child: child,);

      // default flutter transition
      default:
        return FadeUpwardsPageTransitionsBuilder().buildTransitions(this, context, animation, secondaryAnimation, child);
    }
  }
}




