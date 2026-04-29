import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({required this.localDataSource});

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  @override
  Future<Either<Failure, User>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await localDataSource.findUserByEmail(email);
      if (userModel == null) {
        return const Left(AuthFailure(message: 'No account found with this email.'));
      }
      final hash = _hashPassword(password);
      if (userModel.passwordHash != hash) {
        return const Left(AuthFailure(message: 'Incorrect password.'));
      }
      await localDataSource.cacheUser(userModel);
      return Right(userModel.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, User>> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final existing = await localDataSource.findUserByEmail(email);
      if (existing != null) {
        return const Left(AuthFailure(message: 'An account with this email already exists.'));
      }
      final user = User(
        id: const Uuid().v4(),
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );
      final model = UserModel.fromEntity(user, passwordHash: _hashPassword(password));
      await localDataSource.saveUser(model);
      await localDataSource.cacheUser(model);
      return Right(user);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await localDataSource.clearUser();
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final model = await localDataSource.getCachedUser();
      return Right(model?.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateProfile({
    required String name,
    String? avatarUrl,
  }) async {
    try {
      final model = await localDataSource.getCachedUser();
      if (model == null) return const Left(AuthFailure(message: 'Not logged in.'));
      final updated = UserModel(
        id: model.id,
        name: name,
        email: model.email,
        passwordHash: model.passwordHash,
        avatarUrl: avatarUrl ?? model.avatarUrl,
        createdAt: model.createdAt,
      );
      await localDataSource.saveUser(updated);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }
}
