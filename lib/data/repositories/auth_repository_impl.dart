import '../../core/failure/app_failure.dart';
import '../../core/models/user.dart';
import '../../domain/interfaces/repositories/auth_repository.dart';
import '../datasources/local/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl(this._localDataSource);

  @override
  Future<User?> getCurrentUser() async {
    return await _localDataSource.getCurrentUser();
  }

  @override
  Future<User> login(String username, String password) async {
    final isValid = await _localDataSource.validateCredentials(username, password);

    if (!isValid) {
      throw AuthFailure('Неверные учетные данные');
    }

    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      username: username,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastLogin: DateTime.now(),
    );

    await _localDataSource.saveUser(user);
    return user;
  }

  @override
  Future<User> register(String username, String password) async {
    final currentUser = await _localDataSource.getCurrentUser();
    if (currentUser != null && currentUser.username == username) {
      throw AuthFailure('Пользователь уже существует');
    }

    final user = await _localDataSource.createUser(username, password);
    await _localDataSource.saveUser(user);
    return user;
  }

  @override
  Future<void> logout() async {
    await _localDataSource.clearUser();
  }

  @override
  Stream<User?> get userStream => _localDataSource.userStream;
}