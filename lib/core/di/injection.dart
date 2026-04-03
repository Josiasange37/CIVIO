import 'package:get_it/get_it.dart';
import '../core/services/ai_service.dart';
import '../core/services/connectivity_service.dart';
import '../core/services/fallback_ai_service.dart';
import '../core/services/openrouter_service.dart';
import '../data/repositories/chat_repository.dart';

/// Dependency injection container setup
/// 
/// Usage:
/// ```dart
/// final chatRepo = getIt<ChatRepository>();
/// ```
final GetIt getIt = GetIt.instance;

/// Initialize all dependencies
/// 
/// [openRouterApiKey] - Your OpenRouter API key (get free at openrouter.ai)
void setupDependencies({required String openRouterApiKey}) {
  // Services
  getIt.registerLazySingleton<ConnectivityService>(() {
    final service = ConnectivityService();
    service.initialize();
    return service;
  });

  getIt.registerLazySingleton<OpenRouterService>(
    () => OpenRouterService(apiKey: openRouterApiKey),
  );

  getIt.registerLazySingleton<FallbackAIService>(
    () => FallbackAIService(),
  );

  // Repository
  getIt.registerLazySingleton<ChatRepository>(() {
    return ChatRepository(
      onlineService: getIt<OpenRouterService>(),
      offlineService: getIt<FallbackAIService>(),
      connectivityService: getIt<ConnectivityService>(),
    );
  });
}

/// Reset dependencies (useful for testing)
void resetDependencies() {
  getIt.reset();
}
