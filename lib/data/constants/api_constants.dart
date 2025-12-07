class ApiConstants {

  static const String baseUrl = 'https://api.openai.com/v1/chat/completions';
  static const String api = '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';
  static const String aIModelName = 'gpt-4.1';

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $api',
  };

}
