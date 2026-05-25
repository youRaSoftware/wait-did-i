import 'package:core/core.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppThemeProvider(
      initialTokens: LightTokens(),
      builder: (BuildContext context) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          theme: context.theme.copyWith(
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: <TargetPlatform, PageTransitionsBuilder>{
                TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              },
            ),
          ),
          darkTheme: context.theme.copyWith(
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: <TargetPlatform, PageTransitionsBuilder>{
                TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              },
            ),
          ),
          routeInformationParser: appLocator<AppRouter>().router.routeInformationParser,
          routeInformationProvider: appLocator<AppRouter>().router.routeInformationProvider,
          routerDelegate: appLocator<AppRouter>().router.routerDelegate,
          // builder: (BuildContext _, Widget? child) {
          //   return MediaQuery(
          //     data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
          //     child: Overlay(
          //       initialEntries: <OverlayEntry>[
          //         OverlayEntry(
          //           builder: (BuildContext overlayContext) {
          //             final double statusBarHeight = MediaQuery.of(overlayContext).padding.top;

          //             return Stack(
          //               children: <Widget>[
          //                 ToastService().build(child),
          //                 if (statusBarHeight > 0)
          //                   Positioned(
          //                     top: 0,
          //                     left: 0,
          //                     right: 0,
          //                     child: ClipRect(
          //                       child: BackdropFilter(
          //                         filter: ImageFilter.blur(
          //                           sigmaX: AppDimens.size10,
          //                           sigmaY: AppDimens.size10,
          //                         ),
          //                         child: Container(
          //                           height: statusBarHeight,
          //                           color: overlayContext.currentTokens.color.bgPage.withValues(alpha: 0.4),
          //                         ),
          //                       ),
          //                     ),
          //                   ),
          //               ],
          //             );
          //           },
          //         ),
          //       ],
          //     ),
          //   );
          // },
        );
      },
    );
  }
}
