import 'package:flutter/foundation.dart';
import '../../domain/entities/procedure.dart';
import '../../data/repositories/procedure_repository.dart';

enum ChatState { idle, searching, talking, completed }

class ProcedureProvider with ChangeNotifier {
  final IProcedureRepository _repository;

  ProcedureProvider({IProcedureRepository? repository})
      : _repository = repository ?? ProcedureRepository();
  
  List<Procedure> _procedures = [];
  List<Procedure> _searchResults = [];
  Procedure? _selectedProcedure;
  
  ChatState _state = ChatState.idle;
  int _currentQuestionIndex = 0;
  Map<String, String> _userAnswers = {};
  
  List<Procedure> get procedures => _procedures;
  List<Procedure> get searchResults => _searchResults;
  Procedure? get selectedProcedure => _selectedProcedure;
  ChatState get state => _state;
  int get currentQuestionIndex => _currentQuestionIndex;
  
  Future<void> init() async {
    _procedures = await _repository.getProcedures();
    _searchResults = _procedures;
    notifyListeners();
  }

  void search(String query) async {
    _searchResults = await _repository.searchProcedures(query);
    notifyListeners();
  }

  void selectProcedure(Procedure procedure) {
    _selectedProcedure = procedure;
    _state = ChatState.talking;
    _currentQuestionIndex = 0;
    _userAnswers = {};
    notifyListeners();
  }

  void answerQuestion(String answer) {
    if (_selectedProcedure == null) return;
    
    final currentQuestion = _selectedProcedure!.questions[_currentQuestionIndex];
    _userAnswers[currentQuestion.id] = answer;
    
    if (_currentQuestionIndex < _selectedProcedure!.questions.length - 1) {
      _currentQuestionIndex++;
    } else {
      _state = ChatState.completed;
    }
    notifyListeners();
  }

  double get progress {
    if (_selectedProcedure == null) return 0;
    if (_state == ChatState.completed) return 1.0;
    return (_currentQuestionIndex) / _selectedProcedure!.questions.length;
  }

  void reset() {
    _state = ChatState.idle;
    _selectedProcedure = null;
    _currentQuestionIndex = 0;
    _userAnswers = {};
    notifyListeners();
  }
}
