import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/ai_chat_provider.dart';
import 'presentation/providers/procedure_provider.dart';
import 'presentation/providers/voice_provider.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/dialogue_screen.dart';
import 'presentation/screens/result_screen.dart';
import 'presentation/screens/document_generator_screen.dart';

// OpenRouter API Key - Free tier: 20 requests/minute
const String openRouterApiKey = 'REDACTED_OPENROUTER_KEY';

void main() {
  // Initialize dependency injection
  setupDependencies(openRouterApiKey: openRouterApiKey);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProcedureProvider()..init()),
        ChangeNotifierProvider(create: (_) => VoiceProvider()..init()),
        ChangeNotifierProvider(create: (_) => AIChatProvider()..init()),
      ],
      child: const EkemaApp(),
    ),
  );
}

class EkemaApp extends StatelessWidget {
  const EkemaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EKEMA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/dialogue': (context) => const DialogueScreen(),
        '/result': (context) => const ResultScreen(),
        '/document-generator': (context) => const DocumentGeneratorScreen(),
      },
    );
  }
}
