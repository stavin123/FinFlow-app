import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final Box<TransactionModel> transactionBox;

  TransactionRepositoryImpl({required this.transactionBox});

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions(
      String userId) async {
    try {
      final all = transactionBox.values
          .where((t) => t.userId == userId)
          .map((t) => t.toEntity())
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      return Right(all);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Transaction>> addTransaction(
      Transaction transaction) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      await transactionBox.put(model.id, model);
      return Right(transaction);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTransaction(String id) async {
    try {
      await transactionBox.delete(id);
      return const Right(unit);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Transaction>> updateTransaction(
      Transaction transaction) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      await transactionBox.put(model.id, model);
      return Right(transaction);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactionsByDateRange({
    required String userId,
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final filtered = transactionBox.values
          .where((t) =>
              t.userId == userId &&
              !t.date.isBefore(from) &&
              !t.date.isAfter(to))
          .map((t) => t.toEntity())
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      return Right(filtered);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }
}
