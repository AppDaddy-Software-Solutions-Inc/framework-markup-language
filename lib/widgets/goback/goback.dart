import 'package:flutter/material.dart';
import 'package:fml/navigation/navigation_manager.dart';

typedef CanGoBackCallback = Future<bool?> Function();

class GoBack extends StatelessWidget {
  const GoBack({
    required this.child,
    required this.canGoBack,
    super.key,
  });

  final Widget child;
  final CanGoBackCallback canGoBack;

  @override
  Widget build(BuildContext context)
  {
    return PopScope(canPop: false, child: child,
      onPopInvoked: (popped) async
      {
        if (popped) return;
        bool? ok = await canGoBack();
        if (ok == true) NavigationManager().back(1, force: true);
      });
  }
}