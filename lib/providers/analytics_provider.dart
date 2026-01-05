import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import 'transaction_provider.dart';

class AnalyticsProvider extends ChangeNotifier {
  TransactionProvider? _transactionProvider;

  void setTransactionProvider(TransactionProvider provider) {
    _transactionProvider?.removeListener(notifyListeners);
    _transactionProvider = provider;
    _transactionProvider?.addListener(notifyListeners);
  }

  TransactionProvider? get transactionProvider => _transactionProvider;

  @override
  void dispose() {
    _transactionProvider?.removeListener(notifyListeners);
    super.dispose();
  }

  // Get monthly income/expense data for chart
  Map<String, Map<String, double>> getMonthlyData({int months = 6}) {
    if (_transactionProvider == null) return {};
    final now = DateTime.now();
    final data = <String, Map<String, double>>{};

    for (int i = months - 1; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      
      final startDate = DateTime(date.year, date.month, 1);
      final endDate = DateTime(date.year, date.month + 1, 0, 23, 59, 59);

      final income = _transactionProvider!.getTotalIncome(
        startDate: startDate,
        endDate: endDate,
      );
      final expense = _transactionProvider!.getTotalExpenses(
        startDate: startDate,
        endDate: endDate,
      );

      data[monthKey] = {
        'income': income,
        'expense': expense,
      };
    }

    return data;
  }

  // Get category breakdown for pie chart
  Map<String, double> getCategoryBreakdown({TransactionType? type}) {
    if (_transactionProvider == null) return {};
    return _transactionProvider!.getTransactionsByCategory(type: type);
  }

  // Get top spending categories
  List<MapEntry<String, double>> getTopCategories({int limit = 5}) {
    if (_transactionProvider == null) return [];
    final breakdown = getCategoryBreakdown(type: TransactionType.expense);
    final sorted = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).toList();
  }

  // Get spending trend (daily for last 30 days)
  Map<DateTime, double> getDailySpendingTrend({int days = 30}) {
    if (_transactionProvider == null) return {};
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    final trend = <DateTime, double>{};

    final transactions = _transactionProvider!.getFilteredTransactions(
      type: TransactionType.expense,
      startDate: startDate,
      endDate: now,
    );

    for (var tx in transactions) {
      final date = DateTime(tx.date.year, tx.date.month, tx.date.day);
      trend[date] = (trend[date] ?? 0.0) + tx.amount;
    }

    return trend;
  }

  // Calculate savings rate
  double getSavingsRate({DateTime? startDate, DateTime? endDate}) {
    if (_transactionProvider == null) return 0.0;
    final income = _transactionProvider!.getTotalIncome(
      startDate: startDate,
      endDate: endDate,
    );
    final expense = _transactionProvider!.getTotalExpenses(
      startDate: startDate,
      endDate: endDate,
    );

    if (income == 0) return 0.0;
    return ((income - expense) / income * 100).clamp(0.0, 100.0);
  }

  // Get average daily spending
  double getAverageDailySpending({int days = 30}) {
    if (_transactionProvider == null) return 0.0;
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    final expense = _transactionProvider!.getTotalExpenses(
      startDate: startDate,
      endDate: now,
    );
    return expense / days;
  }
}

