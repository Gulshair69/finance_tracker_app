// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_card.dart';
import '../models/transaction_model.dart';

class HistoryScreen extends StatefulWidget {
  static const String routeName = '/history';

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  TransactionType? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);

    final filteredTransactions = _selectedFilter != null
        ? transactionProvider.getFilteredTransactions(type: _selectedFilter)
        : transactionProvider.transactions;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction History"),
        backgroundColor: AppColors.primary,
        actions: [
          PopupMenuButton<TransactionType?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text("All"),
              ),
              const PopupMenuItem(
                value: TransactionType.income,
                child: Text("Income"),
              ),
              const PopupMenuItem(
                value: TransactionType.expense,
                child: Text("Expense"),
              ),
              const PopupMenuItem(
                value: TransactionType.transfer,
                child: Text("Transfer"),
              ),
            ],
          ),
        ],
      ),
      body: filteredTransactions.isEmpty
          ? const Center(
              child: Text("No transactions found."),
            )
          : ListView.builder(
              itemCount: filteredTransactions.length,
              itemBuilder: (context, index) {
                final tx = filteredTransactions[index];
                return TransactionCard(
                  transaction: tx,
                  onDelete: () {
                    transactionProvider.removeTransaction(tx.id);
                  },
                );
              },
            ),
    );
  }
}
