import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class AddTransaction implements UseCase<Transaction, Transaction> {
  final TransactionRepository repository;
  AddTransaction(this.repository);

  @override
  Future<Either<Failure, Transaction>> call(Transaction params) =>
      repository.addTransaction(params);
}
