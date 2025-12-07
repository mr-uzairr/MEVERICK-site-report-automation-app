import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:site_report_automation_app/data/service/openai_api_service.dart';
import 'package:site_report_automation_app/data/service/s3_service.dart';
import 'package:site_report_automation_app/ui/viewmodels/report_actions_viewmodel.dart';

class AppModule {
  static List<InheritedProvider> providers = [
    // Open AI Api Service
    Provider<OpenAiApiService>(create: (_) => OpenAiApiService()),
    // S3 Service
    Provider<S3Service>(create: (_) => S3Service()),
    Provider<SharedPreferencesAsync>(create: (_) => SharedPreferencesAsync()),
    // Report Actions ViewModel
    ChangeNotifierProvider<ReportActionsViewmodel>(create: (context) => ReportActionsViewmodel(asyncPrefs: context.read<SharedPreferencesAsync>(), s3Service: context.read<S3Service>()))
  ];
}