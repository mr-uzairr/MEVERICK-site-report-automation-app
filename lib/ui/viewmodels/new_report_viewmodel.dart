import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:site_report_automation_app/data/service/openai_api_service.dart';
import 'package:site_report_automation_app/domain/models/note_model.dart';
import 'package:site_report_automation_app/ui/theme/theme_colors.dart';

class NewReportViewmodel extends ChangeNotifier {
  NewReportViewmodel({required this.apiService});

  final OpenAiApiService apiService;

  List<NoteModel> _noteList = [];

  List<NoteModel> get noteList => _noteList;

  File? _selectedImageFile;

  File? get selectedFile => _selectedImageFile;

  bool get isAddingNote => _selectedImageFile != null;

  bool isGenerating = false;

  String _recommendedServices = '';

  String get recommendedServices => _recommendedServices;

  String _additionalNotes = '';

  String get additionalNotes => _additionalNotes;

  Future<void> pickImageFromGallery() async {
    try {
      Permission.photos.request();
      final ImagePicker picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: ImageSource.gallery);
      if (kDebugMode) {
        print('Picked Image Path: ${pickedImage?.path ?? ''}');
      }
      if (pickedImage == null) return;
      final CroppedFile? croppedImage = await cropImage(pickedImage.path);
      if (kDebugMode) {
        print('Cropped Image Path: ${croppedImage?.path ?? ''}');
      }
      if (croppedImage == null) return;
      _selectedImageFile = File(croppedImage.path);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<void> takeImageFromCamera() async {
    try {
      Permission.camera.request();
      final ImagePicker picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.camera);
      if (image == null) return;
      final CroppedFile? croppedImage = await cropImage(image.path);
      if (croppedImage == null) return;
      _selectedImageFile = File(croppedImage.path);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<CroppedFile?> cropImage(String pickedFilePath) async {
    return await ImageCropper().cropImage(
      sourcePath: pickedFilePath,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Edit Image',
          toolbarColor: Colors.grey[800],
          toolbarWidgetColor: ThemeColors.white,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPresetCustom(),
          ],
        ),
        IOSUiSettings(
          title: 'Edit Image',
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPresetCustom(),
          ],
        ),
      ],
    );
  }

  void onNoteAdd(NoteModel noteModel) {
    _noteList.add(noteModel);
    _selectedImageFile = null;
    notifyListeners();
  }

  Future<void> onNoteRemove(int index) async {
    final noteModel = _noteList[index];
    final imageFile = File(noteModel.imageFilePath ?? '');


    if (await imageFile.exists()) {
      await imageFile.delete();
    }
    _noteList.removeAt(index);
    notifyListeners();
  }

  // Open ROuter API
  Future<void> _generateProblemAndSolutionForEachNoteFromAI(
    int index,
    NoteModel noteModel,
  ) async {
//     final prompt = '''
// Analyze the following maintenance note and provide concise Problem and Solution.
//
// Description: ${noteModel.textDescription}
// Recording: ${noteModel.recordingText}
//
// Format your response exactly as:
//
// Problem: <problem description>
// Solution: <recommended solution>
//   ''';

  final prompt = '''
  You are analyzing a maintenance issue with the following inputs:

- An attached image showing the area of concern
- A written description provided by the user
- A transcription of a voice recording

Carefully examine all available information and provide a detailed, professional assessment.

Respond in this exact format:

Issue: <A Short Issue for Title from the Problem>
Problem: <clearly describe the issue observed in the image, text, or voice input>  
Solution: <clearly describe the recommended fix, next steps, or professional guidance>
Estimated Cost: <Estimated Cost of the Problem in USD Like This: \$1 and Avoid using '-' in Price>

Be as specific and professional as possible in identifying the root cause and suggesting appropriate next steps. Focus on practical, realistic solutions and Don't refer to the Image or Description Like According to Image or Provided Description.

Image: (attached)  
Description: ${noteModel.textDescription}  
Recording: ${noteModel.recordingText}  
''';

    final responseContent = await apiService.getAiResponseWithImageAnalyze(
        prompt: prompt,
        imageFilePath: noteModel.imageFilePath ?? ''
    );

    final issue = _extractFieldFromResponse(responseContent, 'Issue');
    final problemDescription = _extractFieldFromResponse(responseContent, 'Problem');
    final recommendedSolution = _extractFieldFromResponse(responseContent, 'Solution');
    final estimatedCost = _extractFieldFromResponse(responseContent, 'Estimated Cost');

    if (kDebugMode) {
      print('Issue (Extracted): $issue');
      print('Problem (Extracted): $problemDescription');
      print('Solution (Extracted): $recommendedSolution');
      print('Estimated Cost (Extracted): $estimatedCost');
    }

    final updatedNoteModel = _noteList[index].copyWith(
      issue: issue,
      problemDescription: problemDescription,
      recommendedSolution: recommendedSolution,
      estimatedCost: estimatedCost
    );

    _noteList[index] = updatedNoteModel;
    notifyListeners();
  }

  // Open Router API
  Future<void> _generateRecommendedServicesAndAdditionalNotesFromAI(String issue) async {
    final stringBuffer = StringBuffer();

    for (var i = 0; i < _noteList.length; i++) {
      stringBuffer.writeln('Note ${i + 1}:');
      stringBuffer.writeln('Problem: ${_noteList[i].problemDescription}');
      stringBuffer.writeln('Solution: ${_noteList[i].recommendedSolution}');
      stringBuffer.writeln();
    }

    final prompt = '''
Based on the following Issue and job report notes, generate:

- A list of recommended services with the Price in USD Like This \$1 in Each Solution and Avoid using '-' in Price
- A list of Additional notes for the full site report

Return it like this:

Recommended Services: A Simple String but Separate Items Like This: item1* item2  
Additional Notes: A Simple String but Separate Items Like This: item1* item2

$stringBuffer
''';

    final responseContent = await apiService.getAiResponse(prompt: prompt);

    final recommendedServices = _extractFieldFromResponse(
      responseContent,
      'Recommended Services',
    );
    final additionalNotes = _extractFieldFromResponse(
      responseContent,
      'Additional Notes',
    );

    if (kDebugMode) {
      print('Recommended Services (Extracted): $recommendedServices');
      print('Additional Notes (Extracted): $additionalNotes');
    }

    _recommendedServices = recommendedServices;
    _additionalNotes = additionalNotes;
    notifyListeners();
  }

  String _extractFieldFromResponse(String responseContent, String label) {
    if (responseContent.isEmpty) return 'Unable to Fetch Data from AI';

    final match = RegExp(
      '$label:\\s*(.*?)(\\n[A-Z][a-zA-Z ]+:|\\n|\$)',
      caseSensitive: false,
      // ← this allows end of string
      dotAll: true,
    ).firstMatch(responseContent);
    return match?.group(1)?.trim() ?? '';
  }


  Future<void> generateEverythingFromAI(String issue) async {
    isGenerating = true;
    notifyListeners();
    try {
      // Generating Problem and Solution for Each Note
      for (int index = 0; index < _noteList.length; index++) {
        final noteModel = _noteList[index];
        await _generateProblemAndSolutionForEachNoteFromAI(index, noteModel);
      }

      await _generateRecommendedServicesAndAdditionalNotesFromAI(issue);

      isGenerating = false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      isGenerating = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _selectedImageFile = null;
    _noteList = [];

    if (kDebugMode) {
      print('dispose(): NewReportViewModel');
    }
    super.dispose();
  }
}

class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 3);

  @override
  String get name => '2x3 (customized)';
}
