import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/extensions.dart';

class BudgetsPage extends StatelessWidget {
  const BudgetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Budget'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.pie_chart_outline_rounded,
                size: 64, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text('No budgets set', style: context.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Set spending limits for each category',
                style: context.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
