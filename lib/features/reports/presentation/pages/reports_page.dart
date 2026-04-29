import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/bloc/transaction_bloc.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is! TransactionLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          // Build monthly bar chart data
          final Map<String, double> monthlyExpenses = {};
          for (final tx in state.transactions) {
            if (tx.type == TransactionType.expense) {
              final key = DateFormatter.monthYear(tx.date);
              monthlyExpenses[key] = (monthlyExpenses[key] ?? 0) + tx.amount;
            }
          }

          if (monthlyExpenses.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bar_chart_rounded,
                      size: 64, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  Text('No data yet', style: context.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Add transactions to see reports',
                      style: context.textTheme.bodyMedium),
                ],
              ),
            );
          }

          final months = monthlyExpenses.keys.toList();
          final values = monthlyExpenses.values.toList();
          final maxY = values.reduce((a, b) => a > b ? a : b) * 1.2;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Monthly Expenses', style: context.textTheme.titleLarge),
                const SizedBox(height: 20),
                SizedBox(
                  height: 220,
                  child: BarChart(
                    BarChartData(
                      maxY: maxY,
                      barGroups: values.asMap().entries.map((e) {
                        return BarChartGroupData(
                          x: e.key,
                          barRods: [
                            BarChartRodData(
                              toY: e.value,
                              gradient: const LinearGradient(
                                colors: [AppColors.primary, AppColors.accent],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                              width: 18,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6)),
                            ),
                          ],
                        );
                      }).toList(),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final i = value.toInt();
                              if (i >= months.length) return const SizedBox();
                              final parts = months[i].split(' ');
                              return Text(
                                parts.first.substring(0, 3),
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary),
                              );
                            },
                          ),
                        ),
                      ),
                      gridData: FlGridData(
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (v) => FlLine(
                          color: AppColors.border,
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text('Summary', style: context.textTheme.titleLarge),
                const SizedBox(height: 16),
                _SummaryStatRow(
                  label: 'Total Income',
                  value: CurrencyFormatter.format(state.totalIncome),
                  color: AppColors.income,
                ),
                _SummaryStatRow(
                  label: 'Total Expenses',
                  value: CurrencyFormatter.format(state.totalExpense),
                  color: AppColors.expense,
                ),
                _SummaryStatRow(
                  label: 'Net Balance',
                  value: CurrencyFormatter.format(state.balance),
                  color: state.balance >= 0
                      ? AppColors.income
                      : AppColors.expense,
                ),
                _SummaryStatRow(
                  label: 'Total Transactions',
                  value: '${state.transactions.length}',
                  color: AppColors.primary,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryStatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SummaryStatRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.textTheme.bodyLarge),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
