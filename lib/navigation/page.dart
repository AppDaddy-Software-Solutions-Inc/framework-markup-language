// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/fml.dart';
import 'package:fml/helpers/helpers.dart';
import 'package:fml/system.dart';

class PageConfiguration {
  String? title;
  final String? transition;

  Uri? uri;
  Route? route;

  String get breadcrumb {
    String text = title ?? uri?.toString() ?? "";
    return text.toLowerCase().split('/').last.split('.xml').first;
  }

  PageConfiguration({required this.uri, this.title, this.transition});
}

class CustomMaterialPage<T> extends MaterialPage<T> {
  final String? transition;
  const CustomMaterialPage(
    this.transition, {
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
  Route<T> createRoute(BuildContext context) =>
      CustomPageBasedMaterialPageRoute<T>(
          page: this, allowSnapshotting: allowSnapshotting);
}

class CustomPageBasedMaterialPageRoute<T> extends PageRoute<T>
    with MaterialRouteTransitionMixin<T> {
  CustomPageBasedMaterialPageRoute(
      {required MaterialPage<T> page, super.allowSnapshotting})
      : super(settings: page);

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
  Duration get transitionDuration => duration != null
      ? Duration(milliseconds: duration!)
      : super.transitionDuration;

  @override
  Duration get reverseTransitionDuration => durationBack != null
      ? Duration(milliseconds: durationBack!)
      : super.reverseTransitionDuration;

  PageTransitions get transition {
    PageTransitions? transition;
    if (settings.arguments is PageConfiguration) {
      PageConfiguration? args = settings.arguments as PageConfiguration;
      transition = toEnum(args.transition?.split(",")[0].toLowerCase().trim(),
          PageTransitions.values);
    }
    return transition ?? System.app?.transition ?? FmlEngine.defaultTransition;
  }

  int? get duration {
    if (settings.arguments is PageConfiguration) {
      PageConfiguration? args = (settings.arguments as PageConfiguration);
      var parts = args.transition?.split(",") ?? [];
      if (parts.length > 1) return toInt(parts[1]);
    }
    return null;
  }

  int? get durationBack {
    if (settings.arguments is PageConfiguration) {
      PageConfiguration? args = (settings.arguments as PageConfiguration);
      var parts = args.transition?.split(",") ?? [];
      if (parts.length > 2) return toInt(parts[2]);
    }
    return null;
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    switch (transition) {
      // no transition
      case PageTransitions.none:
        return child;

      case PageTransitions.fade:
        return const FadeUpwardsPageTransitionsBuilder().buildTransitions(
            this, context, animation, secondaryAnimation, child);

      case PageTransitions.slide:
      case PageTransitions.slideright:
        return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child);

      case PageTransitions.slideleft:
        return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child);

      case PageTransitions.zoom:
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(
              CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn)),
          child: child,
        );

      case PageTransitions.rotate:
        return RotationTransition(
          turns: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.linear,
            ),
          ),
          child: child,
        );

      // platform specific
      case PageTransitions.platform:
      default:
        PageTransitionsBuilder builder = const ZoomPageTransitionsBuilder();

        var platform = Theme.of(context).platform;
        if (platform == TargetPlatform.iOS) {
          builder = const CupertinoPageTransitionsBuilder();
        }
        if (platform == TargetPlatform.linux) {
          builder = const OpenUpwardsPageTransitionsBuilder();
        }
        if (platform == TargetPlatform.macOS) {
          builder = const FadeUpwardsPageTransitionsBuilder();
        }

        return builder.buildTransitions(
            this, context, animation, secondaryAnimation, child);
    }
  }
}
