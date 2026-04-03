import 'ai_service.dart';
import 'connectivity_service.dart';
import 'fallback_ai_service.dart';
import 'openrouter_service.dart';

/// Hybrid chat repository that switches between online AI and offline fallback
class ChatRepository {
  final OpenRouterService _onlineService;
  final FallbackAIService _offlineService;
  final ConnectivityService _connectivityService;

  ChatRepository({
    required OpenRouterService onlineService,
    required FallbackAIService offlineService,
    required ConnectivityService connectivityService,
  })  : _onlineService = onlineService,
        _offlineService = offlineService,
        _connectivityService = connectivityService;

  /// Get the currently available AI service
  Future<AIService> _getAvailableService() async {
    final isOnline = await _connectivityService.checkConnection();
    
    if (isOnline) {
      final isAIAvailable = await _onlineService.isAvailable();
      if (isAIAvailable) {
        return _onlineService;
      }
    }
    
    return _offlineService;
  }

  /// Send a message and get a response
  /// Automatically selects between online AI and offline fallback
  Future<String> sendMessage({
    required List<Map<String, String>> messages,
    required String userMessage,
  }) async {
    try {
      final service = await _getAvailableService();
      final response = await service.sendMessage(
        messages: messages,
        userMessage: userMessage,
      );
      
      return response ?? 'Désolé, je ne peux pas répondre pour le moment.';
    } catch (e) {
      // If online service fails, try offline
      if (await _connectivityService.checkConnection()) {
        try {
          final response = await _offlineService.sendMessage(
            messages: messages,
            userMessage: userMessage,
          );
          return response ?? _getGenericResponse();
        } catch (_) {
          return _getGenericResponse();
        }
      }
      return _getGenericResponse();
    }
  }

  /// Check if AI features are available
  Future<Map<String, dynamic>> checkAvailability() async {
    final isOnline = await _connectivityService.checkConnection();
    final isAIAvailable = isOnline ? await _onlineService.isAvailable() : false;
    final isFallbackAvailable = await _offlineService.isAvailable();

    return {
      'isOnline': isOnline,
      'isAIAvailable': isAIAvailable,
      'isFallbackAvailable': isFallbackAvailable,
      'mode': isAIAvailable ? 'ai' : (isFallbackAvailable ? 'fallback' : 'unavailable'),
      'modelName': isAIAvailable ? _onlineService.modelName : _offlineService.modelName,
    };
  }

  /// Get current service info
  Future<Map<String, String>> getServiceInfo() async {
    final availability = await checkAvailability();
    
    if (availability['mode'] == 'ai') {
      return {
        'mode': 'Intelligence Artificielle',
        'model': availability['modelName'] as String,
        'status': 'En ligne',
      };
    } else if (availability['mode'] == 'fallback') {
      return {
        'mode': 'Mode Hors-ligne',
        'model': 'Base de données locale',
        'status': availability['isOnline'] as bool ? 'IA indisponible' : 'Sans connexion',
      };
    } else {
      return {
        'mode': 'Indisponible',
        'model': 'Aucun service',
        'status': 'Erreur',
      };
    }
  }

  String _getGenericResponse() {
    return '''Désolé, je ne peux pas accéder aux informations pour le moment.

Veuillez vérifier votre connexion internet ou réessayer plus tard.

En attendant, vous pouvez consulter les procédures disponibles sur la page d'accueil.''';
  }

  /// Stream of connectivity changes
  Stream<bool> get connectivityStream => _connectivityService.onConnectivityChanged;
}
