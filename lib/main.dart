import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/config/app_config.dart';
import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/ai_chat_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/procedure_provider.dart';
import 'presentation/providers/voice_provider.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/dialogue_screen.dart';
import 'presentation/screens/result_screen.dart';
import 'presentation/screens/document_generator_screen.dart';
import 'presentation/screens/ai_chat_screen.dart';
import 'presentation/screens/offline_map_screen.dart';
import 'presentation/widgets/demo_mode_banner.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'firebase_options.dart';

// OpenRouter API Key - Free tier: 20 requests/minute
// Set via: flutter run --dart-define=OPENROUTER_API_KEY=sk-or-v1-...
const String openRouterApiKey = String.fromEnvironment('OPENROUTER_API_KEY', defaultValue: '');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initializeFirebase();

  setupDependencies(openRouterApiKey: openRouterApiKey);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProcedureProvider()..init()),
        ChangeNotifierProvider(create: (_) => VoiceProvider()..init()),
        ChangeNotifierProvider(create: (_) => AIChatProvider()..init()),
      ],
      child: const CivioApp(),
    ),
  );
}

Future<void> _initializeFirebase() async {
  if (!AppConfig.firebaseSupported) {
    AppConfig.firebaseEnabled = false;
    debugPrint('Civio: Firebase not supported on this platform — running in demo mode.');
    return;
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    if (AppConfig.isDesktopEmulatorHost && AppConfig.useEmulatorByDefault) {
      await _connectToEmulators();
    } else {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
      );
    }

    AppConfig.firebaseEnabled = true;
    debugPrint('Civio: Firebase initialized successfully.');
  } catch (e, st) {
    AppConfig.firebaseEnabled = false;
    debugPrint('Civio: Firebase.initializeApp() failed — running in demo mode.');
    debugPrint('  Error: $e');
    debugPrint('  Stack: $st');
  }
}

Future<void> _connectToEmulators() async {
  const host = AppConfig.emulatorHost;
  const authPort = AppConfig.authEmulatorPort;
  const fsPort = AppConfig.firestoreEmulatorPort;

  try {
    await FirebaseAuth.instance.useAuthEmulator(host, authPort);
  } catch (e) {
    debugPrint('Civio: useAuthEmulator failed: $e');
  }

  try {
    FirebaseFirestore.instance
        .useFirestoreEmulator(host, fsPort, sslEnabled: false);
  } catch (e) {
    debugPrint('Civio: useFirestoreEmulator failed: $e');
  }

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false,
  );

  debugPrint('Civio: connected to local Firebase Emulator '
      '(auth=$host:$authPort, firestore=$host:$fsPort).');
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
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            if (AppConfig.isDemoMode)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: DemoModeBanner(),
                ),
              ),
          ],
        );
      },
      routes: {
        '/': (context) => const SplashScreen(),
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
