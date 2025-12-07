import 'package:flutter/material.dart';
import 'package:site_report_automation_app/ui/theme/theme_colors.dart';

class ThemedOutlinedButton extends StatelessWidget {
  const ThemedOutlinedButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.textColor = ThemeColors.themeColor
  });

  final VoidCallback? onPressed;
  final String text;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Text(text, style: TextStyle(color: textColor))
    );
  }
}
