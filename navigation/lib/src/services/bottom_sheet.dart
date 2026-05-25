import 'package:flutter/material.dart';
import '../../navigation.dart';

extension AppRouterBottomSheet on AppRouter {
  Future<T?> showBottomSheetWidget<T>({
    required Widget contentWidget,
    StackRouter? parentRouter,
    bool isDismissible = true,
    Color? backgroundColor,
  }) async {
    final BuildContext? context = parentRouter?.navigatorKey.currentContext ?? navigatorKey.currentContext;
    if (context == null) {
      return null;
    }
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width,
      ),
      backgroundColor: backgroundColor ?? Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
          ),
          child: contentWidget,
        );
      },
    );
  }
}
