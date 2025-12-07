import 'dart:convert';
import 'dart:typed_data';

import 'package:aws_s3_api/s3-2006-03-01.dart';
import 'package:site_report_automation_app/data/constants/api_constants.dart';

class S3Service {
  late final S3 _s3;

  S3Service() {
    _s3 = S3(
      region: ApiConstants.awsRegion,
      credentials: AwsClientCredentials(
        accessKey: ApiConstants.awsAccessKeyId,
        secretKey: ApiConstants.awsSecretAccessKey,
      ),
    );
  }

  Future<void> uploadPdf(String key, Uint8List pdfBytes) async {
    await _s3.putObject(
      bucket: ApiConstants.s3BucketName,
      key: key,
      body: pdfBytes,
      contentType: 'application/pdf',
    );
  }

  Future<List<String>> listLatestPdfs({int limit = 5}) async {
    final response = await _s3.listObjectsV2(
      bucket: ApiConstants.s3BucketName,
      maxKeys: limit,
    );

    final objects = response.contents ?? [];
    // Sort by last modified, latest first
    objects.sort((a, b) => b.lastModified!.compareTo(a.lastModified!));

    return objects.take(limit).map((obj) => obj.key!).toList();
  }

  Future<Uint8List> downloadPdf(String key) async {
    final response = await _s3.getObject(
      bucket: ApiConstants.s3BucketName,
      key: key,
    );
    return response.body!;
  }

  Future<void> uploadJson(String key, Map<String, dynamic> jsonMap) async {
    final jsonString = jsonEncode(jsonMap);
    final bytes = Uint8List.fromList(utf8.encode(jsonString));
    await _s3.putObject(
      bucket: ApiConstants.s3BucketName,
      key: key,
      body: bytes,
      contentType: 'application/json',
    );
  }

  Future<Map<String, dynamic>?> downloadJson(String key) async {
    try {
      final response = await _s3.getObject(
        bucket: ApiConstants.s3BucketName,
        key: key,
      );
      final bytes = response.body;
      if (bytes == null) return null;
      final jsonString = utf8.decode(bytes);
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
}