import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/bloc/transaction_bloc.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) return const SizedBox();
          final user = authState.user;

          return BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, txState) {
              return CustomScrollView(
                slivers: [
                  _buildAppBar(context, user.name),
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        if (txState is TransactionLoaded) ...[
                          _BalanceCard(state: txState),
                          const SizedBox(height: 20),
                          _SummaryRow(state: txState),
                          const SizedBox(height: 24),
                          _SpendingChart(transactions: txState.transactions),
                          const SizedBox(height: 24),
                          _RecentTransactions(
                              transactions: txState.transactions.take(5).toList()),
                        ] else if (txState is TransactionLoading) ...[
                          const SizedBox(height: 60),
                          const Center(child: CircularProgressIndicator()),
                        ],
                      ]),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, String name) {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.background,
      expandedHeight: 100,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _greeting(),
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary),
            ),
            Text(
              name.split(' ').first,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
      actions: [
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) => IconButton(
            icon: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryLight.withOpacity(0.2),
              child: Text(
                state is AuthAuthenticated
                    ? state.user.name[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w700),
              ),
            ),
            onPressed: () => context.push('/profile'),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }
}

class _BalanceCard extends StatelessWidget {
  final TransactionLoaded state;
  const _BalanceCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Balance',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(state.balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _MiniStat(
                label: 'Income',
                value: CurrencyFormatter.compact(state.totalIncome),
                icon: Icons.arrow_downward_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 32),
              _MiniStat(
                label: 'Expenses',
                value: CurrencyFormatter.compact(state.totalExpense),
                icon: Icons.arrow_upward_rounded,
                color: Colors.white70,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: color, fontSize: 11)),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
          ],
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final TransactionLoaded state;
  const _SummaryRow({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Income',
            value: state.totalIncome,
            color: AppColors.income,
            icon: Icons.trending_up_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: 'Expenses',
            value: state.totalExpense,
            color: AppColors.expense,
            icon: Icons.trending_down_rounded,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final IconData icon;
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: context.textTheme.bodyMedium),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.compact(value),
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpendingChart extends StatelessWidget {
  final List<Transaction> transactions;
  const _SpendingChart({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final expenses = transactions
        .where((t) => t.type == TransactionType.expense)
        .toList();

    if (expenses.isEmpty) return const SizedBox();

    // Group by category
    final Map<String, double> categoryMap = {};
    for (final t in expenses) {
      categoryMap[t.category] = (categoryMap[t.category] ?? 0) + t.amount;
    }

    final sorted = categoryMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(5).toList();
    final total = top.fold<double>(0, (s, e) => s + e.value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Spending by Category',
            style: context.textTheme.titleLarge),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: Row(
            children: [
              SizedBox(
                width: 160,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: top.asMap().entries.map((e) {
                      final color =
                          AppColors.chartColors[e.key % AppColors.chartColors.length];
                      return PieChartSectionData(
                        value: e.value.value,
                        color: color,
                        radius: 50,
                        title: '',
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: top.asMap().entries.map((e) {
                    final color =
                        AppColors.chartColors[e.key % AppColors.chartColors.length];
                    final pct = total > 0
                        ? (e.value.value / total * 100).toStringAsFixed(1)
                        : '0';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              e.value.key,
                              style: context.textTheme.bodyMedium
                                  ?.copyWith(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '$pct%',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecentTransactions extends StatelessWidget {
  final List<Transaction> transactions;
  const _RecentTransactions({required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent', style: context.textTheme.titleLarge),
            TextButton(
              onPressed: () => context.go('/transactions'),
              child: const Text('See all'),
            ),
          ],
        ),
        ...transactions.map((tx) {
          final isIncome = tx.type == TransactionType.income;
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (isIncome ? AppColors.income : AppColors.expense)
                    .withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isIncome
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                color: isIncome ? AppColors.income : AppColors.expense,
                size: 20,
              ),
            ),
            title: Text(tx.title, style: context.textTheme.titleMedium),
            subtitle: Text(tx.category, style: context.textTheme.bodyMedium),
            trailing: Text(
              '${isIncome ? '+' : '-'}${CurrencyFormatter.formatAbs(tx.amount)}',
              style: TextStyle(
                color: isIncome ? AppColors.income : AppColors.expense,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          );
        }),
      ],
    );
  }
}
