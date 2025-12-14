import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String username;
  final DateTime createdAt;
  final DateTime lastLogin;

  const User({
    required this.id,
    required this.username,
    required this.createdAt,
    required this.lastLogin,
  });

  @override
  List<Object?> get props => [id, username, createdAt, lastLogin];

  User copyWith({
    String? id,
    String? username,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}