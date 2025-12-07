import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:site_report_automation_app/domain/models/report_model.dart';
import 'package:site_report_automation_app/navigation/screen_routes.dart';
import 'package:site_report_automation_app/ui/theme/theme_colors.dart';
import 'package:site_report_automation_app/ui/viewmodels/report_actions_viewmodel.dart';
import 'package:site_report_automation_app/ui/widgets/themed_app_bar.dart';
import 'package:site_report_automation_app/ui/widgets/themed_elevated_button.dart';

class ReportActionsScreen extends StatefulWidget {
  const ReportActionsScreen({super.key});

  @override
  State<ReportActionsScreen> createState() => _ReportActionsScreenState();
}

class _ReportActionsScreenState extends State<ReportActionsScreen> {
  List<ReportModel> _reportActions = [];
  ReportActionsViewmodel? _reportActionsViewmodel;
  bool isLoading = false;
  List<S3ReportItem> _latestS3Items = [];
  bool _isFirstLaunch = false;

  @override
  void initState() {
    super.initState();
    _reportActionsViewmodel = context.read<ReportActionsViewmodel>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        await _initialize();
      }
    });
  }

  Future<void> _initialize() async {
    await _getReportActionsList();
    _isFirstLaunch = await _reportActionsViewmodel!.isFirstLaunch();
    if (_isFirstLaunch) {
      await _getLatestPdfs();
    }
  }

  Future<void> _getReportActionsList() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    final reportActionsList =
        await _reportActionsViewmodel?.getSavedReportActions();
    if (mounted) {
      setState(() {
        _reportActions = reportActionsList ?? [];
      });
      setState(() {
        isLoading = false;
      });
    }
    if (kDebugMode) {
      print('Report Actions List Length: ${_reportActions.length}');
    }
  }

  Future<void> _getLatestPdfs() async {
    final items = await _reportActionsViewmodel!.getLatestS3ReportItems(limit: 5);
    if (mounted) {
      setState(() {
        _latestS3Items = items;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ThemedAppBar(
        title: 'Report Actions',
        actions: [
          Tooltip(
            message: 'Refresh',
            child: IconButton(
              onPressed: (() async => _getReportActionsList()),
              icon: const Icon(Icons.refresh, color: Colors.white),
            ),
          ),
        ],
      ),
      /* const EdgeInsets.all(10.0) will Don't Show Padding at the Bottom in IOS */
      /* 30.0 Padding at the Bottom may Add little more padding in Android */
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 30.0),
        child: ThemedElevatedButton(
          onPressed: (() {
            context.push(ScreenRoutes.newReportScreenRoute);
          }),
          child: const Text(
            'Create New Report',
            style: TextStyle(color: ThemeColors.white),
          ),
        ),
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 10),
                    if (_isFirstLaunch && _latestS3Items.isNotEmpty) ...[
                      const Text(
                        'Preview Reports',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Column(
                        children: _latestS3Items.map((item) {
                          final displayTitle = item.reportModel?.jobName ?? item.key.split('/').last;
                          final displayIssue = item.reportModel?.issue ?? '';
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
                            child: S3ReportCard(
                              title: displayTitle,
                              subtitle: displayIssue,
                              onSeeDetails: () async {
                                try {
                                  if (item.reportModel != null) {
                                    if (context.mounted) {
                                      context.push(
                                        ScreenRoutes.previewReportScreenRoute,
                                        extra: item.reportModel,
                                      );
                                    }
                                    return;
                                  }

                                  // Fallback to downloading and previewing PDF
                                  final key = item.key;
                                  final fileName = key.split('/').isNotEmpty ? key.split('/').last : key;
                                  final pdfBytes = await _reportActionsViewmodel!.s3Service.downloadPdf(key);
                                  final tempDir = await getTemporaryDirectory();
                                  final filePath = '${tempDir.path}/$fileName';
                                  final file = File(filePath);
                                  await file.writeAsBytes(pdfBytes, flush: true);
                                  if (context.mounted) {
                                    context.push(
                                      '${ScreenRoutes.previewPdfScreenRoute}/${Uri.encodeComponent(fileName)}/${Uri.encodeComponent('S3 PDF')}',
                                      extra: file.path,
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Failed to open PDF: ${e.toString()}')),
                                    );
                                  }
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 20),
                    ],
                    Center(
                      child: const Text(
                        'Report Actions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    _reportActions.isNotEmpty ? Column(
                      children:
                          _reportActions.map((reportModel) {
                            return ReportActionsListItem(
                              reportModel: reportModel,
                              onSeeDetails: ((reportModel) async {
                                if (context.mounted) {
                                  context.push(
                                    ScreenRoutes.reportActionDetailScreenRoute,
                                    extra: reportModel,
                                  );
                                }
                              }),
                            );
                          }).toList(),
                    ) : SizedBox(),
                  ],
                ),
              ),
    );
  }
}

class ReportActionsListItem extends StatefulWidget {
  const ReportActionsListItem({
    super.key,
    required this.reportModel,
    required this.onSeeDetails,
  });

  final ReportModel reportModel;
  final Future<void> Function(ReportModel) onSeeDetails;

  @override
  State<ReportActionsListItem> createState() => _ReportActionsListItemState();
}

class _ReportActionsListItemState extends State<ReportActionsListItem> {
  bool _isLoading = false;

  Future<void> _handleSeeDetails() async {
    setState(() => _isLoading = true);
    try {
      await widget.onSeeDetails(widget.reportModel);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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

    return Container(
      margin: const EdgeInsets.all(10.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: ThemeColors.cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Job Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text('Job Name: $jobName'),
          Text('Issue: $issue'),
          Text('Client: $clientName'),
          Text('Address: $address'),
          Text('Date: $date'),
          const SizedBox(height: 10),
          // Photos
          const Text(
            'Photos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  noteList.map((noteModel) {
                    if ((noteModel.imageFilePath ?? '').isNotEmpty) {
                      final imageFile = File(noteModel.imageFilePath!);
                      return Container(
                        width: 100,
                        height: 100,
                        margin: const EdgeInsets.fromLTRB(0.0, 5.0, 10.0, 0.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          image: DecorationImage(
                            image: FileImage(imageFile),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text('Failed to load Image'),
                      );
                    }
                  }).toList(),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: TextButton(
              onPressed: _isLoading ? null : _handleSeeDetails,
              child: _isLoading ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('See Details >'),
            ),
          ),
        ],
      ),
    );
  }
}

class S3ReportCard extends StatefulWidget {
  const S3ReportCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onSeeDetails,
  });

  final String title;
  final String subtitle;
  final Future<void> Function()? onSeeDetails;

  @override
  State<S3ReportCard> createState() => _S3ReportCardState();
}

class _S3ReportCardState extends State<S3ReportCard> {
  bool _isLoading = false;

  Future<void> _handleTap() async {
    if (widget.onSeeDetails == null) return;
    setState(() => _isLoading = true);
    try {
      await widget.onSeeDetails!();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: ThemeColors.cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Job Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Job Name: ${widget.title}'),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _isLoading ? null : _handleTap,
              child: _isLoading ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('See Details >'),
            ),
          ),
        ],
      ),
    );
  }
}
