import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/transaction_model.dart';

class BudgetModel {
  final String id;
  final String category;
  final double amount;
  final BudgetPeriod period;

  BudgetModel({
    required this.id,
    required this.category,
    required this.amount,
    required this.period,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'period': period.name,
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] ?? '',
      category: map['category'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      period: BudgetPeriod.values.firstWhere(
        (e) => e.name == map['period'],
        orElse: () => BudgetPeriod.monthly,
      ),
    );
  }

  BudgetModel copyWith({
    String? id,
    String? category,
    double? amount,
    BudgetPeriod? period,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      period: period ?? this.period,
    );
  }
}

enum BudgetPeriod { weekly, monthly }

class BudgetProvider extends ChangeNotifier {
  static const String _budgetsKey = 'budgets';

  List<BudgetModel> _budgets = [];
  bool _isLoading = false;
  String? _error;

  List<BudgetModel> get budgets => _budgets;
  bool get isLoading => _isLoading;
  String? get error => _error;

  BudgetProvider() {
    _loadBudgets();
  }

  Future<void> _loadBudgets() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final budgetsJson = prefs.getString(_budgetsKey);
      
      if (budgetsJson != null) {
        final List<dynamic> budgetsList = json.decode(budgetsJson);
        _budgets = budgetsList.map((b) => BudgetModel.fromMap(b)).toList();
      } else {
        _budgets = [];
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
      _budgets = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveBudgets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final budgetsList = _budgets.map((b) => b.toMap()).toList();
      await prefs.setString(_budgetsKey, json.encode(budgetsList));
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> addBudget(BudgetModel budget) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _budgets.add(budget);
      await _saveBudgets();
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

  Future<bool> updateBudget(BudgetModel budget) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final index = _budgets.indexWhere((b) => b.id == budget.id);
      if (index != -1) {
        _budgets[index] = budget;
        await _saveBudgets();
        _error = null;
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteBudget(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _budgets.removeWhere((b) => b.id == id);
      await _saveBudgets();
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

  Future<void> loadBudgets() async {
    await _loadBudgets();
  }

  void initializeBudgets() {
    _loadBudgets();
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
