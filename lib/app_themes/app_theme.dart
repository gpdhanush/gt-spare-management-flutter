import 'package:flutter/material.dart';
import 'package:spare_management/app_themes/app_colors.dart';
import 'package:spare_management/app_themes/custom_theme.dart';

class AppThemes {
  static ThemeData getThemeByColor(Color color, bool isDark) {
    return ThemeData(
      scaffoldBackgroundColor: isDark ? Colors.grey[900] : Colors.white,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: color,
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
    );
  }

  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    fontFamily: "Roboto",
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blueAccent,
      brightness: Brightness.light,
    ),
    // colorScheme: ColorScheme.light(
    //   surface: Colors.white,
    //   primary: AppColors.primary,
    //   secondary: Colors.white60,
    // ),
    textTheme: const TextTheme(
      headlineLarge: AppTextStyles.headline1,
      titleLarge: AppTextStyles.headline2,
      bodyMedium: AppTextStyles.bodyText,
      labelLarge: AppTextStyles.button,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      elevation: 0,
      titleTextStyle: AppTextStyles.headline2,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.primary,
      selectionColor: AppColors.primary.withAlpha(200),
      selectionHandleColor: AppColors.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: AppTextStyles.buttonStyle,
        elevation: 0,
        foregroundColor: Colors.white,
        backgroundColor: AppColors.primary,
        disabledForegroundColor: AppColors.gray,
        disabledBackgroundColor: AppColors.primary.withAlpha(130),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        elevation: 0,
        foregroundColor: AppColors.primary,
        textStyle: AppTextStyles.textButtonStyle,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
    ),
    datePickerTheme: DatePickerThemeData(
      headerBackgroundColor: AppColors.primary,
      headerForegroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 5,
      dayStyle: TextStyle(fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      todayBorder: BorderSide(color: AppColors.primary),
      confirmButtonStyle: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(AppColors.primary),
        foregroundColor: WidgetStatePropertyAll(Colors.white),
        textStyle: WidgetStatePropertyAll(
          TextStyle(decoration: TextDecoration.none),
        ),
      ),
      cancelButtonStyle: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(Colors.redAccent),
        foregroundColor: WidgetStatePropertyAll(Colors.white),
        textStyle: WidgetStatePropertyAll(
          TextStyle(decoration: TextDecoration.none),
        ),
      ),
      dayOverlayColor: WidgetStatePropertyAll(AppColors.primary),
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return Colors.black;
      }),
      dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return Colors.transparent;
      }),
      todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (!states.contains(WidgetState.selected)) {
          return Colors.transparent;
        }
        return AppColors.primary;
      }),
      todayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (!states.contains(WidgetState.selected)) {
          return Colors.black;
        }
        return Colors.white;
      }),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.grey[900],
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blueAccent,
      brightness: Brightness.dark,
    ),
  );
}
