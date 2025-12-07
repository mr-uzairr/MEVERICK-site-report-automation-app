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
import 'package:site_report_automation_app/ui/widgets/themed_elevated_button.dart';

class PreviewReportScreen extends StatefulWidget {
  const PreviewReportScreen({super.key, required this.reportModel});

  final ReportModel reportModel;

  @override
  State<PreviewReportScreen> createState() => _PreviewReportScreenState();
}

class _PreviewReportScreenState extends State<PreviewReportScreen> {
  late List<NoteModel> _editableNoteList;
  // late PreviewReportViewmodel _previewReportViewmodel;

  late ReportModel _reportModel;

  List<TextEditingController> problemTextEditingControllers = [];
  List<TextEditingController> solutionTextEditingControllers = [];

  bool isEditsSaving = false;
  bool isEditsSaved = false;
  bool isPdfSaving = false;

  @override
  void initState() {
    super.initState();
    _reportModel = widget.reportModel;
    // _editableNoteList = List.from(widget.generatedNoteList);
    _editableNoteList = _reportModel.noteList;
    if (kDebugMode) {
      print('Note List Length: ${_editableNoteList.length}');
      print('Note List: $_editableNoteList');
    }

    // Setting Default Problem Value to Controllers
    problemTextEditingControllers =
        _editableNoteList
            .map(
              (noteModel) => TextEditingController(
                text: noteModel.problemDescription ?? '',
              ),
            )
            .toList();

    // Setting Default Solution Value to Controllers
    solutionTextEditingControllers =
        _editableNoteList
            .map(
              (noteModel) => TextEditingController(
                text: noteModel.recommendedSolution ?? '',
              ),
            )
            .toList();

    // Assigning ViewModel adn Listening Values from ViewModel if Available
    // _previewReportViewmodel = context.read<PreviewReportViewmodel>();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onNotesEdit() {
    setState(() {
      isEditsSaving = true;
      for (int i = 0; i < _editableNoteList.length; i++) {
        _editableNoteList[i] = _editableNoteList[i].copyWith(
          problemDescription: problemTextEditingControllers[i].text,
          recommendedSolution: solutionTextEditingControllers[i].text,
        );
      }
      _reportModel = _reportModel.copyWith(noteList: _editableNoteList);
      setState(() {
        isEditsSaving = false;
        isEditsSaved = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final jobName = _reportModel.jobName ?? '';
    final issue = _reportModel.issue ?? '';
    final clientName = _reportModel.clientName ?? '';
    final address = _reportModel.address ?? '';
    final date = _reportModel.date ?? '';
    final recommendedServices = _reportModel.recommendedServices ?? '';
    final additionalNotes = _reportModel.additionalNotes ?? '';
    final recommendedServicesBulletList =
        recommendedServices.toBulletStringList();
    final additionalNotesBulletList = additionalNotes.toBulletStringList();


    return Scaffold(
      appBar: ThemedAppBar(
        title: 'Preview Report',
        leadingWidget: Tooltip(
          message: 'Back',
          child: IconButton(
            onPressed: (() => context.pop()),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
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
              // Editable Report Heading
              AnimatedContainer(
                duration: Duration(milliseconds: 200),
                child:
                    !isEditsSaved
                        ? Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            width: double.maxFinite,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: ThemeColors.cardColor,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Report Heading',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      color: Colors.white,
                                    ),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: _editableNoteList.length,
                                      itemBuilder: (context, index) {
                                        var noteItem = _editableNoteList[index];

                                        if (index >= _editableNoteList.length) {
                                          return SizedBox();
                                        }

                                        final imageFileName =
                                            noteItem.imageFileName ?? '';

                                        return Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              SizedBox(height: 10),
                                              Text(
                                                'Photo ${index + 1}: $imageFileName',
                                              ),
                                              SizedBox(height: 10),
                                              Text('** Problem Description **'),
                                              EditableText(
                                                controller:
                                                    problemTextEditingControllers[index],
                                                focusNode: FocusNode(),
                                                style: TextStyle(
                                                  color: Colors.black,
                                                ),
                                                cursorColor: Colors.blue,
                                                backgroundCursorColor:
                                                    Colors.blue,
                                                keyboardType:
                                                    TextInputType.multiline,
                                                maxLines: null,
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                '** Recommended Solution **',
                                              ),
                                              EditableText(
                                                controller:
                                                    solutionTextEditingControllers[index],
                                                focusNode: FocusNode(),
                                                style: TextStyle(
                                                  color: Colors.black,
                                                ),
                                                cursorColor: Colors.blue,
                                                backgroundCursorColor:
                                                    Colors.blue,
                                                keyboardType:
                                                    TextInputType.multiline,
                                                maxLines: null,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        : SizedBox(),
              ),
              // Save Edits Button
              !isEditsSaved
                  ? Container(
                    width: double.maxFinite,
                    margin: const EdgeInsets.all(10.0),
                    child: ThemedElevatedButton(
                      onPressed: (isEditsSaving ? null : () => onNotesEdit()),
                      child:
                          !isEditsSaving
                              ? Text(
                                'Save Edits',
                                style: TextStyle(color: Colors.white),
                              )
                              : Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: CircularProgressIndicator(),
                              ),
                    ),
                  )
                  : SizedBox(),
              // Report Heading
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: ThemeColors.cardColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _editableNoteList.length,
                      itemBuilder: (context, index) {
                        var noteItem = _editableNoteList[index];

                        if (index >= _editableNoteList.length) {
                          return SizedBox();
                        }

                        final imageFileName = noteItem.imageFileName ?? '';
                        final recordingText = noteItem.recordingText ?? '';
                        final textDescription = noteItem.textDescription ?? '';
                        final problemDescription =
                            noteItem.problemDescription ?? '';
                        final recommendedSolution =
                            noteItem.recommendedSolution ?? '';

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
                    color: ThemeColors.cardColor,
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
                    color: ThemeColors.cardColor,
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
                        additionalNotesBulletList.isNotEmpty
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
                    onPressed:
                        (isPdfSaving
                            ? null
                            : () async {
                              context.push(ScreenRoutes.editPdfScreenRoute, extra: _reportModel);
                              // Pdf Starts Saving, Changing State
                              // setState(() => isPdfSaving = true);
                              // var jobNameForFileName = 'site_report';
                              // if (jobName.contains(' ')) {
                              //   jobNameForFileName =
                              //       (jobName ?? '')
                              //           .replaceAll(' ', '_')
                              //           .toLowerCase();
                              // } else {
                              //   jobNameForFileName = jobName.toLowerCase();
                              // }
                              // var pdfFileName =
                              //     '${jobNameForFileName}_site_report.pdf';
                              // try {
                              //   final Uint8List pdfBytes =
                              //       await _previewReportViewmodel.generatePdf(
                              //         reportModel: _reportModel,
                              //       );
                              //   // Saving PDF File Path to Application's Storage
                              //   final directory =
                              //       await getApplicationDocumentsDirectory();
                              //   var savedPdfFile = File(
                              //     '${directory.path}/$pdfFileName',
                              //   );
                              //
                              //   if (await savedPdfFile.exists()) {
                              //     pdfFileName =
                              //         '${jobNameForFileName}_site_report${DateTime.now().millisecondsSinceEpoch}.pdf';
                              //     savedPdfFile = File(
                              //       '${directory.path}/$pdfFileName',
                              //     );
                              //   }
                              //
                              //   if (kDebugMode) {
                              //     print('File Path: ${savedPdfFile.path}');
                              //   }
                              //   await savedPdfFile.writeAsBytes(pdfBytes);
                              //
                              //   // Saving PDf File Path to Report Model
                              //   setState(() {
                              //     _reportModel = _reportModel.copyWith(
                              //       pdfFilePath: savedPdfFile.path,
                              //     );
                              //   });
                              //
                              //   // Saving Report to SharedPreference
                              //   await _previewReportViewmodel
                              //       .storeReportToSharedPreferences(
                              //         reportModel: _reportModel,
                              //       );
                              //
                              //   // Pdf Saved, Changing State
                              //   setState(() => isPdfSaving = false);
                              //   // Navigating to Preview Pdf Screen
                              //   if (context.mounted) {
                              //     context.go(
                              //       '${ScreenRoutes.previewPdfScreenRoute}/$pdfFileName/$jobName',
                              //       extra: savedPdfFile.path,
                              //     );
                              //   }
                              // } catch (e) {
                              //   setState(() => isPdfSaving = false);
                              //   if (kDebugMode) {
                              //     print(e.toString());
                              //   }
                              //   if (context.mounted) {
                              //     ScaffoldMessenger.of(context).showSnackBar(
                              //       SnackBar(content: Text(e.toString())),
                              //     );
                              //   }
                              // }
                            }),
                    child:
                        !isPdfSaving
                            ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Next',
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(width: 10),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                ),
                              ],
                            )
                            : CircularProgressIndicator(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class JobDetailsUI extends StatelessWidget {
  const JobDetailsUI({
    super.key,
    required this.jobName,
    required this.issue,
    required this.clientName,
    required this.address,
    required this.date,
  });

  final String jobName, issue, clientName, address, date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        width: double.maxFinite,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: ThemeColors.cardColor,
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Job Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text('Job Name: $jobName'),
              Text('Issue: $issue'),
              Text('Client: $clientName'),
              Text('Address: $address'),
              Text('Date: $date'),
            ],
          ),
        ),
      ),
    );
  }
}
