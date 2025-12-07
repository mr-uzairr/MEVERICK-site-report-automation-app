import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  @override
  void initState() {
    super.initState();
    _reportActionsViewmodel = context.read<ReportActionsViewmodel>();
    _getReportActionsList();
  }

  Future<void> _getReportActionsList() async {
    setState(() {
      isLoading = true;
    });
    final reportActionsList =
        await _reportActionsViewmodel?.getSavedReportActions();
    setState(() {
      _reportActions = reportActionsList ?? [];
    });
    setState(() {
      isLoading = false;
    });
    if (kDebugMode) {
      print('Report Actions List Length: ${_reportActions.length}');
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
                              onSeeDetails: ((reportModel) {
                                context.push(
                                  ScreenRoutes.reportActionDetailScreenRoute,
                                  extra: reportModel,
                                );
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

class ReportActionsListItem extends StatelessWidget {
  const ReportActionsListItem({
    super.key,
    required this.reportModel,
    required this.onSeeDetails,
  });

  final ReportModel reportModel;
  final Function(ReportModel) onSeeDetails;

  @override
  Widget build(BuildContext context) {
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
              onPressed: (() => onSeeDetails(reportModel)),
              child: const Text('See Details >'),
            ),
          ),
        ],
      ),
    );
  }
}
