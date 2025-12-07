import 'dart:typed_data';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:site_report_automation_app/data/service/openai_api_service.dart';
import 'package:site_report_automation_app/domain/models/note_model.dart';
import 'package:site_report_automation_app/domain/models/report_model.dart';
import 'package:site_report_automation_app/navigation/screen_routes.dart';
import 'package:site_report_automation_app/ui/screens/edit_pdf_screen.dart';
import 'package:site_report_automation_app/ui/screens/new_report_screen.dart';
import 'package:site_report_automation_app/ui/screens/preview_pdf_screen.dart';
import 'package:site_report_automation_app/ui/screens/report_action_detail_screen.dart';
import 'package:site_report_automation_app/ui/screens/report_actions_screen.dart';
import 'package:site_report_automation_app/ui/screens/preview_report_screen.dart';
import 'package:site_report_automation_app/ui/viewmodels/new_report_viewmodel.dart';

class AppRouter {
  static GoRouter router = GoRouter(
    initialLocation: ScreenRoutes.reportActionsScreenRoute,
    routes: [
      // Report Actions Screen
      GoRoute(
        path: ScreenRoutes.reportActionsScreenRoute,
        builder: ((_, _) => const ReportActionsScreen())
      ),
      // Report Action Detail Screen
      GoRoute(
        path: ScreenRoutes.reportActionDetailScreenRoute,
        builder: ((_, state) {
          final ReportModel reportModel = state.extra as ReportModel;

          return ReportActionDetailScreen(reportModel: reportModel);
        }),
      ),
      // New Report Screen
      GoRoute(
        path: ScreenRoutes.newReportScreenRoute,
        builder: ((_, _) {
          return ChangeNotifierProvider(
            create: (context) => NewReportViewmodel(apiService: context.read<OpenAiApiService>()),
            child: const NewReportScreen(),
          );
        })
      ),
      // Edit pdf Screen
      GoRoute(
          path: ScreenRoutes.editPdfScreenRoute,
          builder: ((_, state) {
            final reportModel = state.extra as ReportModel;

            return EditPdfScreen(
              reportModel: reportModel,
            );
          })
      ),
      // Preview Report Screen
      GoRoute(
        path: ScreenRoutes.previewReportScreenRoute,
        builder: ((_, state) {
          final reportModel = state.extra as ReportModel;

          return PreviewReportScreen(
            reportModel: reportModel,
          );
        })
      ),
      // Preview Pdf Screen
      GoRoute(
        path: '${ScreenRoutes.previewPdfScreenRoute}/:fileName/:jobName',
        builder: ((_, state) {
          final String fileName = state.pathParameters['fileName'] ?? '';
          final String jobName = state.pathParameters['jobName'] ?? '';
          final String pdfFilePath = state.extra as String;

          return PreviewPdfScreen(pdfFilePath: pdfFilePath, pdfFileName: fileName, jobName: jobName);
        }),
      ),
    ]
  );
}