import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/transaction.dart';
import '../bloc/transaction_bloc.dart';

class TransactionsPage extends StatelessWidget {
  final String userId;
  const TransactionsPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/transactions/add', extra: userId),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add'),
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TransactionError) {
            return Center(
              child: Text(state.message, style: context.textTheme.bodyMedium),
            );
          }
          if (state is TransactionLoaded) {
            if (state.transactions.isEmpty) return _buildEmpty(context);
            return _buildList(context, state);
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.receipt_long_outlined,
              size: 64, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text('No transactions yet', style: context.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Tap the + button to add one',
              style: context.textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, TransactionLoaded state) {
    // Group by date
    final Map<String, List<Transaction>> grouped = {};
    for (final tx in state.transactions) {
      final key = DateFormatter.relative(tx.date);
      grouped.putIfAbsent(key, () => []).add(tx);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final dateKey = grouped.keys.elementAt(index);
        final txList = grouped[dateKey]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                dateKey,
                style: context.textTheme.labelLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ...txList.map((tx) => _TransactionTile(
                  transaction: tx,
                  onDelete: () => context
                      .read<TransactionBloc>()
                      .add(TransactionDeleteRequested(tx.id)),
                )),
          ],
        );
      },
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onDelete;

  const _TransactionTile({
    required this.transaction,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.expense.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppColors.expense),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            _buildCategoryIcon(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(transaction.title,
                      style: context.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(transaction.category,
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                      )),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncome ? '+' : '-'}${CurrencyFormatter.formatAbs(transaction.amount)}',
                  style: context.textTheme.titleMedium?.copyWith(
                    color: isIncome ? AppColors.income : AppColors.expense,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  DateFormatter.time(transaction.date),
                  style: context.textTheme.bodyMedium?.copyWith(fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon() {
    final isIncome = transaction.type == TransactionType.income;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: (isIncome ? AppColors.income : AppColors.expense)
            .withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
        color: isIncome ? AppColors.income : AppColors.expense,
        size: 20,
      ),
    );
  }
}
