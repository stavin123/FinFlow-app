import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<Either<Failure, List<Transaction>>> getTransactions(String userId);
  Future<Either<Failure, Transaction>> addTransaction(Transaction transaction);
  Future<Either<Failure, Unit>> deleteTransaction(String id);
  Future<Either<Failure, Transaction>> updateTransaction(Transaction transaction);
  Future<Either<Failure, List<Transaction>>> getTransactionsByDateRange({
    required String userId,
    required DateTime from,
    required DateTime to,
  });
}
