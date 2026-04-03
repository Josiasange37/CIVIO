import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'ai_service.dart';

/// OpenRouter AI service implementation
/// Uses free tier models: mistral-7b-instruct, llama-3-8b-instruct, gemma-2-9b-it
class OpenRouterService implements AIService {
  static const String _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';
  static const String _defaultModel = 'mistralai/mistral-7b-instruct:free';
  
  final String apiKey;
  final String model;
  
  @override
  String get modelName => model;

  OpenRouterService({
    required this.apiKey,
    this.model = _defaultModel,
  });

  @override
  Future<bool> isAvailable() async {
    try {
      final response = await http.get(
        Uri.parse('https://openrouter.ai/api/v1/auth/key'),
        headers: {
          'Authorization': 'Bearer $apiKey',
        },
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> sendMessage({
    required List<Map<String, String>> messages,
    required String userMessage,
  }) async {
    try {
      final formattedMessages = messages.map((msg) => {
        'role': msg['role'],
        'content': msg['content'],
      }).toList();

      // Add the current user message
      formattedMessages.add({
        'role': 'user',
        'content': userMessage,
      });

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
          'HTTP-Referer': 'https://ekema.app',
          'X-Title': 'EKEMA - Assistant Administratif Cameroun',
        },
        body: jsonEncode({
          'model': model,
          'messages': formattedMessages,
          'temperature': 0.7,
          'max_tokens': 1000,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final choices = data['choices'] as List<dynamic>;
        
        if (choices.isNotEmpty) {
          final message = choices[0]['message'];
          return message['content'] as String;
        }
        return null;
      } else {
        // Handle rate limiting (free tier: 20 req/min)
        if (response.statusCode == 429) {
          throw Exception('Rate limit exceeded. Please wait a moment.');
        }
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on FormatException {
      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  /// Alternative free models available on OpenRouter
  static const List<String> freeModels = [
    'mistralai/mistral-7b-instruct:free',
    'meta-llama/llama-3-8b-instruct:free',
    'google/gemma-2-9b-it:free',
    'huggingfaceh4/zephyr-7b-beta:free',
  ];
}
