import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:site_report_automation_app/domain/extension/string_extension.dart';
import 'package:site_report_automation_app/domain/models/note_model.dart';
import 'package:site_report_automation_app/domain/models/report_model.dart';
import 'package:site_report_automation_app/navigation/screen_routes.dart';
import 'package:site_report_automation_app/ui/theme/theme_colors.dart';
import 'package:site_report_automation_app/ui/viewmodels/new_report_viewmodel.dart';
import 'package:site_report_automation_app/ui/widgets/themed_app_bar.dart';
import 'package:site_report_automation_app/ui/widgets/themed_elevated_button.dart';
import 'package:site_report_automation_app/ui/widgets/themed_outlined_button.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:http/http.dart' as http;

class NewReportScreen extends StatefulWidget {
  const NewReportScreen({super.key});

  @override
  State<NewReportScreen> createState() => _NewReportScreenState();
}

class _NewReportScreenState extends State<NewReportScreen> {
  final _jobNameTextEditingController = TextEditingController();
  final _issueTextEditingController = TextEditingController();
  final _clientNameTextEditingController = TextEditingController();
  final _addressTextEditingController = TextEditingController();
  final _phoneNumberTextEditingController = TextEditingController();
  TextEditingController _dateTextEditingController = TextEditingController();
  String jobName = '';
  String issue = '';
  String clientName = '';
  String address = '';
  String phoneNumber = '';
  String date = '';

  late NewReportViewmodel _newReportViewmodel;

  @override
  void initState() {
    super.initState();
    // Job Name
    _jobNameTextEditingController.addListener(() {
      setState(() => jobName = _jobNameTextEditingController.text);
    });
    // Issue
    _issueTextEditingController.addListener(() {
      setState(() => issue = _issueTextEditingController.text);
    });
    // Client Name
    _clientNameTextEditingController.addListener(() {
      setState(() => clientName = _clientNameTextEditingController.text);
    });
    // Address
    _addressTextEditingController.addListener(() {
      setState(() => address = _addressTextEditingController.text);
    });
    // Phone Number
    _phoneNumberTextEditingController.addListener(() {
      setState(() => phoneNumber = _phoneNumberTextEditingController.text);
    });
    // Setting CurrentDate
    final currentDate = DateTime.now();
    final formattedDate =
        '${currentDate.year}-${currentDate.month}-${currentDate.day}';
    _dateTextEditingController = TextEditingController(text: formattedDate);
    date = _dateTextEditingController.text;
    // Date
    _dateTextEditingController.addListener(() {
      setState(() => date = _dateTextEditingController.text);
      if (kDebugMode) {
        print('Date from Controller: ${_dateTextEditingController.text}');
        print('Date: $date');
      }
    });
    _newReportViewmodel = context.read<NewReportViewmodel>();
    _newReportViewmodel.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _jobNameTextEditingController.dispose();
    _issueTextEditingController.dispose();
    _clientNameTextEditingController.dispose();
    _addressTextEditingController.dispose();
    _phoneNumberTextEditingController.dispose();
    _dateTextEditingController.dispose();
    _newReportViewmodel.removeListener(() {});
    if (kDebugMode) {
      print('dispose(): NewReportScreen');
    }
    super.dispose();
  }

  bool isAbleToSubmitReport() =>
      jobName.isNotEmpty &&
      issue.isNotEmpty &&
      address.isNotEmpty &&
      date.isNotEmpty &&
      _newReportViewmodel.noteList.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final noteList = _newReportViewmodel.noteList;
    final isAddingNote = _newReportViewmodel.isAddingNote;
    final isGenerating = _newReportViewmodel.isGenerating;

