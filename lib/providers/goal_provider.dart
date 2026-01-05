import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import '../services/firebase_services.dart';
import 'package:uuid/uuid.dart';

class GoalProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final Uuid _uuid = const Uuid();

  List<GoalModel> _goals = [];
  bool _isLoading = false;
  String? _error;

  List<GoalModel> get goals => _goals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize and listen to goals
  void initializeGoals() {
    _firebaseService.getGoalsStream().listen(
      (goals) {
        _goals = goals;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  // Load goals (one-time)
  Future<void> loadGoals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _goals = await _firebaseService.getGoals();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add goal
  Future<bool> addGoal(GoalModel goal) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firebaseService.addGoal(goal);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update goal
  Future<bool> updateGoal(GoalModel goal) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firebaseService.updateGoal(goal);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete goal
  Future<bool> deleteGoal(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firebaseService.deleteGoal(id);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add contribution to goal
  Future<bool> addContribution(String goalId, double amount) async {
    try {
      final goal = _goals.firstWhere((g) => g.id == goalId);
      final updatedGoal = goal.copyWith(
        currentAmount: goal.currentAmount + amount,
      );
      return await updateGoal(updatedGoal);
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  // Get active goals
  List<GoalModel> getActiveGoals() {
    final now = DateTime.now();
    return _goals.where((goal) => !goal.isCompleted && goal.deadline.isAfter(now)).toList();
  }

  // Get completed goals
  List<GoalModel> getCompletedGoals() {
    return _goals.where((goal) => goal.isCompleted).toList();
  }
}

