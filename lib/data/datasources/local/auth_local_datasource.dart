import 'dart:async';
import '../../../core/models/user.dart';
import 'mappers/user_mapper.dart';

class AuthLocalDataSource {
  final Map<String, dynamic> _storage = {};
  final StreamController<User?> _userController = StreamController<User?>.broadcast();

  Future<User?> getCurrentUser() async {
    final userData = _storage['currentUser'];
    if (userData == null) return null;
    return UserMapper.fromMap(userData as Map<String, dynamic>);
  }

  Future<void> saveUser(User user) async {
    _storage['currentUser'] = UserMapper.toMap(user);
    _userController.add(user);
  }

  Future<void> clearUser() async {
    _storage.remove('currentUser');
    _userController.add(null);
  }

  Future<bool> validateCredentials(String username, String password) async {
    final demoUsers = {
      'demo': 'password123',
      'test': 'test123',
      'v': 'v',
    };

    return demoUsers[username] == password;
  }

  Future<User> createUser(String username, String password) async {
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      username: username,
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );

    _storage['user_$username'] = password;

    return user;
  }

  Stream<User?> get userStream => _userController.stream;

  void dispose() {
    _userController.close();
  }
}