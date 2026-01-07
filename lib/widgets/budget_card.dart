import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/budget_model.dart';

class BudgetCard extends StatelessWidget {
  final BudgetModel budget;
  final double spent;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const BudgetCard({
    super.key,
    required this.budget,
    required this.spent,
    this.onTap,
    this.onDelete,
  });

  double get progress => budget.amount > 0 ? (spent / budget.amount).clamp(0.0, 1.0) : 0.0;
  bool get isExceeded => spent > budget.amount;
  double get remaining => (budget.amount - spent).clamp(0.0, budget.amount);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          budget.category,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${budget.period.name.toUpperCase()} Budget',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: onDelete,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Spent: \$${spent.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: isExceeded ? Colors.red : AppColors.text,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Budget: \$${budget.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isExceeded ? AppColors.brightRed : AppColors.primary,
                ),
                minHeight: 8,
              ),
              const SizedBox(height: 4),
              Text(
                isExceeded
                    ? 'Exceeded by \$${(-remaining).toStringAsFixed(2)}'
                    : 'Remaining: \$${remaining.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12,
                  color: isExceeded ? Colors.red : AppColors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

