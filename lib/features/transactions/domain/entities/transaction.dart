import 'package:equatable/equatable.dart';

enum TransactionType { income, expense }

class Transaction extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String category;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final String? note;

  const Transaction({
    required this.id,
    required this.userId,
    required this.title,
    required this.category,
    required this.amount,
    required this.type,
    required this.date,
    this.note,
  });

  double get signedAmount =>
      type == TransactionType.income ? amount : -amount;

  @override
  List<Object?> get props =>
      [id, userId, title, category, amount, type, date, note];

  Transaction copyWith({
    String? id,
    String? userId,
    String? title,
    String? category,
    double? amount,
    TransactionType? type,
    DateTime? date,
    String? note,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}
