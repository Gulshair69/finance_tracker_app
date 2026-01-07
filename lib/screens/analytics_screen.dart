import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/transaction_provider.dart';
import '../providers/analytics_provider.dart';
import '../models/transaction_model.dart';
import '../widgets/chart_widgets.dart';
import '../widgets/date_range_picker.dart';
import '../widgets/export_dialog.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class AnalyticsScreen extends StatefulWidget {
  static const String routeName = '/analytics';

  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final analyticsProvider = Provider.of<AnalyticsProvider>(context);

    final income = transactionProvider.getTotalIncome(
      startDate: _startDate,
      endDate: _endDate,
    );
    final expense = transactionProvider.getTotalExpenses(
      startDate: _startDate,
      endDate: _endDate,
    );
    final savingsRate = analyticsProvider.getSavingsRate(
      startDate: _startDate,
      endDate: _endDate,
    );
    final avgDailySpending = analyticsProvider.getAverageDailySpending();

    final monthlyData = analyticsProvider.getMonthlyData();
    final categoryBreakdown = analyticsProvider.getCategoryBreakdown(
      type: TransactionType.expense,
    );
    final topCategories = analyticsProvider.getTopCategories(limit: 5);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Analytics"),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => ExportDialog(
                  onExportCSV: () => _exportToCSV(transactionProvider),
                  onExportJSON: () => _exportToJSON(transactionProvider),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Range Picker
            Padding(
              padding: const EdgeInsets.all(16),
              child: DateRangePickerWidget(
                startDate: _startDate,
                endDate: _endDate,
                onDateRangeSelected: (start, end) {
                  setState(() {
                    _startDate = start;
                    _endDate = end;
                  });
                },
              ),
            ),

            // Summary Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text(
                              "Income",
                              style: TextStyle(color: AppColors.grey),
                            ),
                            Text(
                              '\$${income.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text(
                              "Expense",
                              style: TextStyle(color: AppColors.grey),
                            ),
                            Text(
                              '\$${expense.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.trueRed,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Savings Rate
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Savings Rate",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${savingsRate.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Income vs Expense Pie Chart
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Income vs Expense",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 280, // Increased to accommodate chart labels
              child: IncomeExpensePieChart(
                income: income,
                expense: expense,
              ),
            ),

            const SizedBox(height: 24),

            // Monthly Trend Chart
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Monthly Trend",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 250,
              child: MonthlyTrendChart(monthlyData: monthlyData),
            ),

            const SizedBox(height: 24),

            // Category Breakdown
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Category Breakdown",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (categoryBreakdown.isNotEmpty)
              SizedBox(
                height: 250,
                child: CategoryPieChart(categoryData: categoryBreakdown),
              )
            else
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: Text("No data available")),
              ),

            const SizedBox(height: 24),

            // Top Categories
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Top Spending Categories",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...topCategories.map((entry) => Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    title: Text(entry.key),
                    trailing: Text(
                      '\$${entry.value.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                )),

            const SizedBox(height: 24),

            // Average Daily Spending
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Average Daily Spending (Last 30 days)",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${avgDailySpending.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/profile');
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
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Future<void> _exportToCSV(TransactionProvider provider) async {
    try {
      final transactions = provider.transactions;
      final csv = StringBuffer();
      csv.writeln('Title,Amount,Type,Category,Date,Description');

      for (var tx in transactions) {
        csv.writeln(
          '${tx.title},"${tx.amount}",${tx.type.name},${tx.category},"${tx.date.toIso8601String()}","${tx.description ?? ""}"',
        );
      }

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/transactions_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(csv.toString());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exported to ${file.path}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _exportToJSON(TransactionProvider provider) async {
    try {
      final transactions = provider.transactions;
      final jsonData = transactions.map((tx) => {
        'title': tx.title,
        'amount': tx.amount,
        'type': tx.type.name,
        'category': tx.category,
        'date': tx.date.toIso8601String(),
        'description': tx.description,
      }).toList();

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/transactions_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonEncode(jsonData));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exported to ${file.path}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }
}

