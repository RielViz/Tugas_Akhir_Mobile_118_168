// ------------------------------------------
// lib/repositories/auth_repository.dart
// ------------------------------------------

import 'package:hive/hive.dart';
import 'package:bcrypt/bcrypt.dart';
import '../models/user_model.dart';

class AuthRepository {
  final Box<User> _userBox = Hive.box<User>('userBox');
  // Box baru untuk menyimpan sesi login
  final Box _sessionBox = Hive.box('sessionBox'); 

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

    // --- SIMPAN SESI (Username) KE HIVE ---
    await _sessionBox.put('current_user', username);

    return user;
  }

  // --- FUNGSI BARU: CEK SESI SAAT APP DIBUKA ---
  Future<User?> getCurrentUser() async {
    // Ambil username yang tersimpan di sesi
    final String? username = _sessionBox.get('current_user');
    
    if (username != null) {
      // Jika ada, kembalikan object User dari database
      return _userBox.get(username);
    }
    return null; // Tidak ada sesi
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
    // --- HAPUS SESI SAAT LOGOUT ---
    await _sessionBox.delete('current_user');
  }
}