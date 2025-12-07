class NoteModel {

  NoteModel({
    required this.imageFileName,
    required this.imageFilePath,
    required this.recordingText,
    required this.textDescription,
    required this.issue,
    required this.problemDescription,
    required this.recommendedSolution,
    required this.estimatedCost
  });

  final String? imageFileName;
  final String? imageFilePath;
  final String? recordingText;
  final String? textDescription;



  final String? issue, problemDescription, recommendedSolution, estimatedCost;  // AI-GENERATED


  NoteModel copyWith({
    String? imageFileName,
    String? imageFilePath,
    String? recordingText,
    String? textDescription,
    String? issue,
    String? problemDescription,
    String? recommendedSolution,
    String? estimatedCost,
  }) {
    return NoteModel(
        imageFileName: imageFileName ?? this.imageFileName,
        imageFilePath: imageFilePath ?? this.imageFilePath,
        recordingText: recordingText ?? this.recordingText,
        textDescription: textDescription ?? this.textDescription,
        issue: issue ?? this.issue,
        problemDescription: problemDescription ?? this.problemDescription,
        recommendedSolution: recommendedSolution ?? this.recommendedSolution,
        estimatedCost: estimatedCost ?? this.estimatedCost,
    );
  }



  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      imageFileName: json['imageFileName'] as String?,
      imageFilePath: json['imageFilePath'] as String?,
      recordingText: json['recordingText'] as String?,
      textDescription: json['textDescription'] as String?,
      issue: json['issue'] as String?,
      problemDescription: json['problemDescription'] as String?,
      recommendedSolution: json['recommendedSolution'] as String?,
      estimatedCost: json['estimatedCost'] as String?
    );
  }


  Map<String, dynamic> toJson() => {
    'imageFileName': imageFileName,
    'imageFilePath': imageFilePath,
    'recordingText': recordingText,
    'textDescription': textDescription,
    'issue': issue,
    'problemDescription': problemDescription,
    'recommendedSolution': recommendedSolution,
    'estimatedCost': estimatedCost,
  };


}