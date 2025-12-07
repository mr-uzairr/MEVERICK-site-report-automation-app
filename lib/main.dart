import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:site_report_automation_app/app_module.dart';
import 'package:site_report_automation_app/navigation/app_router.dart';
import 'package:site_report_automation_app/ui/theme/theme_colors.dart';

void main() {
  runApp(
    MultiProvider(
      providers: AppModule.providers,
      child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: ThemeColors.themeColor),
      ),
      routerConfig: AppRouter.router,
    );
  }
}
