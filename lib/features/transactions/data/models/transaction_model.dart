import 'package:hive/hive.dart';
import '../../domain/entities/transaction.dart' as entity;

part 'transaction_model.g.dart';

@HiveType(typeId: 1)
class TransactionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final double amount;

  @HiveField(5)
  final bool isIncome;

  @HiveField(6)
  final DateTime date;

  @HiveField(7)
  final String? note;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.category,
    required this.amount,
    required this.isIncome,
    required this.date,
    this.note,
  });

  factory TransactionModel.fromEntity(entity.Transaction t) {
    return TransactionModel(
      id: t.id,
      userId: t.userId,
      title: t.title,
      category: t.category,
      amount: t.amount,
      isIncome: t.type == entity.TransactionType.income,
      date: t.date,
      note: t.note,
    );
  }

  entity.Transaction toEntity() => entity.Transaction(
        id: id,
        userId: userId,
        title: title,
        category: category,
        amount: amount,
        type: isIncome
            ? entity.TransactionType.income
            : entity.TransactionType.expense,
        date: date,
        note: note,
      );
}