    return Scaffold(
      appBar: ThemedAppBar(
        title: 'New Report',
        leadingWidget: Tooltip(
          message: 'Back',
          child: IconButton(
            onPressed: (() => context.pop()),
            icon: Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Text(
                  'New Report',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              // Job Name
              TextField(
                controller: _jobNameTextEditingController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Job Name',
                  labelStyle: TextStyle(color: Colors.blue),
                ),
              ),
              const SizedBox(height: 20),
              // Job Name
              TextField(
                controller: _issueTextEditingController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Issue',
                  labelStyle: TextStyle(color: Colors.blue),
                ),
              ),
              const SizedBox(height: 20),
              // Clint Name
              TextField(
                controller: _clientNameTextEditingController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Client Name',
                  labelStyle: TextStyle(color: Colors.blue),
                ),
              ),
              const SizedBox(height: 20),
              // Address
              TextField(
                controller: _addressTextEditingController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Address',
                  labelStyle: TextStyle(color: Colors.blue),
                ),
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              // Phone Number
              TextField(
                controller: _phoneNumberTextEditingController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Phone Number',
                  labelStyle: TextStyle(color: Colors.blue),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              // Date
              TextField(
                controller: _dateTextEditingController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Date',
                  labelStyle: TextStyle(color: Colors.blue),
                ),
              ),
              const SizedBox(height: 20),
              // Picking from Gallery Button
              SizedBox(
                width: double.maxFinite,
                child: ThemedOutlinedButton(
                  onPressed:
                      (isAddingNote
                          ? null
                          : () async =>
                              _newReportViewmodel.pickImageFromGallery()),
                  text: 'Add Photo from Gallery',
                ),
              ),
              const SizedBox(height: 20),
              // Taking from Camera Button
              SizedBox(
                width: double.maxFinite,
                child: ThemedOutlinedButton(
                  onPressed:
                      (isAddingNote
                          ? null
                          : () async =>
                              _newReportViewmodel.takeImageFromCamera()),
                  text: 'Take Photo from Camera',
                ),
              ),
              const SizedBox(height: 10),
              // Note List
              noteList.isNotEmpty
                  ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children:
                          noteList.asMap().entries.map((entry) {
                            int index = entry.key;
                            var noteItem = entry.value;

                            return buildNoteListItem(
                              noteItem: noteItem,
                              index: index,
                              isGenerating: isGenerating
                            );
                          }).toList(),
                    ),
                  )
                  : SizedBox(),
              // Adding Note
              isAddingNote
                  ? AddingNoteUI(
                    key:
                        _newReportViewmodel.selectedFile != null
                            ? ValueKey(_newReportViewmodel.selectedFile!.path)
                            : null,
                    selectedImageFile: _newReportViewmodel.selectedFile,
                    onNoteAdded: (noteModel) {
                      _newReportViewmodel.onNoteAdd(noteModel);
                    },
                  )
                  : SizedBox(),
              const SizedBox(height: 20),
              SizedBox(height: 20),
              SizedBox(
                width: double.maxFinite,
                child: ThemedElevatedButton(
                  onPressed:
                      (!isAbleToSubmitReport() || isGenerating
                          ? null
                          : () async {
                            try {
                              await _newReportViewmodel
                                  .generateEverythingFromAI(issue);
                              // Navigating to Preview Report Screen
                              if (context.mounted) {
                                final reportModel = ReportModel(
                                  jobName: jobName,
                                  issue: issue,
                                  clientName: clientName,
                                  address: address,
                                  phoneNumber: phoneNumber,
                                  date: date,
                                  noteList: _newReportViewmodel.noteList,
                                  recommendedServices:
                                      _newReportViewmodel.recommendedServices,
                                  additionalNotes:
                                      _newReportViewmodel.additionalNotes,
                                  pdfFilePath: null,
                                );


                                context.push(
                                  ScreenRoutes.previewReportScreenRoute,
                                  extra: reportModel,
                                );

                              }
                            } catch (e) {
                              if (kDebugMode) {
                                print(e.toString());
                              }
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            }
                          }),
                  child:
                      !isGenerating
                          ? Text(
                            'Submit Report',
                            style: TextStyle(color: Colors.white),
                          )
                          : Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: CircularProgressIndicator(),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget buildNoteListItem({
    required NoteModel noteItem,
    required int index,
    required bool isGenerating
  }) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          noteItem.imageFilePath != null
              ? Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                10.0,
              ),
              image: DecorationImage(
                image: FileImage(
                  File(
                    noteItem.imageFilePath ?? '',
                  ),
                ),
                fit: BoxFit.cover,
              ),
            ),
          )
              : SizedBox(),
          SizedBox(height: 10),
          noteItem.recordingText != null
              ? Text('Voice')
              : SizedBox(),
          noteItem.textDescription != null
              ? Text('text')
              : SizedBox(),
          SizedBox(height: 5),
          TextButton(
            onPressed:(isGenerating ? null
                : () async => _newReportViewmodel.onNoteRemove(index)),
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }


}

class AddingNoteUI extends StatefulWidget {
  const AddingNoteUI({
    super.key,
    required this.selectedImageFile,
    required this.onNoteAdded,
  });

  final File? selectedImageFile;
  final Function(NoteModel) onNoteAdded;

  @override
  State<AddingNoteUI> createState() => _AddingNoteUIState();
}

class _AddingNoteUIState extends State<AddingNoteUI> {
  final _textDescriptionTextEditingController = TextEditingController();
  String? _textDescription;

