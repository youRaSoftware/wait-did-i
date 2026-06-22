import 'package:flutter/material.dart';

import '../../theme/app_dimens.dart';
import '../../theme/app_theme.dart';
import 'custom_app_bar.dart';

/// App scaffold with a flat header.
class AppScaffold extends StatelessWidget {
  final Widget body;
  final bool showAppBar;
  final bool showBackButton;
  final bool applyTopPadding;
  final Color? backgroundColor;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final List<Widget>? persistentFooterButtons;
  final Widget? bottomNavigationBar;
  final Widget? appBar;
  final Widget? leading;
  final Widget? title;
  final List<Widget>? actions;
  final VoidCallback? onBack;

  const AppScaffold({
    required this.body,
    this.showAppBar = true,
    this.showBackButton = true,
    this.applyTopPadding = false,
    this.backgroundColor,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.persistentFooterButtons,
    this.bottomNavigationBar,
    this.appBar,
    this.leading,
    this.title,
    this.actions,
    this.onBack,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ColorTokens color = context.currentTokens.color;
    final EdgeInsets systemPadding = MediaQuery.of(context).padding;
    const double appBarContentHeight = AppDimens.size50;
    final double appBarTotalHeight = systemPadding.top + appBarContentHeight;
    final Color background = backgroundColor ?? color.colorBackgroundPrimary;

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: background,
      appBar: showAppBar
          ? PreferredSize(
              preferredSize: Size.fromHeight(appBarTotalHeight),
              child: DecoratedBox(
                decoration: BoxDecoration(color: background),
                child: Padding(
                  padding: EdgeInsets.only(top: systemPadding.top),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: appBarContentHeight),
                    child:
                        appBar ??
                        CustomAppBar(
                          showBackButton: showBackButton,
                          leading: leading,
                          title: title,
                          actions: actions,
                          onBack: onBack,
                        ),
                  ),
                ),
              ),
            )
          : null,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      persistentFooterButtons: persistentFooterButtons,
      body: applyTopPadding
          ? Padding(
              padding: EdgeInsets.only(top: appBarTotalHeight),
              child: body,
            )
          : body,
    );
  }
}
