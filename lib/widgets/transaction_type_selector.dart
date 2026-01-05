import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../constants/app_colors.dart';

class TransactionTypeSelector extends StatelessWidget {
  final TransactionType selectedType;
  final Function(TransactionType) onTypeSelected;

  const TransactionTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TypeButton(
            type: TransactionType.income,
            label: 'Income',
            icon: Icons.arrow_downward,
            color: AppColors.secondary,
            isSelected: selectedType == TransactionType.income,
            onTap: () => onTypeSelected(TransactionType.income),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _TypeButton(
            type: TransactionType.expense,
            label: 'Expense',
            icon: Icons.arrow_upward,
            color: Colors.red,
            isSelected: selectedType == TransactionType.expense,
            onTap: () => onTypeSelected(TransactionType.expense),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _TypeButton(
            type: TransactionType.transfer,
            label: 'Transfer',
            icon: Icons.swap_horiz,
            color: Colors.blue,
            isSelected: selectedType == TransactionType.transfer,
            onTap: () => onTypeSelected(TransactionType.transfer),
          ),
        ),
      ],
    );
  }
}

class _TypeButton extends StatelessWidget {
  final TransactionType type;
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.type,
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