  final SpeechToText _speechToText = SpeechToText();
  String? _recordingText;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      print('AddingNote: initState()');
    }

    _textDescriptionTextEditingController.addListener(() {
      setState(
        () => _textDescription = _textDescriptionTextEditingController.text,
      );

      if (kDebugMode) {
        print('Text Description: $_textDescription');
      }
    });
  }

  Future<void> _recordNoteOrStop() async {
    var permissionsStatus = await [
      Permission.microphone,
      if (Platform.isIOS) Permission.speech,
    ].request();

    final microphoneStatus = permissionsStatus[Permission.microphone];
    final speechStatus = Platform.isIOS ? permissionsStatus[Permission.speech] : PermissionStatus.granted;

    if (microphoneStatus != PermissionStatus.granted || speechStatus != PermissionStatus.granted) return;
    if (
      microphoneStatus == PermissionStatus.permanentlyDenied
        || speechStatus == PermissionStatus.permanentlyDenied
    ) {
      await openAppSettings();
    }

    if (!_isListening) {
      bool isSpeechEnabled = await _speechToText.initialize(
        onError: (SpeechRecognitionError speechRecognitionError) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(speechRecognitionError.errorMsg)),
            );
          }
        },
      );
      if (isSpeechEnabled) {
        setState(() => _isListening = true);
        if (kDebugMode) {
          print('Listening: true');
        }
        _speechToText.listen(onResult: _onSpeechResult);
        setState(() {});
      }
    } else {
      if ((_recordingText ?? '').isNotEmpty) {
        _speechToText.stop();
        _isListening = false;
        setState(() {});
        if (kDebugMode) {
          print('Listening: false');
        }
        // Saving Note
        _addNote(); // Saving  Note
        //
      } else {
        return;
      }
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _recordingText = result.recognizedWords;
    });
    if (kDebugMode) {
      print('Recording Text: $_recordingText');
    }
  }

  Future<void> _addNote() async {
    try {
      final selectedFile = widget.selectedImageFile;
      if (selectedFile != null) {
        // Saving File to the Application's Document Directory
        final savedImage = await _saveImagePermanently(selectedFile);

        final savedImageFilePath = savedImage.path;
        final savedImageFileName = savedImageFilePath.getFileName();

        if (kDebugMode) {
          print('Selected Image Path: ${selectedFile.path}');
          print('Saved Image Path: $savedImageFilePath');
          print('Saved Image Name with Extension: $savedImageFileName');
        }

        final noteModel = NoteModel(
          imageFileName: savedImageFileName,
          imageFilePath: savedImageFilePath,
          recordingText: _recordingText,
          textDescription: _textDescription,
          issue: null,  // AI Generated
          problemDescription: null, // AI Generated
          recommendedSolution: null, // AI Generated
          estimatedCost: null // AI Generated
        );
        widget.onNoteAdded(noteModel);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }


  // Saving Image to the Application's Document Directory
  // Otherwise the Image path will remove because selected Image is a Cache Image
  Future<File> _saveImagePermanently(File selectedImageFile) async {

    final fileName = selectedImageFile.path.getFileName();
    final fileExtension = fileName.getFileExtension();

    final directory = await getApplicationDocumentsDirectory();
    final newFileName =
        '${DateTime.now().millisecondsSinceEpoch}$fileExtension';
    final newFilePath = '${directory.path}/$newFileName';

    // Saving File to the Application's Document Directory
    try {
      return await selectedImageFile.copy(newFilePath);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to Save Image Permanently: ${e.toString()}');
      }
      return selectedImageFile;
    }
  }

  @override
  void dispose() {
    _speechToText.cancel();
    _textDescriptionTextEditingController.removeListener(() {});
    _textDescriptionTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child:
          widget.selectedImageFile != null
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 20),
                  const Text('Add Note for Photo'),
                  const SizedBox(height: 5),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      image: DecorationImage(
                        image: FileImage(widget.selectedImageFile!),
                        fit: BoxFit.cover,
                      ),
                    ),
                    width: 130,
                    height: 130,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.maxFinite,
                    child: OutlinedButton(
                      onPressed: (() async => _recordNoteOrStop()),
                      style: OutlinedButton.styleFrom(
                        backgroundColor:
                            !_isListening ? Colors.transparent : Colors.blue,
                      ),
                      child:
                          !_isListening
                              ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.mic, color: Colors.blue),
                                  SizedBox(width: 10),
                                  Text(
                                    'Record Voice Note',
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ],
                              )
                              : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.stop, color: Colors.white),
                                  SizedBox(width: 10),
                                  Text(
                                    'Stop & Save Voice',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const Text('OR'),
                      const SizedBox(height: 5),
                      // Text Description
                      TextField(
                        controller: _textDescriptionTextEditingController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Text Description',
                          labelStyle: TextStyle(color: Colors.blue),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      SizedBox(
                        width: double.maxFinite,
                        child: ThemedElevatedButton(
                          onPressed:
                              ((_textDescription ?? '').isEmpty
                                  ? null
                                  : () {
                                    _addNote();
                                  }),
                          child: const Text(
                            'Save Text Note',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )
              : CircularProgressIndicator(),
    );
  }
}
