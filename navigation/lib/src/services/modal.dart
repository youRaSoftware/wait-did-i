import 'package:flutter/material.dart';
import '../../navigation.dart';

extension AppRouterDialog on AppRouter {
  Future<T?> showModal<T>({
    required Widget contentWidget,
    StackRouter? parentRouter,
    Color? backgroundColor,
    bool barrierDismissible = true,
    String? barrierLabel,
  }) async {
    final BuildContext? context = parentRouter?.navigatorKey.currentContext ?? navigatorKey.currentContext;
    if (context == null) {
      return null;
    }
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel,
      builder: (BuildContext context) {
        return contentWidget;
      },
    );
  }
}
