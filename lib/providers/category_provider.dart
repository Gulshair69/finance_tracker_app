import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../services/firebase_services.dart';
import 'package:uuid/uuid.dart';

class CategoryProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final Uuid _uuid = const Uuid();

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _error;
  bool _initialized = false;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize categories and set up listener
  Future<void> initializeCategories() async {
    if (_initialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Initialize default categories if needed
      await _firebaseService.initializeDefaultCategories();

      // Set up real-time listener
      _firebaseService.getCategoriesStream().listen(
        (categories) {
          _categories = categories;
          _error = null;
          _isLoading = false;
          _initialized = true;
          notifyListeners();
        },
        onError: (error) {
          _error = error.toString();
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load categories (one-time)
  Future<void> loadCategories({TransactionType? type}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Initialize defaults if first time
      if (!_initialized) {
        await _firebaseService.initializeDefaultCategories();
      }

      _categories = await _firebaseService.getCategories(type: type);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get categories by type
  List<CategoryModel> getCategoriesByType(TransactionType type) {
    return _categories.where((cat) => cat.type == type).toList();
  }

  // Get category by ID
  CategoryModel? getCategoryById(String id) {
    try {
      return _categories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  // Add category
  Future<bool> addCategory(CategoryModel category) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firebaseService.addCategory(category);
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

  // Update category
  Future<bool> updateCategory(CategoryModel category) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firebaseService.updateCategory(category);
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

  // Delete category
  Future<bool> deleteCategory(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firebaseService.deleteCategory(id);
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
}

