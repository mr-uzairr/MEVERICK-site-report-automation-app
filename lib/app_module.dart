import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:site_report_automation_app/data/service/openai_api_service.dart';
import 'package:site_report_automation_app/ui/viewmodels/new_report_viewmodel.dart';
import 'package:site_report_automation_app/ui/viewmodels/report_actions_viewmodel.dart';

class AppModule {
  static List<InheritedProvider> providers = [
    // Open AI Api Service
    Provider<OpenAiApiService>(create: (_) => OpenAiApiService()),
    Provider<SharedPreferencesAsync>(create: (_) => SharedPreferencesAsync()),
    // Report Actions ViewModel
    ChangeNotifierProvider<ReportActionsViewmodel>(create: (context) => ReportActionsViewmodel(asyncPrefs: context.read<SharedPreferencesAsync>()))
  ];
}