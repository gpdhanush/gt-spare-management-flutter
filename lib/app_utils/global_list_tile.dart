import 'package:flutter/material.dart';
import 'package:spare_management/app_themes/app_colors.dart';

class GlobalListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback onTap;
  final IconData leadingIcon;
  const GlobalListTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
    required this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      borderOnForeground: true,
      color: Colors.white,
      margin: EdgeInsets.zero,
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
        side: BorderSide(color: AppColors.primary),
      ),
      child: ListTile(
        onTap: () {
          onTap();
        },
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          radius: 18,
          child: Icon(leadingIcon, color: AppColors.white),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 10),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            fontFamily: 'tamilFont',
            color: AppColors.primary,
          ),
          softWrap: true,
          overflow: TextOverflow.clip,
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.normal,
            fontSize: 14,
            color: AppColors.primary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: trailing,
      ),
    );
  }
}
