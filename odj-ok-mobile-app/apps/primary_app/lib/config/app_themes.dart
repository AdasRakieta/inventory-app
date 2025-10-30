import 'package:flutter/material.dart';
import 'package:ok_mobile_common/ok_mobile_common.dart';

class AppThemes {
  static ThemeData appLightTheme = ThemeData(
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.darkGreen,
      onPrimary: Colors.white,
      secondary: Colors.purple,
      onSecondary: Colors.white,
      error: Colors.red,
      onError: Colors.black,
      surface: AppColors.lightGrey,
      surfaceTint: Colors.transparent,
      onSurface: Colors.black,
    ),
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    useMaterial3: true,

    fontFamily: AppTextStyle.openSans,
    textTheme: const TextTheme(
      bodySmall: TextStyle(
        fontFamily: AppTextStyle.openSans,
        fontSize: 12,
        color: AppColors.white,
      ),
      bodyMedium: TextStyle(
        fontFamily: AppTextStyle.openSans,
        fontSize: 13,
        color: AppColors.white,
      ),
      bodyLarge: TextStyle(
        fontFamily: AppTextStyle.openSans,
        fontSize: 16,
        color: AppColors.white,
      ),
      titleSmall: TextStyle(
        fontFamily: AppTextStyle.openSans,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        height: 1.1,
        color: AppColors.white,
      ),
      titleMedium: TextStyle(
        fontFamily: AppTextStyle.openSans,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1.1,
        color: AppColors.black,
      ),
      titleLarge: TextStyle(
        fontFamily: AppTextStyle.openSans,
        fontSize: 20,
        color: AppColors.white,
      ),
      labelSmall: TextStyle(
        fontFamily: AppTextStyle.openSans,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        color: AppColors.white,
      ),
      labelMedium: TextStyle(
        fontFamily: AppTextStyle.openSans,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        color: Colors.black,
      ),
      labelLarge: TextStyle(
        fontFamily: AppTextStyle.openSans,
        fontSize: 15,
        color: Colors.white,
      ),
      headlineLarge: TextStyle(
        fontFamily: AppTextStyle.oswald,
        color: AppColors.white,
      ),
    ),

    elevatedButtonTheme: const ElevatedButtonThemeData(
      style: ButtonStyle(
        elevation: WidgetStatePropertyAll(0),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
    ),

    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      isDense: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: AppColors.darkGrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: AppColors.darkGrey),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: AppColors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: AppColors.red),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: AppColors.darkGrey),
      ),
      activeIndicatorBorder: BorderSide(color: AppColors.darkGrey),
      outlineBorder: BorderSide(color: AppColors.darkGrey),
    ),
  );
}
