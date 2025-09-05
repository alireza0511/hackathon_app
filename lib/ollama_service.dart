import 'dart:convert';

import 'package:http/http.dart' as http;

class OllamaService {
  static const String baseUrl = 'http://localhost:11434';
  static const String defaultModel = 'llama3.2';

  static Future<String> generateResponse(String prompt, {String? model}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': model ?? defaultModel,
          'prompt': prompt,
          'stream': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? 'No response received';
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to Ollama: $e');
    }
  }

  static Future<List<String>> getAvailableModels() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/tags'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final models = data['models'] as List<dynamic>? ?? [];
        return models.map((model) => model['name'] as String).toList();
      } else {
        return [defaultModel];
      }
    } catch (e) {
      return [defaultModel];
    }
  }

  static Future<bool> isServerAvailable() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/version'),
       // timeout: const Duration(seconds: 5),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}