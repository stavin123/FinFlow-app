import 'package:hive/hive.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel?> getCachedUser();
  Future<void> cacheUser(UserModel user);
  Future<void> clearUser();
  Future<UserModel?> findUserByEmail(String email);
  Future<void> saveUser(UserModel user);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final Box<UserModel> userBox;
  final Box<dynamic> settingsBox;

  const AuthLocalDataSourceImpl({
    required this.userBox,
    required this.settingsBox,
  });

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final id = settingsBox.get(AppConstants.currentUserKey) as String?;
      if (id == null) return null;
      return userBox.get(id);
    } catch (_) {
      throw const CacheException();
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await settingsBox.put(AppConstants.currentUserKey, user.id);
    } catch (_) {
      throw const CacheException();
    }
  }

  @override
  Future<void> clearUser() async {
    try {
      await settingsBox.delete(AppConstants.currentUserKey);
    } catch (_) {
      throw const CacheException();
    }
  }

  @override
  Future<UserModel?> findUserByEmail(String email) async {
    try {
      final users = userBox.values;
      return users
          .where((u) => u.email.toLowerCase() == email.toLowerCase())
          .firstOrNull;
    } catch (_) {
      throw const CacheException();
    }
  }

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      await userBox.put(user.id, user);
    } catch (_) {
      throw const CacheException();
    }
  }
}
