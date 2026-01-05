import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class RecurringTransactionsScreen extends StatefulWidget {
  static const String routeName = '/recurringTransactions';

  const RecurringTransactionsScreen({super.key});

  @override
  State<RecurringTransactionsScreen> createState() =>
      _RecurringTransactionsScreenState();
}

class _RecurringTransactionsScreenState
    extends State<RecurringTransactionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recurring Transactions"),
        backgroundColor: AppColors.primary,
      ),
      body: const Center(
        child: Text("Recurring Transactions feature coming soon"),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          // TODO: Implement add recurring transaction
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
