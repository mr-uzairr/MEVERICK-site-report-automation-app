import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:site_report_automation_app/domain/extension/string_extension.dart';
import 'package:site_report_automation_app/domain/models/note_model.dart';
import 'package:site_report_automation_app/domain/models/report_model.dart';
import 'package:site_report_automation_app/navigation/screen_routes.dart';
import 'package:site_report_automation_app/ui/theme/theme_colors.dart';
import 'package:site_report_automation_app/ui/viewmodels/report_actions_viewmodel.dart';
import 'package:site_report_automation_app/ui/widgets/themed_app_bar.dart';

class EditPdfScreen extends StatefulWidget {
  const EditPdfScreen({super.key, required this.reportModel});

  final ReportModel reportModel;

  @override
  State<EditPdfScreen> createState() => _EditPdfScreenState();
}

class _EditPdfScreenState extends State<EditPdfScreen> {
  late ReportModel _reportModel;
  bool isPdfSaving = false;

  // Note Related
  List<TextEditingController> issueControllers = [];
  List<TextEditingController> problemControllers = [];
  List<TextEditingController> solutionControllers = [];
  List<TextEditingController> estimatedCostControllers = [];

  List<TextEditingController> recommendedServicesControllers = [];
  List<TextEditingController> additionalNotesControllers = [];

  @override
  void initState() {
    super.initState();
    _reportModel = widget.reportModel;
    if (kDebugMode) {
      print('NoteList Length: ${_reportModel.noteList.length}');
    }
    // Notes Related Controllers
    _setUpNoteRelatedControllers();
    // Recommended Services and Additional Notes Related Controllers
    _setUpServicesAndNotesRelatedControllers();
  }

  void _setUpNoteRelatedControllers() {
    if (_reportModel.noteList.isNotEmpty) {
      for (final noteModel in _reportModel.noteList) {
        // Issue
        issueControllers.add(
          TextEditingController(text: noteModel.issue ?? ''),
        );
        // Problem
        problemControllers.add(
          TextEditingController(text: noteModel.problemDescription ?? ''),
        );
        // Solution
        solutionControllers.add(
          TextEditingController(text: noteModel.recommendedSolution ?? ''),
        );
        // Estimated Cost
        estimatedCostControllers.add(
          TextEditingController(text: noteModel.estimatedCost ?? ''),
        );
      }
      if (kDebugMode) {
        print('Issue Controllers Length: ${issueControllers.length}');
        print('Problem Controllers Length: ${problemControllers.length}');
        print('Solution Controllers Length: ${solutionControllers.length}');
        print(
          'Estimated Cost Controllers Length: ${estimatedCostControllers.length}',
        );
      }
      // Issue
      // issueControllers =
      //     _reportModel.noteList
      //         .map(
      //           (noteModel) =>
      //               TextEditingController(text: noteModel.issue ?? ''),
      //         )
      //         .toList();
      // // Problem
      // problemControllers =
      //     _reportModel.noteList
      //         .map(
      //           (noteModel) => TextEditingController(
      //             text: noteModel.problemDescription ?? '',
      //           ),
      //         )
      //         .toList();
      // // Solution
      // solutionControllers =
      //     _reportModel.noteList
      //         .map(
      //           (noteModel) => TextEditingController(
      //             text: noteModel.recommendedSolution ?? '',
      //           ),
      //         )
      //         .toList();
      // // Estimated Cost
      // estimatedCostControllers =
      //     _reportModel.noteList
      //         .map(
      //           (noteModel) =>
      //               TextEditingController(text: noteModel.estimatedCost ?? ''),
      //         )
      //         .toList();
    }
  }

  void _setUpServicesAndNotesRelatedControllers() {
    // Recommended Services
    final bulletRecommendedServicesList =
        (_reportModel.recommendedServices ?? '').toBulletStringList();
    // Additional Notes
    final bulletAdditionalNotesList =
        (_reportModel.additionalNotes ?? '').toBulletStringList();

    // Recommended Services
    if (bulletRecommendedServicesList.isNotEmpty) {
      recommendedServicesControllers =
          bulletRecommendedServicesList
              .map((text) => TextEditingController(text: text))
              .toList();
    }
    // Additional Notes
    additionalNotesControllers =
        bulletAdditionalNotesList
            .map((text) => TextEditingController(text: text))
            .toList();
  }

