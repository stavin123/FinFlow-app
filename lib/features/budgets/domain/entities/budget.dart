import 'package:equatable/equatable.dart';

class Budget extends Equatable {
  final String id;
  final String userId;
  final String category;
  final double limit;
  final double spent;
  final DateTime month;

  const Budget({
    required this.id,
    required this.userId,
    required this.category,
    required this.limit,
    required this.spent,
    required this.month,
  });

  double get remaining => limit - spent;
  double get percentUsed => limit > 0 ? (spent / limit).clamp(0, 1) : 0;
  bool get isOverBudget => spent > limit;

  @override
  List<Object> get props => [id, userId, category, limit, spent, month];
}
