import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:spare_management/app_configs/app_constants.dart';
import 'package:spare_management/app_configs/size_configs.dart';
import 'package:spare_management/app_pages/index.dart';
import 'package:spare_management/app_themes/app_colors.dart';
import 'package:spare_management/app_themes/app_theme.dart';

import 'app_configs/app_routes.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      runApp(const MyApp());
    },
    (error, stack) {
      debugPrint("Main Error: ${error.toString()}");
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constrains) {
        return OrientationBuilder(
          builder: (context, orientation) {
            SizeConfig().get(constrains, orientation);
            final Color barColor = AppColors.primary;
            final SystemUiOverlayStyle overlay = SystemUiOverlayStyle(
              statusBarColor: barColor,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.light,
              systemStatusBarContrastEnforced: false,
              systemNavigationBarContrastEnforced: false,
            );
            SystemChrome.setSystemUIOverlayStyle(overlay);
            return MaterialApp(
              title: "Spare Management",
              debugShowCheckedModeBanner: false,
              themeMode: ThemeMode.system,
              onGenerateRoute: AppRoute.allRoutes,
              navigatorKey: AppConstants.navigatorKey,
              builder: EasyLoading.init(),
              theme: AppThemes.lightTheme,
              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}
