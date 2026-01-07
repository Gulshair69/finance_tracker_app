import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/transaction_model.dart';

class CategoryProvider extends ChangeNotifier {
  static const String _expenseCategoriesKey = 'expense_categories';
  static const String _incomeCategoriesKey = 'income_categories';

  List<String> _expenseCategories = [];
  List<String> _incomeCategories = [];
  bool _isLoading = false;
  String? _error;

  List<String> get expenseCategories => _expenseCategories;
  List<String> get incomeCategories => _incomeCategories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CategoryProvider() {
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load expense categories
      final expenseJson = prefs.getString(_expenseCategoriesKey);
      if (expenseJson != null) {
        _expenseCategories = List<String>.from(json.decode(expenseJson));
      } else {
        // Initialize with default expense categories
        _expenseCategories = [
          'Food',
          'Transport',
          'Shopping',
          'Bills',
          'Entertainment',
          'Health',
          'Education',
          'Other'
        ];
        await _saveCategories();
      }

      // Load income categories
      final incomeJson = prefs.getString(_incomeCategoriesKey);
      if (incomeJson != null) {
        _incomeCategories = List<String>.from(json.decode(incomeJson));
      } else {
        // Initialize with default income categories
        _incomeCategories = [
          'Salary',
          'Business',
          'Investment',
          'Gift',
          'Other'
        ];
        await _saveCategories();
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_expenseCategoriesKey, json.encode(_expenseCategories));
      await prefs.setString(_incomeCategoriesKey, json.encode(_incomeCategories));
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  List<String> getCategoriesByType(TransactionType type) {
    return type == TransactionType.expense ? _expenseCategories : _incomeCategories;
  }

  Future<bool> addCategory(String category, TransactionType type) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (type == TransactionType.expense) {
        if (!_expenseCategories.contains(category)) {
          _expenseCategories.add(category);
          _expenseCategories.sort();
        }
      } else {
        if (!_incomeCategories.contains(category)) {
          _incomeCategories.add(category);
          _incomeCategories.sort();
        }
      }

      await _saveCategories();
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

  Future<bool> deleteCategory(String category, TransactionType type) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (type == TransactionType.expense) {
        _expenseCategories.remove(category);
      } else {
        _incomeCategories.remove(category);
      }

      await _saveCategories();
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

  Future<void> loadCategories({TransactionType? type}) async {
    await _loadCategories();
  }

  Future<void> initializeCategories() async {
    await _loadCategories();
  }
}

