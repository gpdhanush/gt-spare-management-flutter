import 'package:flutter/material.dart';
import 'package:spare_management/app_configs/app_constants.dart';
import 'package:spare_management/services/data_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize database - will create if doesn't exist
      await DataService().initialize();

      // Wait for minimum splash duration
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.pushReplacementNamed(context, "home");
      }
    } catch (e) {
      debugPrint("Error initializing app: $e");
      if (mounted) {
        Navigator.pushReplacementNamed(context, "home");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            /// Centered logo
            Center(child: Image.asset(AppConstants.appLogo)),

            /// App version at the bottom
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Text(
                "App Version: ${AppConstants.appVersion}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
