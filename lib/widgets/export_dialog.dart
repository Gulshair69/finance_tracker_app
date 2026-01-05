import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ExportDialog extends StatelessWidget {
  final VoidCallback onExportCSV;
  final VoidCallback onExportJSON;

  const ExportDialog({
    super.key,
    required this.onExportCSV,
    required this.onExportJSON,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Export Data'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.table_chart, color: AppColors.primary),
            title: const Text('Export as CSV'),
            subtitle: const Text('Comma-separated values file'),
            onTap: () {
              Navigator.pop(context);
              onExportCSV();
            },
          ),
          ListTile(
            leading: const Icon(Icons.code, color: AppColors.primary),
            title: const Text('Export as JSON'),
            subtitle: const Text('JavaScript Object Notation file'),
            onTap: () {
              Navigator.pop(context);
              onExportJSON();
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

