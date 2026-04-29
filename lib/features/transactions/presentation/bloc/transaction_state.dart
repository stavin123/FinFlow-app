part of 'transaction_bloc.dart';

abstract class TransactionState {}

class TransactionInitial extends TransactionState {}
class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<Transaction> transactions;
  final double totalIncome;
  final double totalExpense;
  final double balance;

  TransactionLoaded(this.transactions)
      : totalIncome = transactions
            .where((t) => t.type == TransactionType.income)
            .fold(0, (sum, t) => sum + t.amount),
        totalExpense = transactions
            .where((t) => t.type == TransactionType.expense)
            .fold(0, (sum, t) => sum + t.amount),
        balance = transactions.fold(0, (sum, t) => sum + t.signedAmount);
}

class TransactionError extends TransactionState {
  final String message;
  TransactionError(this.message);
}
