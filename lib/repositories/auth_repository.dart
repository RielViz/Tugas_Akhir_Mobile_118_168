// ------------------------------------------
// lib/data/repositories/auth_repository.dart
// ------------------------------------------

import 'package:hive/hive.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:ta_teori/models/user_model.dart';

class AuthRepository {
  final Box<User> _userBox = Hive.box<User>('userBox');

  Future<void> register(String username, String password) async {
    if (_userBox.containsKey(username)) {
      throw Exception('Username sudah terdaftar');
    }
    final String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
    final newUser = User(
      username: username,
      encryptedPassword: hashedPassword,
      profileImagePath: null,
    );
    await _userBox.put(username, newUser);
  }

  Future<User> login(String username, String password) async {
    final user = _userBox.get(username);
    if (user == null) {
      throw Exception('Username tidak ditemukan');
    }
    final bool isPasswordMatch =
        BCrypt.checkpw(password, user.encryptedPassword);
    if (!isPasswordMatch) {
      throw Exception('Password salah');
    }
    return user;
  }

  Future<User> updateProfilePicture(
      String username, String newImagePath) async {
    final user = _userBox.get(username);

    if (user == null) {
      throw Exception('User tidak ditemukan saat update foto');
    }

    user.profileImagePath = newImagePath;
    
    await user.save();

    return User(
      username: user.username,
      encryptedPassword: user.encryptedPassword,
      profileImagePath: user.profileImagePath,
    );
  }

  Future<void> logout() async {
  }
}