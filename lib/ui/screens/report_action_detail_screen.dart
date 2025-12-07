import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:site_report_automation_app/domain/extension/string_extension.dart';
import 'package:site_report_automation_app/domain/models/report_model.dart';
import 'package:site_report_automation_app/navigation/screen_routes.dart';
import 'package:site_report_automation_app/ui/screens/preview_report_screen.dart';
import 'package:site_report_automation_app/ui/theme/theme_colors.dart';
import 'package:site_report_automation_app/ui/viewmodels/report_actions_viewmodel.dart';
import 'package:site_report_automation_app/ui/widgets/themed_app_bar.dart';
import 'package:site_report_automation_app/ui/widgets/themed_elevated_button.dart';

class ReportActionDetailScreen extends StatefulWidget {
  const ReportActionDetailScreen({super.key, required this.reportModel});

  final ReportModel reportModel;

  @override
  State<ReportActionDetailScreen> createState() => _ReportActionDetailScreenState();
}

class _ReportActionDetailScreenState extends State<ReportActionDetailScreen> {

  late ReportActionsViewmodel _previewReportViewmodel;

  @override
  void initState() {
    super.initState();
    _previewReportViewmodel = context.read<ReportActionsViewmodel>();
  }


  @override
  Widget build(BuildContext context) {
    final reportModel = widget.reportModel;

    final jobName = reportModel.jobName ?? '';
    final issue = reportModel.issue ?? '';
    final clientName = reportModel.clientName ?? '';
    final address = reportModel.address ?? '';
    final date = reportModel.date ?? '';
    final noteList = reportModel.noteList;

    final recommendedServices = reportModel.recommendedServices ?? '';
    final additionalNotes = reportModel.additionalNotes ?? '';

    final recommendedServicesBulletList = recommendedServices.toBulletStringList();
    final additionalNotesBulletList = additionalNotes.toBulletStringList();


    return Scaffold(
      appBar: ThemedAppBar(
        title: 'Report Detail',
        leadingWidget: Tooltip(
          message: 'Back',
          child: IconButton(
              onPressed: (() => context.pop()),
              icon: Icon(Icons.arrow_back, color: ThemeColors.white)
          ),
        ),
      ),
      body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                Center(
                  child: const Text(
                    'Preview Report',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                // Job Details
                JobDetailsUI(
                  jobName: jobName,
                  issue: issue,
                  clientName: clientName,
                  address: address,
                  date: date,
                ),
                // Report Heading
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.shade300,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: noteList.length,
                        itemBuilder: (context, index) {
                          var noteItem = noteList[index];

                          if (index >= noteList.length) {
                            return SizedBox();
                          }

                          final imageFileName = noteItem.imageFileName ?? '';
                          final recordingText = noteItem.recordingText ?? '';
                          final textDescription = noteItem.textDescription ?? '';
                          final problemDescription = noteItem.problemDescription ?? '';
                          final recommendedSolution = noteItem.recommendedSolution ?? '';

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(height: 10),
                              Text(
                                'Photo ${index + 1}:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10),
                              recordingText.isNotEmpty
                                  ? Text('Type: Voice')
                                  : Text('Type: Text'),
                              recordingText.isNotEmpty
                                  ? Text('Description: $recordingText')
                                  : Text('Description: $textDescription'),
                              Text('File: $imageFileName'),
                              SizedBox(height: 10),
                              Text('** Problem Description **'),
                              Text(problemDescription),
                              SizedBox(height: 10),
                              Text('** Recommended Solution **'),
                              Text(recommendedSolution),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
                // Recommended Services
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.shade300,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Recommended Services',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          recommendedServicesBulletList
                              .isNotEmpty
                              ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:
                            recommendedServicesBulletList
                                .map((item) => Text('• $item'))
                                .toList(),
                          )
                              : Text('No Services Available'),
                        ],
                      ),
                    ),
                  ),
                ),
                // Additional Notes
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.shade300,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Additional Notes',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          additionalNotesBulletList
                              .isNotEmpty
                              ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:
                            additionalNotesBulletList
                                .map((item) => Text('• $item'))
                                .toList(),
                          )
                              : Text('No Additional Notes Available'),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    width: double.maxFinite,
                    child: ThemedElevatedButton(
                      onPressed: (() async {
                        final pdfFilePath = reportModel.pdfFilePath ?? '';

                        if (pdfFilePath.isEmpty || !pdfFilePath.contains('/')) return;

                        final pdfFileName = pdfFilePath.split('/').last;
                        if (context.mounted) {
                          context.push(
                            '${ScreenRoutes.previewPdfScreenRoute}/$pdfFileName/$jobName',
                            extra: reportModel.pdfFilePath,
                          );
                        }
                      }),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Save & Share Pdf',
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.arrow_forward_ios, color: Colors.white),
                        ],
                      )
                    ),
                  ),
                ),
              ],
            ),
          )
      ),
    );
  }
}

