import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class SignOut implements UseCaseNoParams<Unit> {
  final AuthRepository repository;
  SignOut(this.repository);

  @override
  Future<Either<Failure, Unit>> call() => repository.signOut();
}
