import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:site_report_automation_app/data/constants/api_constants.dart';

class OpenAiApiService {
  Future<String> getAiResponseWithImageAnalyze({
    required String prompt,
    required String imageFilePath,
  }) async {
    final url = Uri.parse(ApiConstants.baseUrl);

    final base64Image = await _encodeImageToBase64(imageFilePath);
    final imageMimeType = _getImageMimeType(imageFilePath);

    if (kDebugMode) {
      print('Base64 Image: $base64Image');
      print('Image Mime Type: $imageMimeType');
    }

    final body = await Isolate.run(
      () => jsonEncode({
        'model': 'gpt-4.1',
        'messages': [
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': prompt},
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:$imageMimeType;base64,$base64Image',
                  // OpenAI Supports this Format for base64 Image
                },
              },
            ],
          },
        ],
        'temperature': 0.3,
        'max_tokens': 700,
      }),
    );

    // Body of Without Analyzing Image

    // final body = await Isolate.run(
    //   () => jsonEncode({
    //     'model': 'gpt-4.1',
    //     'messages': [
    //       {'role': 'user', 'content': prompt},
    //     ],
    //     'temperature': 0.3,
    //     'max_tokens': 500,
    //   }),
    // );

    final response = await http.post(
      url,
      headers: ApiConstants.headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final mappedData = await Isolate.run(() => jsonDecode(response.body));
      final contentString =
          mappedData['choices'][0]['message']['content'] as String;

      if (kDebugMode) {
        print('Response Body ${response.body}');
        print('Content String: $contentString');
      }

      return contentString;
    } else {
      if (kDebugMode) {
        print('Response Body (Failed) ${response.body}');
        print('Status Code ${response.statusCode}');
      }
      throw Exception('Failed to Get AI Response');
    }
  }

  Future<String> getAiResponse({required String prompt}) async {
    final url = Uri.parse(ApiConstants.baseUrl);

    final body = await Isolate.run(
      () => jsonEncode({
        'model': 'gpt-4.1',
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.3,
        'max_tokens': 700,
      }),
    );

    final response = await http.post(
      url,
      headers: ApiConstants.headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final mappedData = await Isolate.run(() => jsonDecode(response.body));
      final contentString =
          mappedData['choices'][0]['message']['content'] as String;

      if (kDebugMode) {
        print('Response Body ${response.body}');
        print('Content String: $contentString');
      }

      return contentString;
    } else {
      if (kDebugMode) {
        print('Response Body (Failed) ${response.body}');
        print('Status Code ${response.statusCode}');
      }
      throw Exception('Failed to Get AI Response');
    }
  }

  Future<String> _encodeImageToBase64(String imageFilePath) async {
    final imageFile = File(imageFilePath);
    if (!await imageFile.exists()) return '';

    final compressedImageBytes = await _compressImage(imageFile);

    // Returning Base64Encoded String
    return await Isolate.run(() => base64Encode(compressedImageBytes));
  }

  Future<Uint8List> _compressImage(File file) async {
    final originalBytes = await file.readAsBytes();
    return await Isolate.run(() {
      final decodedImage = img.decodeImage(originalBytes);
      if (decodedImage != null) {
        final resized = img.copyResize(decodedImage, width: 512);
        return Uint8List.fromList(img.encodeJpg(resized, quality: 75));
      } else {
        return originalBytes;
      }
    });
  }

  String _getImageMimeType(String imagePath) {
    if (imagePath.toLowerCase().endsWith('.png')) return 'image/png';
    if (imagePath.toLowerCase().endsWith('.webp')) return 'image/webp';
    if (imagePath.toLowerCase().endsWith('.gif')) return 'image/gif';

    // Otherwise image/jpeg
    return 'image/jpeg';
  }
}
