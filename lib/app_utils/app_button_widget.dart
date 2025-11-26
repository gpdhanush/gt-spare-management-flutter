import 'package:flutter/material.dart';
import 'package:spare_management/app_themes/app_colors.dart';
import 'package:spare_management/app_themes/custom_theme.dart';

class AppButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final double? width;

  const AppButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.maxFinite,
      child: MaterialButton(
        height: 55,
        elevation: 0,
        onPressed: onPressed,
        color: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: Text(
          title,
          style: AppTextStyles.button.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
