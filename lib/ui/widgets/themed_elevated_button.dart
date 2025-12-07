import 'package:flutter/material.dart';
import 'package:site_report_automation_app/ui/theme/theme_colors.dart';

class ThemedElevatedButton extends StatelessWidget {
  const ThemedElevatedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor = ThemeColors.themeColor
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Color backgroundColor;


  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: backgroundColor),
      child: child
    );
  }
}
