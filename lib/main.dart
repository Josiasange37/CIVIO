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
import 'presentation/screens/ai_chat_screen.dart';
import 'presentation/screens/offline_map_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// OpenRouter API Key - Free tier: 20 requests/minute
// Set via: flutter run --dart-define=OPENROUTER_API_KEY=sk-or-v1-...
const String openRouterApiKey = String.fromEnvironment('OPENROUTER_API_KEY', defaultValue: '');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Activer la persistance hors-ligne pour Firestore (crucial pour votre cahier des charges)
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  setupDependencies(openRouterApiKey: openRouterApiKey);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProcedureProvider()..init()),
        ChangeNotifierProvider(create: (_) => VoiceProvider()..init()),
        ChangeNotifierProvider(create: (_) => AIChatProvider()..init()),
      ],
      child: const CivioApp(),
    ),
  );
}

class CivioApp extends StatelessWidget {
  const CivioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Civio',
      debugShowCheckedModeBanner: false,
      theme: CivioTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/dialogue': (context) => const DialogueScreen(),
        '/result': (context) => const ResultScreen(),
        '/document-generator': (context) => const DocumentGeneratorScreen(),
        '/ai-chat': (context) => const AIChatScreen(),
        '/map': (context) {
          final procedure = context.read<ProcedureProvider>().selectedProcedure;
          return OfflineMapScreen(locations: procedure?.locations ?? []);
        },
      },
    );
  }
}
