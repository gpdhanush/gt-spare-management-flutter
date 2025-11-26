import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spare_management/app_themes/app_colors.dart';
import 'package:spare_management/app_themes/custom_theme.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> action;

  const AppBarWidget({super.key, required this.title, required this.action});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: AppTextStyles.bodyText.copyWith(color: Colors.white),
      ),
      backgroundColor: AppColors.primary,
      automaticallyImplyLeading: true,
      centerTitle: true,
      elevation: 0,
      actions: action,
      iconTheme: const IconThemeData(color: Colors.white),
      systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: AppColors.primary,
        systemStatusBarContrastEnforced: false,
      ),
    );
  }
}
