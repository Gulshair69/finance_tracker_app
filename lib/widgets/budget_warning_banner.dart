import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class BudgetWarningBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onTap;

  const BudgetWarningBanner({super.key, required this.message, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300, width: 2),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Budget Alert",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(fontSize: 14, color: Colors.orange.shade800),
                ),
              ],
            ),
          ),
          if (onTap != null)
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.budget);
              },
              child: Text(
                "Add Amount",
                style: TextStyle(
                  color: Colors.orange.shade900,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
