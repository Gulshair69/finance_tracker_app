import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../constants/app_colors.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onDelete;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.onDelete,
  });

  Color _getTypeColor() {
    switch (transaction.type) {
      case TransactionType.income:
        return AppColors.secondary;
      case TransactionType.expense:
        return AppColors.trueRed;
      case TransactionType.transfer:
        return Colors.blue;
    }
  }

  IconData _getTypeIcon() {
    switch (transaction.type) {
      case TransactionType.income:
        return Icons.arrow_downward;
      case TransactionType.expense:
        return Icons.arrow_upward;
      case TransactionType.transfer:
        return Icons.swap_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final color = _getTypeColor();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(_getTypeIcon(), color: color),
        ),
        title: Text(
          transaction.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(transaction.category),
            Text(
              dateFormat.format(transaction.date),
              style: TextStyle(fontSize: 12, color: AppColors.grey),
            ),
            if (transaction.description != null && transaction.description!.isNotEmpty)
              Text(
                transaction.description!,
                style: TextStyle(fontSize: 12, color: AppColors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '\$${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