  void _updateReportModel() {
    List<NoteModel> updatedNoteList = [];
    String recommendedServices = '';
    String additionalNotes = '';

    // Notes List
    if (_reportModel.noteList.isNotEmpty) {
      for (int index = 0; index < _reportModel.noteList.length; index++) {
        final updatedNote = _reportModel.noteList[index].copyWith(
          issue: issueControllers[index].text,
          problemDescription: problemControllers[index].text,
          recommendedSolution: solutionControllers[index].text,
          estimatedCost: estimatedCostControllers[index].text,
        );
        updatedNoteList.add(updatedNote);
      }
    }

    // Recommended Services
    if (recommendedServicesControllers.isNotEmpty) {
      recommendedServices = recommendedServicesControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .join('* ');
    }

    // Additional Notes
    if (additionalNotesControllers.isNotEmpty) {
      additionalNotes = additionalNotesControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .join('* ');
    }

    // Updating ReportModel
    setState(() {
      _reportModel = _reportModel.copyWith(
        noteList: updatedNoteList,
        recommendedServices: recommendedServices,
        additionalNotes: additionalNotes,
      );
    });

    if (kDebugMode) {
      print('RecommendedServices: ${_reportModel.recommendedServices}');
      print('Additional Notes: ${_reportModel.additionalNotes}');
      print(
        'First Note Problem: ${_reportModel.noteList[0].problemDescription}',
      );
    }
  }

  @override
  void dispose() {
    _clearControllers();
    super.dispose();
  }

