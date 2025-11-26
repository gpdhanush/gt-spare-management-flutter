import 'package:flutter/material.dart';
import 'package:spare_management/app_configs/app_constants.dart';
import 'package:spare_management/app_configs/app_routes.dart';
import 'package:spare_management/app_themes/app_colors.dart';
import 'package:spare_management/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Navigator.pushReplacementNamed(context, AppRoute.home);

      // final account = await AuthService.instance.signIn();
      // if (account != null && mounted) {
      //   // Navigate to home page after successful login
      //   Navigator.pushReplacementNamed(context, AppRoute.home);
      // }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Sign in failed';
        if (e.toString().contains('PlatformException') &&
            e.toString().contains('10')) {
          errorMessage =
              'Configuration Error (10):\n'
              '• Check OAuth client ID in Google Cloud Console\n'
              '• Add SHA-1 fingerprint to Firebase/Google Cloud Console\n'
              '• Verify package name: com.gt.spare_management';
        } else {
          errorMessage = 'Sign in failed: ${e.toString()}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(AppConstants.appLogo, height: 200, width: 200),
                const Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in with Google to continue',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.text.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                // Google Sign-In Button
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Image.asset(
                          'assets/img/google_logo.png',
                          height: 24,
                          width: 24,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.login, size: 24);
                          },
                        ),
                  label: Text(
                    _isLoading ? 'Signing in...' : 'Sign in with Google',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: AppColors.grayDark, width: 1.5),
                    ),
                    elevation: 2,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'By signing in, you agree to sync your data with Google Drive',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.text.withOpacity(0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
