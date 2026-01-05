import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/firebase_services.dart';
import 'package:uuid/uuid.dart';

class TransactionProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final Uuid _uuid = const Uuid();

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _error;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize and listen to transactions
  void initializeTransactions() {
    _firebaseService.getTransactionsStream().listen(
      (transactions) {
        _transactions = transactions;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  // Get transactions with filters
  Future<void> loadTransactions({
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
    String? category,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transactions = await _firebaseService.getTransactions(
        startDate: startDate,
        endDate: endDate,
        type: type,
        category: category,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add transaction
  Future<bool> addTransaction(TransactionModel transaction) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firebaseService.addTransaction(transaction);
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

  // Update transaction
  Future<bool> updateTransaction(TransactionModel transaction) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firebaseService.updateTransaction(transaction);
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

  // Delete transaction
  Future<bool> removeTransaction(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firebaseService.deleteTransaction(id);
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

  // Get filtered transactions
  List<TransactionModel> getFilteredTransactions({
    TransactionType? type,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    var filtered = _transactions;

    if (type != null) {
      filtered = filtered.where((tx) => tx.type == type).toList();
    }

    if (category != null) {
      filtered = filtered.where((tx) => tx.category == category).toList();
    }

    if (startDate != null) {
      filtered = filtered.where((tx) => tx.date.isAfter(startDate) || tx.date.isAtSameMomentAs(startDate)).toList();
    }

    if (endDate != null) {
      filtered = filtered.where((tx) => tx.date.isBefore(endDate) || tx.date.isAtSameMomentAs(endDate)).toList();
    }

    return filtered;
  }

  // Calculate total balance
  double getTotalBalance() {
    double balance = 0.0;
    for (var tx in _transactions) {
      if (tx.type == TransactionType.income) {
        balance += tx.amount;
      } else if (tx.type == TransactionType.expense) {
        balance -= tx.amount;
      }
      // Transfer doesn't affect balance
    }
    return balance;
  }

  // Calculate total income
  double getTotalIncome({DateTime? startDate, DateTime? endDate}) {
    var filtered = getFilteredTransactions(
      type: TransactionType.income,
      startDate: startDate,
      endDate: endDate,
    );
    return filtered.fold(0.0, (sum, tx) => sum + tx.amount);
  }

  // Calculate total expenses
  double getTotalExpenses({DateTime? startDate, DateTime? endDate}) {
    var filtered = getFilteredTransactions(
      type: TransactionType.expense,
      startDate: startDate,
      endDate: endDate,
    );
    return filtered.fold(0.0, (sum, tx) => sum + tx.amount);
  }

  // Get transactions by category
  Map<String, double> getTransactionsByCategory({TransactionType? type}) {
    var filtered = type != null
        ? _transactions.where((tx) => tx.type == type).toList()
        : _transactions;

    Map<String, double> categoryMap = {};
    for (var tx in filtered) {
      categoryMap[tx.category] = (categoryMap[tx.category] ?? 0.0) + tx.amount;
    }
    return categoryMap;
  }
}
