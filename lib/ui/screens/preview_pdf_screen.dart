import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:site_report_automation_app/navigation/screen_routes.dart';
import 'package:site_report_automation_app/ui/widgets/themed_app_bar.dart';
import 'package:site_report_automation_app/ui/widgets/themed_elevated_button.dart';

class PreviewPdfScreen extends StatefulWidget {
  const PreviewPdfScreen({
    super.key,
    required this.pdfFilePath,
    required this.pdfFileName,
    required this.jobName
  });

  final String pdfFilePath;
  final String pdfFileName;
  final String jobName;

  @override
  State<PreviewPdfScreen> createState() => _PreviewPdfScreenState();
}

class _PreviewPdfScreenState extends State<PreviewPdfScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> downloadPdf() async {
    try {
      // Requesting Permission
      if (defaultTargetPlatform == TargetPlatform.android) {
        var permissionStatus = await Permission.storage.request();

        if (!permissionStatus.isGranted) return;
      }

      if (defaultTargetPlatform == TargetPlatform.android) {

        final pdfFile = File(widget.pdfFilePath);
        if (await pdfFile.exists()) {
          final pdfBytes = await pdfFile.readAsBytes();

          final directories = await getExternalStorageDirectories(type: StorageDirectory.documents);
          final documentsDirectory = directories?.first;
          final file = File('${documentsDirectory?.path ?? ''}/${widget.pdfFileName}');
          await file.writeAsBytes(pdfBytes);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Pdf File is Saved to your Documents Folder'),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('No Pdf File Exist!')));
          }
        }
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        await sharePdf();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> printPdf() async {
    try {
      final pdfFile = File(widget.pdfFilePath);
      if (await pdfFile.exists()) {
        final pdfBytes = await pdfFile.readAsBytes();
        await Printing.layoutPdf(onLayout: (_) => pdfBytes);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('No Pdf File Exist!')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> sharePdf() async {
    try {
      final pdfFile = File(widget.pdfFilePath);
      if (await pdfFile.exists()) {
        final pdfBytes = await pdfFile.readAsBytes();
        await Printing.sharePdf(bytes: pdfBytes, filename: widget.pdfFileName);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('No Pdf File Exist!')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> emailPdf() async {
    final file = File(widget.pdfFilePath);

    if (await file.exists()) {
      final mail = Email(
        subject: '${widget.jobName} Site Report',
        recipients: ['user@example.com'],
        attachmentPaths: [widget.pdfFilePath],
        isHTML: false
      );

      try {
        await FlutterEmailSender.send(mail);
      } catch (e) {
        await sharePdf();
      }

    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pdf File is Not Exist in the Application Storage'))
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ThemedAppBar(
        title: 'Preview Pdf',
        actions: [
          // Email Pdf
          Tooltip(
            message: 'Email Pdf',
            child: IconButton(
              onPressed: (() async => emailPdf()),
              icon: Icon(Icons.email, color: Colors.white),
            ),
          ),
          // Download Pdf
          Tooltip(
            message: 'Download Pdf',
            child: IconButton(
              onPressed: (() async => downloadPdf()),
              icon: Icon(Icons.download, color: Colors.white),
            ),
          ),
          // Print Pdf
          Tooltip(
            message: 'Print Pdf',
            child: IconButton(
              onPressed: (() async => printPdf()),
              icon: Icon(Icons.print, color: Colors.white),
            ),
          ),
          // Share Pdf
          Tooltip(
            message: 'Share Pdf',
            child: IconButton(
              onPressed: (() async => sharePdf()),
              icon: Icon(Icons.share, color: Colors.white),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 30.0),
        child: ThemedElevatedButton(
          onPressed: (() {
            Future.microtask(() {
              if (context.mounted) {
                context.go(ScreenRoutes.reportActionsScreenRoute);
              }
            });
          }),
          child: const Text(
            'Return to Home Page',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: PopScope(
        onPopInvokedWithResult: (didPop, result) {
          Future.microtask(() {
            if (context.mounted) {
              context.go(ScreenRoutes.reportActionsScreenRoute);
            }
          });
        },
        child: PdfPreview(
          build: (_) async {
            final pdfFile = File(widget.pdfFilePath);
            final pdfBytes = await pdfFile.readAsBytes();
            return pdfBytes;
          },
          loadingWidget: CircularProgressIndicator(),
          useActions: false,
          pdfFileName: widget.pdfFileName ?? '',
          onError: ((_, error) => Center(child: Text(error.toString()))),
        ),
      ),
    );
  }
}
