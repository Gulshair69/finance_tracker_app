import 'package:flutter/material.dart';
import '../services/firebase_services.dart';

class UserProfileProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  double? _initialBalance;
  bool _isLoading = false;
  String? _error;
  bool _hasProfile = false;

  double? get initialBalance => _initialBalance;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasProfile => _hasProfile;

  // Check if user has profile
  Future<void> checkUserProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      _hasProfile = await _firebaseService.hasUserProfile();
      if (_hasProfile) {
        final profile = await _firebaseService.getUserProfile();
        if (profile != null) {
          _initialBalance = (profile['initialBalance'] ?? 0).toDouble();
        }
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set initial balance
  Future<bool> setInitialBalance(double amount) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firebaseService.setInitialBalance(amount);
      _initialBalance = amount;
      _hasProfile = true;
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

  // Update initial balance
  Future<bool> updateInitialBalance(double amount) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firebaseService.updateInitialBalance(amount);
      _initialBalance = amount;
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

