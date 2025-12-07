class ApiConstants {

  static const String baseUrl = 'https://api.openai.com/v1/chat/completions';
  static const String api = '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';
  static const String aIModelName = 'gpt-4.1';

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $api',
  };

}
