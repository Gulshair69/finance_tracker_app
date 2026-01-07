import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constants/app_colors.dart';

class IncomeExpensePieChart extends StatelessWidget {
  final double income;
  final double expense;

  const IncomeExpensePieChart({
    super.key,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    final total = income + expense;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive sizing based on screen size
    // Limit chart size to prevent overflow (max 180px to leave room for legend and padding)
    final maxChartSize = 180.0;
    final chartSize =
        (screenWidth < 360
                ? screenWidth * 0.7
                : screenWidth < 400
                ? screenWidth * 0.75
                : screenWidth * 0.8)
            .clamp(0.0, maxChartSize);

    // Ensure centerSpaceRadius and radius fit within chartSize
    final centerSpaceRadius =
        (screenWidth < 360
                ? 40.0
                : screenWidth < 400
                ? 50.0
                : 60.0)
            .clamp(0.0, chartSize / 3);
    final radius = (screenWidth < 360
        ? 70.0
        : screenWidth < 400
        ? 85.0
        : 100.0);
    final fontSize = screenWidth < 360
        ? 10.0
        : screenWidth < 400
        ? 11.0
        : 12.0;

    if (total == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No data available',
            style: TextStyle(fontSize: screenWidth < 360 ? 12 : 14),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Use OverflowBox to allow labels to render outside strict bounds
          SizedBox(
            height: chartSize + 40, // Add extra space for labels
            width: chartSize + 40, // Add extra space for labels
            child: Center(
              child: SizedBox(
                height: chartSize,
                width: chartSize,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: centerSpaceRadius,
                    sections: [
                      PieChartSectionData(
                        value: income,
                        title: '\$${income.toStringAsFixed(0)}',
                        color: AppColors.secondary,
                        radius: radius.clamp(0.0, chartSize / 2 - 10),
                        titleStyle: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      PieChartSectionData(
                        value: expense,
                        title: '\$${expense.toStringAsFixed(0)}',
                        color: AppColors.trueRed,
                        radius: radius.clamp(0.0, chartSize / 2 - 10),
                        titleStyle: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Legend
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 24,
            runSpacing: 12,
            children: [
              _buildLegendItem(
                context,
                'Income',
                AppColors.secondary,
                screenWidth,
              ),
              _buildLegendItem(
                context,
                'Expense',
                AppColors.trueRed,
                screenWidth,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    String label,
    Color color,
    double screenWidth,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: screenWidth < 360 ? 12 : 16,
          height: screenWidth < 360 ? 12 : 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: screenWidth < 360 ? 11 : 13,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class CategoryPieChart extends StatelessWidget {
  final Map<String, double> categoryData;
  final Map<String, Color>? categoryColors;

  const CategoryPieChart({
    super.key,
    required this.categoryData,
    this.categoryColors,
  });

  @override
  Widget build(BuildContext context) {
    if (categoryData.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final colors = [
      AppColors.primary,
      AppColors.secondary,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.blue,
      Colors.amber,
    ];

    final entries = categoryData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: entries.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          final color =
              categoryColors?[data.key] ?? colors[index % colors.length];

          return PieChartSectionData(
            value: data.value,
            title: data.key.length > 8
                ? '${data.key.substring(0, 8)}...'
                : data.key,
            color: color,
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class MonthlyTrendChart extends StatelessWidget {
  final Map<String, Map<String, double>> monthlyData;

  const MonthlyTrendChart({super.key, required this.monthlyData});

  @override
  Widget build(BuildContext context) {
    if (monthlyData.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final months = monthlyData.keys.toList();
    final maxValue = monthlyData.values
        .expand((m) => [m['income'] ?? 0, m['expense'] ?? 0])
        .fold(0.0, (a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${value.toInt()}',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < months.length) {
                  final month = months[value.toInt()];
                  return Text(
                    month.substring(5),
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        minX: 0,
        maxX: (months.length - 1).toDouble(),
        minY: 0,
        maxY: maxValue * 1.2,
        lineBarsData: [
          LineChartBarData(
            spots: months.asMap().entries.map((entry) {
              final index = entry.key.toDouble();
              final income = monthlyData[entry.value]?['income'] ?? 0.0;
              return FlSpot(index, income);
            }).toList(),
            isCurved: true,
            color: AppColors.secondary,
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          ),
          LineChartBarData(
            spots: months.asMap().entries.map((entry) {
              final index = entry.key.toDouble();
              final expense = monthlyData[entry.value]?['expense'] ?? 0.0;
              return FlSpot(index, expense);
            }).toList(),
            isCurved: true,
            color: AppColors.trueRed,
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}
