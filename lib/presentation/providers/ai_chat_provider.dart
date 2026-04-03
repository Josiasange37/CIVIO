import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/di/injection.dart';
import '../../data/repositories/chat_repository.dart';

enum ChatMode { online, offline, unavailable }

class AIChatProvider with ChangeNotifier {
  final ChatRepository _repository = getIt<ChatRepository>();
  
  List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  ChatMode _mode = ChatMode.offline;
  String _serviceInfo = '';
  bool _isInitialized = false;
  
  StreamSubscription<bool>? _connectivitySubscription;

  // Getters
  List<Map<String, String>> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  ChatMode get mode => _mode;
  String get serviceInfo => _serviceInfo;
  bool get isInitialized => _isInitialized;
  bool get isOnline => _mode == ChatMode.online;

  /// Initialize the provider and check service availability
  Future<void> init() async {
    if (_isInitialized) return;
    
    await _checkAvailability();
    
    // Listen to connectivity changes
    _connectivitySubscription = _repository.connectivityStream.listen((isConnected) {
      _checkAvailability();
    });
    
    _isInitialized = true;
    notifyListeners();
  }

  /// Check current service availability
  Future<void> _checkAvailability() async {
    try {
      final availability = await _repository.checkAvailability();
      final info = await _repository.getServiceInfo();
      
      final mode = availability['mode'] as String;
      _mode = mode == 'ai' 
          ? ChatMode.online 
          : (mode == 'fallback' ? ChatMode.offline : ChatMode.unavailable);
      
      _serviceInfo = '${info['mode']} - ${info['status']}';
      notifyListeners();
    } catch (e) {
      _mode = ChatMode.unavailable;
      _serviceInfo = 'Service indisponible';
      notifyListeners();
    }
  }

  /// Send a user message and get AI response
  Future<void> sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty) return;
    
    _isLoading = true;
    
    // Add user message
    _messages.add({
      'role': 'user',
      'content': userMessage,
    });
    notifyListeners();

    try {
      final response = await _repository.sendMessage(
        messages: _messages.sublist(0, _messages.length - 1),
        userMessage: userMessage,
      );

      // Add assistant response
      _messages.add({
        'role': 'assistant',
        'content': response,
      });
      
      // Refresh availability status after response
      await _checkAvailability();
    } catch (e) {
      _messages.add({
        'role': 'assistant',
        'content': 'Désolé, une erreur est survenue. Veuillez réessayer.',
      });
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear chat history
  void clearChat() {
    _messages = [];
    notifyListeners();
  }

  /// Get welcome message based on current mode
  String getWelcomeMessage() {
    switch (_mode) {
      case ChatMode.online:
        return 'Bonjour ! Je suis EKEMA, votre assistant administratif alimenté par IA. Comment puis-je vous aider aujourd\'hui ?';
      case ChatMode.offline:
        return 'Bonjour ! Je suis EKEMA (mode hors-ligne). Je peux vous aider avec les procédures administratives de base. Comment puis-je vous aider ?';
      case ChatMode.unavailable:
        return 'Bonjour ! Le service est temporairement indisponible. Veuillez vérifier votre connexion ou réessayer plus tard.';
    }
  }

  /// Refresh connection status manually
  Future<void> refreshStatus() async {
    await _checkAvailability();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
