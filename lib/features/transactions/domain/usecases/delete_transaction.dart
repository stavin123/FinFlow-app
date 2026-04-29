import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/transaction_repository.dart';

class DeleteTransaction implements UseCase<Unit, String> {
  final TransactionRepository repository;
  DeleteTransaction(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String id) =>
      repository.deleteTransaction(id);
}
