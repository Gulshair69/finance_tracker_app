import 'package:flutter/material.dart';
import '../models/budget_model.dart';
import '../models/transaction_model.dart';
import '../services/firebase_services.dart';
import 'package:uuid/uuid.dart';

class BudgetProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final Uuid _uuid = const Uuid();

  List<BudgetModel> _budgets = [];
  bool _isLoading = false;
  String? _error;

  List<BudgetModel> get budgets => _budgets;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize and listen to budgets
  void initializeBudgets() {
    _firebaseService.getBudgetsStream().listen(
      (budgets) {
        _budgets = budgets;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  // Load budgets (one-time)
  Future<void> loadBudgets() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _budgets = await _firebaseService.getBudgets();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add budget
  Future<bool> addBudget(BudgetModel budget) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firebaseService.addBudget(budget);
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

  // Update budget
  Future<bool> updateBudget(BudgetModel budget) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firebaseService.updateBudget(budget);
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

  // Delete budget
  Future<bool> deleteBudget(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firebaseService.deleteBudget(id);
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

  // Calculate spent amount for a budget
  double calculateSpent(BudgetModel budget, List<TransactionModel> transactions) {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    if (budget.period == BudgetPeriod.monthly) {
      startDate = DateTime(now.year, now.month, 1);
      endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    } else {
      // Weekly
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      startDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
      endDate = startDate.add(Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    }

    final filtered = transactions.where((tx) {
      return tx.type == TransactionType.expense &&
          tx.category == budget.category &&
          tx.date.isAfter(startDate.subtract(Duration(days: 1))) &&
          tx.date.isBefore(endDate.add(Duration(days: 1)));
    }).toList();

    return filtered.fold(0.0, (sum, tx) => sum + tx.amount);
  }

  // Get budget progress (0.0 to 1.0)
  double getBudgetProgress(BudgetModel budget, List<TransactionModel> transactions) {
    final spent = calculateSpent(budget, transactions);
    return budget.amount > 0 ? (spent / budget.amount).clamp(0.0, 1.0) : 0.0;
  }

  // Check if budget is exceeded
  bool isBudgetExceeded(BudgetModel budget, List<TransactionModel> transactions) {
    final spent = calculateSpent(budget, transactions);
    return spent > budget.amount;
  }
}

