import '../../../../core/models/user.dart';

class UserMapper {
  static User fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      username: map['username'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastLogin: DateTime.parse(map['lastLogin'] as String),
    );
  }

  static Map<String, dynamic> toMap(User user) {
    return {
      'id': user.id,
      'username': user.username,
      'createdAt': user.createdAt.toIso8601String(),
      'lastLogin': user.lastLogin.toIso8601String(),
    };
  }
}