  void _clearControllers() {
    issueControllers = [];
    problemControllers = [];
    solutionControllers = [];
    estimatedCostControllers = [];
    recommendedServicesControllers = [];
    additionalNotesControllers = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ThemedAppBar(
        title: 'Edit Pdf',
        leadingWidget: Tooltip(
          message: 'Back',
          child: IconButton(
            onPressed: (() => context.pop()),
            icon: Icon(Icons.arrow_back, color: ThemeColors.white),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed:
            (isPdfSaving
                ? null
                : () async {
                  _updateReportModel();
                  // Pdf Starts Saving, Changing State
                  setState(() => isPdfSaving = true);

                  final reportActionsViewModel =
                      context.read<ReportActionsViewmodel>();

                  var safeJobNameForFileName =
                      (_reportModel.jobName ?? '').toSafeJobNameForFileName();
                  var pdfFileName = '${safeJobNameForFileName}site_report.pdf';
                  try {
                    // Generating Pdf
                    final Uint8List pdfBytes = await reportActionsViewModel
                        .generatePdf(reportModel: _reportModel);

                    // Saving PDF File Path to Application's Storage
                    final directory = await getApplicationDocumentsDirectory();
                    var savedPdfFile = File('${directory.path}/$pdfFileName');

                    if (await savedPdfFile.exists()) {
                      pdfFileName =
                          '${safeJobNameForFileName}_site_report${DateTime.now().millisecondsSinceEpoch}.pdf';
                      savedPdfFile = File('${directory.path}/$pdfFileName');
                    }

                    if (kDebugMode) {
                      print('Saved Pdf File Path: ${savedPdfFile.path}');
                    }

                    await savedPdfFile.writeAsBytes(pdfBytes);

                    // Upload to S3
                    try {
                      await reportActionsViewModel.uploadPdfToS3(pdfBytes, pdfFileName);
                      // Upload metadata JSON alongside PDF so we can reconstruct report UI
                      try {
                        await reportActionsViewModel.uploadReportMetadataToS3(reportModel: _reportModel, pdfFileName: pdfFileName);
                      } catch (e) {
                        if (kDebugMode) print('Failed to upload metadata to S3: $e');
                      }
                    } catch (e) {
                      if (kDebugMode) {
                        print('Failed to upload to S3: $e');
                      }
                      // Don't fail the save if S3 upload fails
                    }

                    // Saving PDf File Path to Report Model
                    setState(() {
                      _reportModel = _reportModel.copyWith(
                        pdfFilePath: savedPdfFile.path,
                      );
                    });

                    // Saving Report to SharedPreference
                    reportActionsViewModel.storeReportToSharedPreferences(
                      reportModel: _reportModel,
                    );

                    // Pdf Saved, Changing State
                    setState(() => isPdfSaving = false);

                    // Navigating to Preview Pdf Screen
                    if (context.mounted) {
                      context.push(
                        '${ScreenRoutes.previewPdfScreenRoute}/$pdfFileName/${_reportModel.jobName ?? ''}',
                        extra: savedPdfFile.path,
                      );
                    }
                  } catch (e) {
                    setState(() => isPdfSaving = false);
                    if (kDebugMode) {
                      print(e.toString());
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  }
                }),
        isExtended: !isPdfSaving,
        label: const Text(
          'Save Changes',
          style: TextStyle(color: ThemeColors.white),
        ),
        icon:
            isPdfSaving
                ? CircularProgressIndicator(color: ThemeColors.white)
                : Icon(Icons.navigate_next_sharp, color: ThemeColors.white),
        backgroundColor: ThemeColors.themeColor,
        tooltip: 'Save and Preview Pdf',
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 100.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: ThemeColors.white,
              ),
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Site Report: ${_reportModel.jobName}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Divider(),
                    SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _reportModel.noteList.length,
                      itemBuilder: ((context, index) {
                        final noteModel = _reportModel.noteList[index];

                        return buildNotesListItem(noteModel, index);
                      }),
                    ),
                    // Recommended Services
                    Text(
                      'Recommended Services:',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: recommendedServicesControllers.length,
                      itemBuilder: ((context, index) {
                        return buildRecommendedServicesListItem(index);
                      }),
                    ),
                    SizedBox(height: 10),
                    Divider(),
                    SizedBox(height: 10),
                    // Additional Notes
                    Text(
                      'Additional Notes:',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: additionalNotesControllers.length,
                      itemBuilder: ((context, index) {
                        return buildAdditionalNotesListItem(index);
                      }),
                    ),
                    SizedBox(height: 10),
                    Divider(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNotesListItem(NoteModel noteModel, int index) {
    final imageFile = File(noteModel.imageFilePath ?? '');

    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 10.0, 10.0, 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Short Issue
          issueControllers.isNotEmpty
              ? TextField(
                controller: issueControllers[index],
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(right: 5),
                    child: Text(
                      'Issue ${index + 1}: ',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                cursorColor: ThemeColors.themeColor,
                keyboardType: TextInputType.multiline,
                maxLines: null,
              )
              : SizedBox(),
          // Problem Image
          imageFile.existsSync()
              ? SizedBox(
                width: 200,
                height: 150,
                child: Image.file(imageFile, fit: BoxFit.fill),
              )
              : Text('Failed to Load Image', style: TextStyle(fontSize: 12)),
          SizedBox(height: 10),
          // Problem
          Text(
            'Problem:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          problemControllers.isNotEmpty
              ? TextField(
                controller: problemControllers[index],
                decoration: InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
                style: TextStyle(fontSize: 12),
                cursorColor: ThemeColors.themeColor,
                keyboardType: TextInputType.multiline,
                maxLines: null,
              )
              : SizedBox(),
          SizedBox(height: 10),
          // Solution
          Text(
            'Solution:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          solutionControllers.isNotEmpty
              ? TextField(
                controller: solutionControllers[index],
                decoration: InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
                style: TextStyle(fontSize: 12),
                cursorColor: ThemeColors.themeColor,
                keyboardType: TextInputType.multiline,
                maxLines: null,
              )
              : SizedBox(),
          SizedBox(height: 10),
          // Estimated Cost
          estimatedCostControllers.isNotEmpty
              ? TextField(
                controller: estimatedCostControllers[index],
                decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Text(
                      'Estimated Cost:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
                style: TextStyle(fontSize: 12),
                cursorColor: ThemeColors.themeColor,
                keyboardType: TextInputType.multiline,
                maxLines: null,
              )
              : SizedBox(),

          // Divider
          SizedBox(height: 10),
          Divider(),
        ],
      ),
    );
  }

  Widget buildRecommendedServicesListItem(int index) {
    return TextField(
      controller: recommendedServicesControllers[index],
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.only(right: 0),
          child: Text(
            '•',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        filled: false,
        contentPadding: EdgeInsets.zero,
      ),
      style: TextStyle(fontSize: 12),
      cursorColor: ThemeColors.themeColor,
      keyboardType: TextInputType.multiline,
      maxLines: null,
    );
  }

  Widget buildAdditionalNotesListItem(int index) {
    return TextField(
      controller: additionalNotesControllers[index],
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.only(right: 5),
          child: Text(
            '${index + 1}) ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        filled: false,
        contentPadding: EdgeInsets.zero,
      ),
      style: TextStyle(fontSize: 12),
      cursorColor: ThemeColors.themeColor,
      keyboardType: TextInputType.multiline,
      maxLines: null,
    );
  }
}
