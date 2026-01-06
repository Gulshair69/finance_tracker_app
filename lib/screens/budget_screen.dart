import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../constants/app_colors.dart';
import '../providers/budget_provider.dart';
import '../providers/category_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/user_profile_provider.dart';
import '../models/budget_model.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../widgets/budget_card.dart';
import '../widgets/budget_warning_banner.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BudgetScreen extends StatefulWidget {
  static const String routeName = '/budget';

  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final budgetProvider = Provider.of<BudgetProvider>(
        context,
        listen: false,
      );
      final categoryProvider = Provider.of<CategoryProvider>(
        context,
        listen: false,
      );
      budgetProvider.loadBudgets();
      categoryProvider.loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final userProfileProvider = Provider.of<UserProfileProvider>(context);

    // Check for exceeded budgets
    final exceededBudgets = budgetProvider.budgets.where((budget) {
      final spent = budgetProvider.calculateSpent(
        budget,
        transactionProvider.transactions,
      );
      return spent > budget.amount;
    }).toList();

    // Check for low balance
    final initialBalance = userProfileProvider.initialBalance ?? 0.0;
    final totalBalance = initialBalance + transactionProvider.getTotalBalance();
    final lowBalance = totalBalance < 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Budgets"),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          // Warning Banner
          if (lowBalance)
            BudgetWarningBanner(
              message:
                  "Your balance is negative! Please add amount to your budget.",
            ),
          if (exceededBudgets.isNotEmpty && !lowBalance)
            BudgetWarningBanner(
              message: "Your budget is low! Please add amount to your budget.",
            ),
          // Budget List
          Expanded(
            child: budgetProvider.budgets.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.account_balance_wallet,
                          size: 64,
                          color: AppColors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "No budgets yet",
                          style: TextStyle(fontSize: 18, color: AppColors.grey),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => _showAddBudgetDialog(
                            context,
                            budgetProvider,
                            categoryProvider,
                          ),
                          child: const Text("Create Budget"),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: budgetProvider.budgets.length,
                    itemBuilder: (context, index) {
                      final budget = budgetProvider.budgets[index];
                      final spent = budgetProvider.calculateSpent(
                        budget,
                        transactionProvider.transactions,
                      );
                      return BudgetCard(
                        budget: budget,
                        spent: spent,
                        onTap: () => _showEditBudgetDialog(
                          context,
                          budget,
                          budgetProvider,
                          categoryProvider,
                        ),
                        onDelete: () {
                          budgetProvider.deleteBudget(budget.id);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () =>
            _showAddBudgetDialog(context, budgetProvider, categoryProvider),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddBudgetDialog(
    BuildContext context,
    BudgetProvider budgetProvider,
    CategoryProvider categoryProvider,
  ) {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController();
    CategoryModel? selectedCategory;
    BudgetPeriod selectedPeriod = BudgetPeriod.monthly;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final expenseCategories = categoryProvider.getCategoriesByType(
      TransactionType.expense,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Budget"),
        content: StatefulBuilder(
          builder: (context, setState) => Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<CategoryModel>(
                    decoration: const InputDecoration(labelText: "Category"),
                    items: expenseCategories.map((cat) {
                      return DropdownMenuItem<CategoryModel>(
                        value: cat,
                        child: Text(cat.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedCategory = value);
                    },
                    validator: (value) =>
                        value == null ? "Select category" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: "Budget Amount",
                    ),
                    validator: (value) {
                      if (value!.isEmpty) return "Enter amount";
                      if (double.tryParse(value) == null) {
                        return "Enter valid amount";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<BudgetPeriod>(
                    initialValue: selectedPeriod,
                    decoration: const InputDecoration(labelText: "Period"),
                    items: BudgetPeriod.values.map((period) {
                      return DropdownMenuItem<BudgetPeriod>(
                        value: period,
                        child: Text(period.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedPeriod = value!);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate() &&
                  selectedCategory != null) {
                final budget = BudgetModel(
                  id: const Uuid().v4(),
                  category: selectedCategory!.name,
                  amount: double.parse(amountController.text),
                  period: selectedPeriod,
                  startDate: DateTime.now(),
                  userId: user.uid,
                );

                final success = await budgetProvider.addBudget(budget);
                if (success && context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _showEditBudgetDialog(
    BuildContext context,
    BudgetModel budget,
    BudgetProvider budgetProvider,
    CategoryProvider categoryProvider,
  ) {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController(
      text: budget.amount.toString(),
    );
    BudgetPeriod selectedPeriod = budget.period;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Budget"),
        content: StatefulBuilder(
          builder: (context, setState) => Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: "Budget Amount"),
                  validator: (value) {
                    if (value!.isEmpty) return "Enter amount";
                    if (double.tryParse(value) == null) {
                      return "Enter valid amount";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<BudgetPeriod>(
                  initialValue: selectedPeriod,
                  decoration: const InputDecoration(labelText: "Period"),
                  items: BudgetPeriod.values.map((period) {
                    return DropdownMenuItem<BudgetPeriod>(
                      value: period,
                      child: Text(period.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedPeriod = value!);
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final updatedBudget = budget.copyWith(
                  amount: double.parse(amountController.text),
                  period: selectedPeriod,
                );

                final success = await budgetProvider.updateBudget(
                  updatedBudget,
                );
                if (success && context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }
}
