part of 'transaction_bloc.dart';

abstract class TransactionEvent {}

class TransactionLoadRequested extends TransactionEvent {
  final String userId;
  TransactionLoadRequested(this.userId);
}

class TransactionAddRequested extends TransactionEvent {
  final Transaction transaction;
  TransactionAddRequested(this.transaction);
}

class TransactionDeleteRequested extends TransactionEvent {
  final String id;
  TransactionDeleteRequested(this.id);
}
