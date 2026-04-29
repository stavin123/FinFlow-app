import 'package:hive/hive.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String passwordHash;

  @HiveField(4)
  final String? avatarUrl;

  @HiveField(5)
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    this.avatarUrl,
    required this.createdAt,
  });

  factory UserModel.fromEntity(User user, {required String passwordHash}) {
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      passwordHash: passwordHash,
      avatarUrl: user.avatarUrl,
      createdAt: user.createdAt,
    );
  }

  User toEntity() => User(
        id: id,
        name: name,
        email: email,
        avatarUrl: avatarUrl,
        createdAt: createdAt,
      );
}
