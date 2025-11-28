// -------------------------------
// lib/data/models/user_model.dart
// -------------------------------
import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  final String username;

  @HiveField(1)
  final String encryptedPassword;

  @HiveField(2)
  String? profileImagePath;

  User({
    required this.username,
    required this.encryptedPassword,
    this.profileImagePath,
  });
}
