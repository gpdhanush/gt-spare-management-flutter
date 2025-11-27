import 'package:flutter/material.dart';
import 'package:spare_management/app_pages/index.dart';
import 'package:spare_management/models/machine.dart';
import 'package:spare_management/models/unit.dart';
import 'package:spare_management/models/spare.dart';

class AppRoute {
  static const String splash = "splash";
  static const String login = "login";
  static const String home = "home";
  static const String dashboard = "dashboard";
  static const String machines = "machines";
  static const String units = "units";
  static const String spares = "spares";
  static const String spareDetails = "spare_details";
  static const String allUnits = "all_units";
  static const String allSpares = "all_spares";
  static const String globalSearch = "global_search";

  static Route<dynamic> allRoutes(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) {
        switch (settings.name) {
          case splash:
            return const SplashScreen();
          case login:
            return const LoginPage();
          case home:
            return const HomePage();
          case dashboard:
            return const DashboardPage();
          case machines:
            return const MachinesPage();
          case units:
            final args = settings.arguments as Map<String, dynamic>?;
            final machine = args?['machine'] as Machine?;
            if (machine != null) {
              return UnitsPage(machine: machine);
            }
            return const MachinesPage();
          case spares:
            final args = settings.arguments as Map<String, dynamic>?;
            final unit = args?['unit'] as Unit?;
            final machine = args?['machine'] as Machine?;
            if (unit != null && machine != null) {
              return SparesPage(unit: unit, machine: machine);
            }
            return const MachinesPage();
          case spareDetails:
            final args = settings.arguments as Map<String, dynamic>?;
            final spare = args?['spare'] as Spare?;
            final unit = args?['unit'] as Unit?;
            final machine = args?['machine'] as Machine?;
            if (spare != null && unit != null && machine != null) {
              return SpareDetailsPage(
                spare: spare,
                unit: unit,
                machine: machine,
              );
            }
            return const MachinesPage();
          case allUnits:
            return const AllUnitsPage();
          case allSpares:
            return const AllSparesPage();
          case globalSearch:
            return const GlobalSearchPage();
          default:
            return const SplashScreen();
        }
      },
    );
  }
}
