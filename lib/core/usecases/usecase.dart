import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Base use-case with params.
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Use-case with no params.
abstract class UseCaseNoParams<T> {
  Future<Either<Failure, T>> call();
}

/// Sentinel class when a use-case needs no parameters.
class NoParams {}
