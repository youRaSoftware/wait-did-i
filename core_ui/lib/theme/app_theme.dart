import 'dart:async';
import 'dart:developer';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core_ui.dart';

export 'generate/tokens.g.dart';

part 'theme_provider.dart';

class AppThemeData {
  static ThemeData createTheme(ITokens tokens) {
    return ThemeData(
      useMaterial3: true,
      buttonTheme: ButtonThemeData(
        buttonColor: tokens.color.colorBrandCoral,
        textTheme: ButtonTextTheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      colorScheme: _createColorScheme(tokens),
      textTheme: _createTextTheme(tokens),
      appBarTheme: _createAppBarTheme(tokens),
      scaffoldBackgroundColor: tokens.color.colorBackgroundPrimary,
      inputDecorationTheme: _createInputDecorationTheme(tokens),
      bottomNavigationBarTheme: _createBottomNavigationBarTheme(tokens),
    );
  }

  static ColorScheme _createColorScheme(ITokens tokens) {
    final ColorTokens colors = tokens.color;
    final bool isDark = colors.colorBackgroundPrimary.computeLuminance() < 0.5;

    return ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: colors.colorBrandCoral,
      onPrimary: colors.colorTextInverse,
      secondary: colors.colorBrandPeach,
      onSecondary: colors.colorTextInverse,
      tertiary: colors.colorBrandLavender,
      onTertiary: colors.colorTextInverse,
      error: colors.colorStateError,
      onError: colors.colorTextInverse,
      surface: colors.colorBackgroundSurface,
      onSurface: colors.colorTextPrimary,
      surfaceContainerHighest: colors.colorBackgroundElevated,
    );
  }

  static TextTheme _createTextTheme(ITokens tokens) {
    return TextTheme(
      displayLarge: tokens.textStyle.displayXl,
      displayMedium: tokens.textStyle.display,
      displaySmall: tokens.textStyle.headline,
      headlineLarge: tokens.textStyle.title,
      headlineMedium: tokens.textStyle.subtitle,
      bodyLarge: tokens.textStyle.bodyLarge,
      bodyMedium: tokens.textStyle.body,
      bodySmall: tokens.textStyle.bodySmall,
      labelLarge: tokens.textStyle.button,
      labelMedium: tokens.textStyle.caption,
      labelSmall: tokens.textStyle.overline,
    );
  }

  static AppBarTheme _createAppBarTheme(ITokens tokens) {
    final ColorTokens colors = tokens.color;
    final bool isDark = colors.colorBackgroundPrimary.computeLuminance() < 0.5;

    return AppBarTheme(
      systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      backgroundColor: colors.colorBackgroundPrimary,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(
        color: colors.colorBrandCoral,
      ),
      titleTextStyle: tokens.textStyle.title,
    );
  }

  static InputDecorationTheme _createInputDecorationTheme(ITokens tokens) {
    final ColorTokens colors = tokens.color;

    return InputDecorationTheme(
      errorStyle: tokens.textStyle.caption.copyWith(
        color: colors.colorStateError,
      ),
      labelStyle: tokens.textStyle.bodySmall.copyWith(
        color: colors.colorTextSecondary,
      ),
      floatingLabelStyle: tokens.textStyle.bodySmall.copyWith(
        color: colors.colorTextPrimary,
      ),
      hintStyle: tokens.textStyle.bodySmall.copyWith(
        color: colors.colorTextTertiary,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.colorBorderDefault),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.colorBorderDefault),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.colorBorderFocus, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.colorStateError),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.colorStateError, width: 2),
      ),
    );
  }

  static BottomNavigationBarThemeData _createBottomNavigationBarTheme(ITokens tokens) {
    final ColorTokens colors = tokens.color;

    return BottomNavigationBarThemeData(
      elevation: 0,
      backgroundColor: colors.colorBackgroundSurface,
      selectedItemColor: colors.colorBrandCoral,
      unselectedItemColor: colors.colorTextSecondary,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      showSelectedLabels: true,
    );
  }
}
