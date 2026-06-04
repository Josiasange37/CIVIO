import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/procedure.dart';
import 'ai_service.dart';

/// Fallback AI service that uses Firestore procedures
/// Used when offline or when OpenRouter is unavailable
class FallbackAIService implements AIService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Procedure> _procedures = [];
  bool _initialized = false;

  @override
  String get modelName => 'firestore-fallback';

  Future<void> _init() async {
    if (_initialized) return;

    try {
      final snapshot = await _firestore
          .collection('procedures')
          .get(const GetOptions(source: Source.serverAndCache));
      _procedures = snapshot.docs
          .map((doc) => Procedure.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
      _initialized = true;
    } catch (e) {
      _procedures = [];
    }
  }

  @override
  Future<bool> isAvailable() async {
    await _init();
    return _procedures.isNotEmpty;
  }

  @override
  Future<String?> sendMessage({
    required List<Map<String, String>> messages,
    required String userMessage,
  }) async {
    await _init();

    final lowerMessage = userMessage.toLowerCase();

    Procedure? matchedProcedure;

    for (final procedure in _procedures) {
      final title = procedure.title.toLowerCase();
      final category = procedure.category.toLowerCase();
      final description = procedure.description.toLowerCase();

      if (lowerMessage.contains(title) ||
          lowerMessage.contains(category) ||
          title.contains(lowerMessage) ||
          description.contains(lowerMessage.split(' ').first)) {
        matchedProcedure = procedure;
        break;
      }
    }

    if (matchedProcedure == null) {
      if (_procedures.isEmpty) {
        return "Je suis Civio, votre assistant administratif pour le Cameroun.\n\nAucune procédure n'est disponible pour le moment. Veuillez réessayer plus tard.";
      }
      return """Je suis Civio, votre assistant administratif pour le Cameroun.

Je peux vous aider avec les procédures suivantes :
${_procedures.map((p) => "• ${p.title}").join('\n')}

Pour obtenir des informations détaillées, veuillez sélectionner une procédure depuis la page d'accueil.""";
    }

    final buffer = StringBuffer();
    buffer.writeln('**${matchedProcedure.title}**');
    buffer.writeln();
    buffer.writeln(matchedProcedure.description);
    buffer.writeln();

    if (matchedProcedure.documents.isNotEmpty) {
      buffer.writeln('**Documents nécessaires :**');
      for (final doc in matchedProcedure.documents) {
        buffer.writeln('• $doc');
      }
      buffer.writeln();
    }

    if (matchedProcedure.steps.isNotEmpty) {
      buffer.writeln('**Étapes principales :**');
      for (var i = 0; i < matchedProcedure.steps.length; i++) {
        final step = matchedProcedure.steps[i];
        buffer.writeln('${i + 1}. ${step.title}');
        if (step.cost != '0 FCFA') {
          buffer.writeln('   Coût: ${step.cost}');
        }
        buffer.writeln('   Durée: ${step.time}');
      }
    }

    return buffer.toString();
  }

  Future<Procedure?> getProcedureById(String id) async {
    await _init();
    try {
      return _procedures.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Procedure>> getAllProcedures() async {
    await _init();
    return _procedures;
  }
}
