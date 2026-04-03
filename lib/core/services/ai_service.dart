/// Abstract interface for AI chat services
abstract class AIService {
  /// Sends a message to the AI and returns the response
  /// [messages] - List of previous messages for context
  /// [userMessage] - The current user message
  /// Returns the AI response or null if the service is unavailable
  Future<String?> sendMessage({
    required List<Map<String, String>> messages,
    required String userMessage,
  });

  /// Checks if the AI service is available
  Future<bool> isAvailable();

  /// Gets the model name being used
  String get modelName;
}
