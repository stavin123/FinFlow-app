import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/transaction.dart';
import '../bloc/transaction_bloc.dart';

class AddTransactionPage extends StatefulWidget {
  final String userId;
  const AddTransactionPage({super.key, required this.userId});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  TransactionType _type = TransactionType.expense;
  String _category = AppConstants.expenseCategories.first;
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  List<String> get _categories => _type == TransactionType.expense
      ? AppConstants.expenseCategories
      : AppConstants.incomeCategories;

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: context.theme.copyWith(
          colorScheme: context.colorScheme.copyWith(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final tx = Transaction(
      id: const Uuid().v4(),
      userId: widget.userId,
      title: _titleCtrl.text.trim(),
      category: _category,
      amount: double.parse(_amountCtrl.text),
      type: _type,
      date: _date,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );
    context.read<TransactionBloc>().add(TransactionAddRequested(tx));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTypeToggle(),
              const SizedBox(height: 24),
              TextFormField(
                controller: _amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: context.textTheme.displayMedium?.copyWith(
                  color: _type == TransactionType.income
                      ? AppColors.income
                      : AppColors.expense,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter an amount';
                  if (double.tryParse(v) == null || double.parse(v) <= 0) {
                    return 'Enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Enter a title' : null,
              ),
              const SizedBox(height: 16),
              _buildCategoryDropdown(),
              const SizedBox(height: 16),
              _buildDatePicker(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  prefixIcon: Icon(Icons.notes_rounded),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Save Transaction'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: TransactionType.values.map((t) {
          final selected = _type == t;
          final isIncome = t == TransactionType.income;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _type = t;
                  _category = _categories.first;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selected
                      ? (isIncome ? AppColors.income : AppColors.expense)
                          .withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: selected
                      ? Border.all(
                          color:
                              isIncome ? AppColors.income : AppColors.expense,
                          width: 1.5,
                        )
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isIncome
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      color: selected
                          ? (isIncome ? AppColors.income : AppColors.expense)
                          : AppColors.textHint,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isIncome ? 'Income' : 'Expense',
                      style: TextStyle(
                        color: selected
                            ? (isIncome ? AppColors.income : AppColors.expense)
                            : AppColors.textHint,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    if (!_categories.contains(_category)) {
      _category = _categories.first;
    }
    return DropdownButtonFormField<String>(
      value: _category,
      dropdownColor: AppColors.surfaceVariant,
      decoration: const InputDecoration(
        labelText: 'Category',
        prefixIcon: Icon(Icons.category_outlined),
      ),
      items: _categories
          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
          .toList(),
      onChanged: (v) => setState(() => _category = v!),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _pickDate,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date',
          prefixIcon: Icon(Icons.calendar_today_outlined),
        ),
        child: Text(DateFormatter.full(_date)),
      ),
    );
  }
}
