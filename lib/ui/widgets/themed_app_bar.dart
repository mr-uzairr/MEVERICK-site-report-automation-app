import 'package:flutter/material.dart';
import 'package:site_report_automation_app/ui/theme/theme_colors.dart';

class ThemedAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ThemedAppBar({
    super.key,
    required this.title,
    this.titleColor = ThemeColors.white,
    this.backgroundColor = ThemeColors.themeColor,
    this.actions,
    this.leadingWidget
  });

  final String title;
  final Color titleColor;
  final Color backgroundColor;
  final List<Widget>? actions;
  final Widget? leadingWidget;


  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: TextStyle(color: titleColor)),
      backgroundColor: backgroundColor,
      actions: actions,
      leading: leadingWidget,
      automaticallyImplyLeading: false,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
