import 'package:flutter/material.dart';
import '../models/quiz_model.dart';
import '../services/quiz_service.dart';

class QuizProvider with ChangeNotifier {
  final QuizService _service = QuizService();

  bool _isLoadingArena = false;
  QuizArenaDataModel? _arenaData;
  String? _arenaError;

  bool get isLoadingArena => _isLoadingArena;
  QuizArenaDataModel? get arenaData => _arenaData;
  String? get arenaError => _arenaError;

  // Active Quiz Playing State
  QuizDeckModel? _currentDeck;
  int _currentQuestionIndex = 0;
  final Map<int, int> _selectedAnswers = {}; // questionId -> optionIndex
  bool _isSubmitting = false;
  num? _finalScore;
  int? _xpEarned;
  bool _leveledUp = false;

  QuizDeckModel? get currentDeck => _currentDeck;
  int get currentQuestionIndex => _currentQuestionIndex;
  Map<int, int> get selectedAnswers => _selectedAnswers;
  bool get isSubmitting => _isSubmitting;
  num? get finalScore => _finalScore;
  int? get xpEarned => _xpEarned;
  bool get leveledUp => _leveledUp;

  Future<void> fetchQuizArena() async {
    _isLoadingArena = true;
    _arenaError = null;
    notifyListeners();

    try {
      _arenaData = await _service.getQuizArena();
    } catch (e) {
      _arenaError = e.toString();
    } finally {
      _isLoadingArena = false;
      notifyListeners();
    }
  }

  void startQuiz(QuizDeckModel deck) {
    _currentDeck = deck;
    _currentQuestionIndex = 0;
    _selectedAnswers.clear();
    _finalScore = null;
    _xpEarned = null;
    _leveledUp = false;
    notifyListeners();
  }

  void selectAnswer(int questionId, int optionIndex) {
    _selectedAnswers[questionId] = optionIndex;
    notifyListeners();
  }

  void nextQuestion() {
    if (_currentDeck != null && _currentQuestionIndex < _currentDeck!.questions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  Future<bool> submitQuiz() async {
    if (_currentDeck == null) return false;
    _isSubmitting = true;
    notifyListeners();

    try {
      final result = await _service.attemptQuiz(_currentDeck!.id, _selectedAnswers);
      _finalScore = result.score;
      _xpEarned = result.xpEarned;
      _leveledUp = result.leveledUp;
      await fetchQuizArena(); // refresh gamification XP
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (_) {
      // Fallback local calculation if backend offline
      int correct = 0;
      for (final q in _currentDeck!.questions) {
        if (_selectedAnswers[q.id] == q.correctIndex) {
          correct++;
        }
      }
      final calculated = _currentDeck!.questions.isNotEmpty
          ? ((correct / _currentDeck!.questions.length) * 100).round()
          : 80;
      _finalScore = calculated;
      _xpEarned = 20;
      _isSubmitting = false;
      notifyListeners();
      return true;
    }
  }
}
