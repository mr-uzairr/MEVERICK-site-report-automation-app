import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:site_report_automation_app/domain/extension/string_extension.dart';
import 'package:site_report_automation_app/domain/models/note_model.dart';
import 'package:site_report_automation_app/domain/models/report_model.dart';

class ReportActionsViewmodel extends ChangeNotifier {
  ReportActionsViewmodel({required this.asyncPrefs});

  final SharedPreferencesAsync asyncPrefs;

  Future<Uint8List> generatePdf({required ReportModel reportModel}) async {
    final pdf = pw.Document();

    final noteListWidget = await _buildNoteListUIInPdf(reportModel.noteList);

    final recommendedServicesBulletList = (reportModel.recommendedServices ?? '').toBulletStringList();
    final additionalNotesBulletList = (reportModel.additionalNotes ?? '').toBulletStringList();

    pdf.addPage(
      pw.MultiPage(
        build:
            (context) => [
              // Title, Issue and Reference Photos
              pw.Text(
                'Site Report: ${reportModel.jobName}',
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.SizedBox(height: 10),
              // Note List
              ...noteListWidget,
              // End of Note List
              pw.SizedBox(height: 10),
              // Recommended Services
              pw.Text(
                'Recommended Services:',
                style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              ...recommendedServicesBulletList.map((text) {
                return pw.Bullet(
                  text: text.trim(),
                  style: pw.TextStyle(fontSize: 12),
                );
              }).toList(),
              pw.SizedBox(height: 20),
              // Additional Notes
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text(
                'Additional Notes:',
                style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              ...additionalNotesBulletList.asMap().entries.map((entry) {
                return pw.RichText(
                  text: pw.TextSpan(
                    children: [
                      pw.TextSpan(
                        text: '${entry.key + 1}) ',
                        style: pw.TextStyle(fontSize: 12)
                      ),
                      pw.TextSpan(
                        text: entry.value.trim(),
                        style: pw.TextStyle(fontSize: 12)
                      )
                    ]
                  )
                );
              }).toList(),
              pw.SizedBox(height: 20),
              pw.Divider(),
            ],
      ),
    );

    return await pdf.save();
  }

  Future<List<pw.Widget>> _buildNoteListUIInPdf(List<NoteModel> noteList) async {

    final List<pw.Widget> widgets = [];

    for (var index = 0; index < noteList.length; index++) {

      final noteModel = noteList[index];

      final issue = noteModel.issue ?? 'No Issue Provided';
      final problem = noteModel.problemDescription ?? 'No Problem Provided';
      final solution = noteModel.recommendedSolution ?? 'No Solution Available';
      final estimatedCost = noteModel.estimatedCost ?? 'No Estimated Cost';

      final imageBytes = await File(noteModel.imageFilePath ?? '').readAsBytes();
      final image = pw.MemoryImage(imageBytes);

      widgets.add(
          pw.Padding(
            padding: pw.EdgeInsets.fromLTRB(0.0, 10.0, 10.0, 10.0),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Short Issue
                pw.RichText(
                  text: pw.TextSpan(
                    children: [
                      pw.TextSpan(
                        text: 'Issue ${index + 1}: ',
                        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.TextSpan(
                        text: issue,
                        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 10),
                // Problem Image
                pw.SizedBox(
                  width: 200,
                  height: 150,
                  child: pw.Image(image, fit: pw.BoxFit.fill)
                ),
                pw.SizedBox(height: 20),
                // Problem
                pw.Text(
                  'Problem:',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(problem, style: pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 20),
                // Solution
                pw.Text(
                  'Solution:',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  solution,
                  style: pw.TextStyle(
                    fontSize: 12,
                  ),
                ),
                pw.SizedBox(height: 20),
                // Estimated Cost
                pw.RichText(
                  text: pw.TextSpan(
                    children: [
                      pw.TextSpan(
                        text: 'Estimated Cost: ',
                        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.TextSpan(
                        text: estimatedCost,
                        style: pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),

                // Divider
                pw.SizedBox(height: 10),
                pw.Divider(),
              ],
            ),
          )
      );
    }

    return widgets;
  }


  Future<void> storeReportToSharedPreferences({
    required ReportModel reportModel,
  }) async {
    // Get Existing Report Actions List
    final existingReportActions =
        await asyncPrefs.getStringList('saved_report_actions') ?? [];

    if (kDebugMode) {
      print(
        'Existing Report Actions List Length (before Adding Item): ${existingReportActions.length}',
      );
    }

    // Running Encoded Part in Another Thread to Prevent Screen Freezes
    final reportJsonString = await Isolate.run(
      () => jsonEncode(reportModel.toJson()),
    );

    // Inserting this ReportModel at the Top of List (Latest)
    existingReportActions.insert(0, reportJsonString);

    if (kDebugMode) {
      print(
        'Existing Report Actions List Length (After Adding Item): ${existingReportActions.length}',
      );
    }

    await asyncPrefs.setStringList(
      'saved_report_actions',
      existingReportActions,
    );
  }

  Future<List<ReportModel>> getSavedReportActions() async {
    final reportActionsJsonStringList =
        await asyncPrefs.getStringList('saved_report_actions') ?? [];

    if (kDebugMode) {
      print(
        'Report Actions List Length: ${reportActionsJsonStringList.length}',
      );
    }

    // Running Decoding Part in Another Thread to Prevent Screen Freezes
    return await Isolate.run(
      () =>
          reportActionsJsonStringList.map((json) {
            final jsonDecoded = jsonDecode(json);
            return ReportModel.fromJson(jsonDecoded);
          }).toList(),
    );
  }
}
