import 'package:flutter_test/flutter_test.dart';
import 'package:ekema/domain/entities/procedure.dart';
import 'package:ekema/presentation/providers/procedure_provider.dart';

void main() {
  group('Procedure Logic Tests', () {
    test('Procedure JSON parsing', () {
      final json = {
        "id": "test-id",
        "category": "Test Cat",
        "title": "Test Title",
        "description": "Test Desc",
        "questions": [
          {"id": "q1", "text": "Q1 Text", "options": ["Option 1", "Option 2"]}
        ],
        "documents": ["Doc 1"],
        "steps": [
          {"title": "Step 1", "description": "Step 1 Desc", "cost": "1000", "time": "1 день"}
        ],
        "locations": [
          {"name": "Loc 1", "lat": 1.23, "lon": 4.56, "address": "Addr 1", "phone": "123"}
        ]
      };

      final procedure = Procedure.fromJson(json);
      expect(procedure.id, "test-id");
      expect(procedure.questions.length, 1);
      expect(procedure.steps.first.cost, "1000");
    });

    test('ProcedureProvider state transition', () {
      final provider = ProcedureProvider();
      final procedure = Procedure(
        id: "id",
        category: "cat",
        title: "title",
        description: "desc",
        questions: [
          Question(id: "q1", text: "Q1", options: ["O1", "O2"]),
          Question(id: "q2", text: "Q2", options: ["O3", "O4"]),
        ],
        documents: [],
        steps: [],
        locations: [],
      );

      provider.selectProcedure(procedure);
      expect(provider.state, ChatState.talking);
      expect(provider.currentQuestionIndex, 0);

      provider.answerQuestion("O1");
      expect(provider.currentQuestionIndex, 1);
      expect(provider.state, ChatState.talking);

      provider.answerQuestion("O3");
      expect(provider.state, ChatState.completed);
    });
  });
}
