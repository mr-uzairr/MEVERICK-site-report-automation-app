import 'package:site_report_automation_app/domain/models/note_model.dart';

class ReportModel {

  ReportModel({
    required this.jobName,
    required this.issue,
    required this.clientName,
    required this.address,
    required this.phoneNumber,
    required this.date,
    required this.noteList,
    required this.recommendedServices,
    required this.additionalNotes,
    required this.pdfFilePath,
  });

  final String? jobName, issue, clientName, address, phoneNumber, date;
  final List<NoteModel> noteList;
  final String? recommendedServices, additionalNotes;
  final String? pdfFilePath;


  ReportModel copyWith({
    String? jobName,
    String? issue,
    String? clientName,
    String? address,
    String? phoneNumber,
    String? date,
    List<NoteModel>? noteList,
    String? recommendedServices,
    String? additionalNotes,
    String? pdfFilePath,
  }) {
    return ReportModel(
      jobName: jobName ?? this.jobName,
      issue: issue ?? this.issue,
      clientName: clientName ?? this.clientName,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      date: date ?? this.date,
      noteList: noteList ?? this.noteList,
      recommendedServices: recommendedServices?? this.recommendedServices,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      pdfFilePath: pdfFilePath ?? this.pdfFilePath
    );
  }

  
  
  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
        jobName: json['jobName'] as String?,
        issue: json['issue'] as String?,
        clientName: json['clientName'] as String?,
        address: json['address'] as String?,
        phoneNumber: json['phoneNumber'] as String?,
        date: json['date'] as String?,
        noteList: (json['noteList'] as List).map((element) => NoteModel.fromJson(element)).toList(),
        recommendedServices: json['recommendedServices'] as String?,
        additionalNotes: json['additionalNotes'] as String?,
        pdfFilePath: json['pdfFilePath'] as String?
    );
  }



  Map<String, dynamic> toJson() => {
    'jobName': jobName,
    'issue': issue,
    'clientName': clientName,
    'address': address,
    'phoneNumber': phoneNumber,
    'date': date,
    'noteList': noteList.map((noteModel) => noteModel.toJson()).toList(),
    'recommendedServices': recommendedServices,
    'additionalNotes': additionalNotes,
    'pdfFilePath': pdfFilePath
  };
  
  
}