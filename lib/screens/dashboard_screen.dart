import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/goal_provider.dart';
import '../providers/user_profile_provider.dart';
import '../widgets/transaction_card.dart';
import '../widgets/summary_card.dart';
import '../widgets/budget_card.dart';
import '../widgets/goal_card.dart';
import '../widgets/budget_warning_banner.dart';
import '../routes/app_routes.dart';

class DashboardScreen extends StatefulWidget {
  static const String routeName = '/dashboard';

  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final transactionProvider = Provider.of<TransactionProvider>(
        context,
        listen: false,
      );
      final categoryProvider = Provider.of<CategoryProvider>(
        context,
        listen: false,
      );
      final budgetProvider = Provider.of<BudgetProvider>(
        context,
        listen: false,
      );
      final goalProvider = Provider.of<GoalProvider>(context, listen: false);
      final userProfileProvider = Provider.of<UserProfileProvider>(
        context,
        listen: false,
      );

      transactionProvider.initializeTransactions();
      categoryProvider.initializeCategories();
      budgetProvider.initializeBudgets();
      goalProvider.initializeGoals();
      userProfileProvider.checkUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final goalProvider = Provider.of<GoalProvider>(context);
    final userProfileProvider = Provider.of<UserProfileProvider>(context);

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    // Calculate balance including initial balance
    final initialBalance = userProfileProvider.initialBalance ?? 0.0;
    final totalBalance = initialBalance + transactionProvider.getTotalBalance();
    final monthlyIncome = transactionProvider.getTotalIncome(
      startDate: startOfMonth,
      endDate: endOfMonth,
    );
    final monthlyExpense = transactionProvider.getTotalExpenses(
      startDate: startOfMonth,
      endDate: endOfMonth,
    );
    final savings = monthlyIncome - monthlyExpense;

    // Check for budget warnings
    final exceededBudgets = budgetProvider.budgets.where((budget) {
      final spent = budgetProvider.calculateSpent(
        budget,
        transactionProvider.transactions,
      );
      return spent > budget.amount;
    }).toList();

    final lowBalance = totalBalance < 0;

    final recentTransactions = transactionProvider.transactions
        .take(5)
        .toList();
    final activeBudgets = budgetProvider.budgets.take(3).toList();
    final activeGoals = goalProvider.getActiveGoals().take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await transactionProvider.loadTransactions();
          await budgetProvider.loadBudgets();
          await goalProvider.loadGoals();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Budget Warning Banner
              if (lowBalance)
                BudgetWarningBanner(
                  message:
                      "Your balance is negative! Please add amount to your budget.",
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.budget);
                  },
                ),
              if (exceededBudgets.isNotEmpty && !lowBalance)
                BudgetWarningBanner(
                  message:
                      "Your budget is low! Please add amount to your budget.",
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.budget);
                  },
                ),
              // Summary Cards
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: SummaryCard(
                            title: "Total Balance",
                            amount: '\$${totalBalance.toStringAsFixed(2)}',
                            icon: Icons.account_balance_wallet,
                            color: AppColors.primary,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SummaryCard(
                            title: "This Month Income",
                            amount: '\$${monthlyIncome.toStringAsFixed(2)}',
                            icon: Icons.arrow_downward,
                            color: AppColors.secondary,
                            backgroundColor: AppColors.secondary.withOpacity(
                              0.1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SummaryCard(
                            title: "This Month Expense",
                            amount: '\$${monthlyExpense.toStringAsFixed(2)}',
                            icon: Icons.arrow_upward,
                            color: Colors.red,
                            backgroundColor: Colors.red.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SummaryCard(
                            title: "Savings",
                            amount: '\$${savings.toStringAsFixed(2)}',
                            icon: Icons.savings,
                            color: savings >= 0
                                ? AppColors.secondary
                                : Colors.red,
                            backgroundColor:
                                (savings >= 0
                                        ? AppColors.secondary
                                        : Colors.red)
                                    .withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Quick Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Add Transaction'),
                                content: const Text(
                                    'You are about to add a new transaction. Continue?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.addTransaction,
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                    ),
                                    child: const Text('Continue'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Transaction'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.analytics);
                        },
                        icon: const Icon(Icons.analytics),
                        label: const Text('Analytics'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Active Budgets
              if (activeBudgets.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Active Budgets",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.budget);
                        },
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                ),
                ...activeBudgets.map((budget) {
                  final spent = budgetProvider.calculateSpent(
                    budget,
                    transactionProvider.transactions,
                  );
                  return BudgetCard(
                    budget: budget,
                    spent: spent,
                    onDelete: () {
                      budgetProvider.deleteBudget(budget.id);
                    },
                  );
                }),
              ],

              // Active Goals
              if (activeGoals.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Active Goals",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.goals);
                        },
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                ),
                ...activeGoals.map(
                  (goal) => GoalCard(
                    goal: goal,
                    onDelete: () {
                      goalProvider.deleteGoal(goal.id);
                    },
                  ),
                ),
              ],

              // Recent Transactions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Recent Transactions",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.history);
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ),
              if (recentTransactions.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(
                    child: Text(
                      "No transactions yet. Add your first transaction!",
                    ),
                  ),
                )
              else
                ...recentTransactions.map(
                  (tx) => TransactionCard(
                    transaction: tx,
                    onDelete: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Delete Transaction'),
                            content: Text(
                              'Are you sure you want to delete this transaction?\n\n'
                              'Title: ${tx.title}\n'
                              'Amount: \$${tx.amount.toStringAsFixed(2)}\n'
                              'Type: ${tx.type.name}',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  final success =
                                      await transactionProvider.removeTransaction(
                                    tx.id,
                                  );
                                  if (mounted) {
                                    if (success) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Transaction deleted successfully'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Error: ${transactionProvider.error}'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Add Transaction'),
                content: const Text(
                    'You are about to add a new transaction. Continue?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, AppRoutes.addTransaction);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('Continue'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacementNamed(context, AppRoutes.analytics);
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, AppRoutes.profile);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
