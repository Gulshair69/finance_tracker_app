import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/budget_model.dart';
import '../models/goal_model.dart';
import '../models/recurring_transaction_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // ==================== TRANSACTION OPERATIONS ====================

  // Add transaction
  Future<String> addTransaction(TransactionModel transaction) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final transactionRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc(transaction.id);

      await transactionRef.set(transaction.toMap());
      return transaction.id;
    } catch (e) {
      throw Exception('Error adding transaction: $e');
    }
  }

  // Get transactions stream (real-time)
  Stream<List<TransactionModel>> getTransactionsStream({
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
    String? category,
  }) {
    final userId = currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    Query query = _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .orderBy('date', descending: true);

    if (startDate != null) {
      query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (endDate != null) {
      query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }
    if (type != null) {
      query = query.where('type', isEqualTo: type.name);
    }
    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get transactions (one-time)
  Future<List<TransactionModel>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
    String? category,
  }) async {
    final userId = currentUserId;
    if (userId == null) return [];

    try {
      Query query = _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .orderBy('date', descending: true);

      if (startDate != null) {
        query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }
      if (type != null) {
        query = query.where('type', isEqualTo: type.name);
      }
      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error getting transactions: $e');
    }
  }

  // Update transaction
  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc(transaction.id)
          .update(transaction.toMap());
    } catch (e) {
      throw Exception('Error updating transaction: $e');
    }
  }

  // Delete transaction
  Future<void> deleteTransaction(String transactionId) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc(transactionId)
          .delete();
    } catch (e) {
      throw Exception('Error deleting transaction: $e');
    }
  }

  // ==================== CATEGORY OPERATIONS ====================

  // Initialize default categories
  Future<void> initializeDefaultCategories() async {
    final userId = currentUserId;
    if (userId == null) return;

    try {
      // Check if categories already exist
      final categoriesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('categories')
          .get();

      if (categoriesSnapshot.docs.isNotEmpty) {
        return; // Categories already initialized
      }

      // Default expense categories
      final expenseCategories = [
        {'name': 'Food', 'icon': 'restaurant', 'color': 0xFFFF6B6B},
        {'name': 'Transport', 'icon': 'directions_car', 'color': 0xFF4ECDC4},
        {'name': 'Shopping', 'icon': 'shopping_bag', 'color': 0xFFFFE66D},
        {'name': 'Bills', 'icon': 'receipt', 'color': 0xFF95E1D3},
        {'name': 'Entertainment', 'icon': 'movie', 'color': 0xFFAA96DA},
        {'name': 'Health', 'icon': 'favorite', 'color': 0xFFFF6B9D},
        {'name': 'Education', 'icon': 'school', 'color': 0xFFC7CEEA},
        {'name': 'Other', 'icon': 'category', 'color': 0xFFB8B8B8},
      ];

      // Default income categories
      final incomeCategories = [
        {'name': 'Salary', 'icon': 'work', 'color': 0xFF00B894},
        {'name': 'Freelance', 'icon': 'laptop', 'color': 0xFF00CEC9},
        {'name': 'Investment', 'icon': 'trending_up', 'color': 0xFF6C5CE7},
        {'name': 'Gift', 'icon': 'card_giftcard', 'color': 0xFFFFD93D},
        {'name': 'Other', 'icon': 'attach_money', 'color': 0xFF95A5A6},
      ];

      final batch = _firestore.batch();

      // Add expense categories
      for (var cat in expenseCategories) {
        final categoryId = _uuid.v4();
        final categoryRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('categories')
            .doc(categoryId);

        final category = CategoryModel(
          id: categoryId,
          name: cat['name'] as String,
          icon: cat['icon'] as String,
          color: cat['color'] as int,
          type: TransactionType.expense,
          isDefault: true,
          userId: userId,
        );

        batch.set(categoryRef, category.toMap());
      }

      // Add income categories
      for (var cat in incomeCategories) {
        final categoryId = _uuid.v4();
        final categoryRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('categories')
            .doc(categoryId);

        final category = CategoryModel(
          id: categoryId,
          name: cat['name'] as String,
          icon: cat['icon'] as String,
          color: cat['color'] as int,
          type: TransactionType.income,
          isDefault: true,
          userId: userId,
        );

        batch.set(categoryRef, category.toMap());
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Error initializing categories: $e');
    }
  }

  // Get categories stream
  Stream<List<CategoryModel>> getCategoriesStream({TransactionType? type}) {
    final userId = currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    Query query = _firestore
        .collection('users')
        .doc(userId)
        .collection('categories')
        .orderBy('name');

    if (type != null) {
      query = query.where('type', isEqualTo: type.name);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get categories (one-time)
  Future<List<CategoryModel>> getCategories({TransactionType? type}) async {
    final userId = currentUserId;
    if (userId == null) return [];

    try {
      Query query = _firestore
          .collection('users')
          .doc(userId)
          .collection('categories')
          .orderBy('name');

      if (type != null) {
        query = query.where('type', isEqualTo: type.name);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error getting categories: $e');
    }
  }

  // Add category
  Future<String> addCategory(CategoryModel category) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('categories')
          .doc(category.id)
          .set(category.toMap());

      return category.id;
    } catch (e) {
      throw Exception('Error adding category: $e');
    }
  }

  // Update category
  Future<void> updateCategory(CategoryModel category) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('categories')
          .doc(category.id)
          .update(category.toMap());
    } catch (e) {
      throw Exception('Error updating category: $e');
    }
  }

  // Delete category
  Future<void> deleteCategory(String categoryId) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('categories')
          .doc(categoryId)
          .delete();
    } catch (e) {
      throw Exception('Error deleting category: $e');
    }
  }

  // ==================== BUDGET OPERATIONS ====================

  // Add budget
  Future<String> addBudget(BudgetModel budget) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .doc(budget.id)
          .set(budget.toMap());

      return budget.id;
    } catch (e) {
      throw Exception('Error adding budget: $e');
    }
  }

  // Get budgets stream
  Stream<List<BudgetModel>> getBudgetsStream() {
    final userId = currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => BudgetModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get budgets (one-time)
  Future<List<BudgetModel>> getBudgets() async {
    final userId = currentUserId;
    if (userId == null) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .orderBy('startDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => BudgetModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error getting budgets: $e');
    }
  }

  // Update budget
  Future<void> updateBudget(BudgetModel budget) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .doc(budget.id)
          .update(budget.toMap());
    } catch (e) {
      throw Exception('Error updating budget: $e');
    }
  }

  // Delete budget
  Future<void> deleteBudget(String budgetId) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .doc(budgetId)
          .delete();
    } catch (e) {
      throw Exception('Error deleting budget: $e');
    }
  }

  // ==================== GOAL OPERATIONS ====================

  // Add goal
  Future<String> addGoal(GoalModel goal) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('goals')
          .doc(goal.id)
          .set(goal.toMap());

      return goal.id;
    } catch (e) {
      throw Exception('Error adding goal: $e');
    }
  }

  // Get goals stream
  Stream<List<GoalModel>> getGoalsStream() {
    final userId = currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('goals')
        .orderBy('deadline')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => GoalModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get goals (one-time)
  Future<List<GoalModel>> getGoals() async {
    final userId = currentUserId;
    if (userId == null) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('goals')
          .orderBy('deadline')
          .get();

      return snapshot.docs
          .map((doc) => GoalModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error getting goals: $e');
    }
  }

  // Update goal
  Future<void> updateGoal(GoalModel goal) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('goals')
          .doc(goal.id)
          .update(goal.toMap());
    } catch (e) {
      throw Exception('Error updating goal: $e');
    }
  }

  // Delete goal
  Future<void> deleteGoal(String goalId) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('goals')
          .doc(goalId)
          .delete();
    } catch (e) {
      throw Exception('Error deleting goal: $e');
    }
  }

  // ==================== RECURRING TRANSACTION OPERATIONS ====================

  // Add recurring transaction
  Future<String> addRecurringTransaction(RecurringTransactionModel recurring) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('recurringTransactions')
          .doc(recurring.id)
          .set(recurring.toMap());

      return recurring.id;
    } catch (e) {
      throw Exception('Error adding recurring transaction: $e');
    }
  }

  // Get recurring transactions stream
  Stream<List<RecurringTransactionModel>> getRecurringTransactionsStream() {
    final userId = currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('recurringTransactions')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RecurringTransactionModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get recurring transactions (one-time)
  Future<List<RecurringTransactionModel>> getRecurringTransactions() async {
    final userId = currentUserId;
    if (userId == null) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('recurringTransactions')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => RecurringTransactionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error getting recurring transactions: $e');
    }
  }

  // Update recurring transaction
  Future<void> updateRecurringTransaction(RecurringTransactionModel recurring) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('recurringTransactions')
          .doc(recurring.id)
          .update(recurring.toMap());
    } catch (e) {
      throw Exception('Error updating recurring transaction: $e');
    }
  }

  // Delete recurring transaction
  Future<void> deleteRecurringTransaction(String recurringId) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('recurringTransactions')
          .doc(recurringId)
          .delete();
    } catch (e) {
      throw Exception('Error deleting recurring transaction: $e');
    }
  }

  // ==================== USER PROFILE OPERATIONS ====================

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final userId = currentUserId;
      if (userId == null) return null;

      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      throw Exception('Error getting user profile: $e');
    }
  }

  // Set initial balance
  Future<void> setInitialBalance(double amount) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      await _firestore.collection('users').doc(userId).set({
        'userId': userId,
        'initialBalance': amount,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Error setting initial balance: $e');
    }
  }

  // Update initial balance
  Future<void> updateInitialBalance(double amount) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      await _firestore.collection('users').doc(userId).update({
        'initialBalance': amount,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Error updating initial balance: $e');
    }
  }

  // Check if user profile exists
  Future<bool> hasUserProfile() async {
    try {
      final userId = currentUserId;
      if (userId == null) return false;

      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.exists && doc.data()?['initialBalance'] != null;
    } catch (e) {
      return false;
    }
  }
}

