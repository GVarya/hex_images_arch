import '../../../core/failure/app_failure.dart';
import '../../interfaces/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<String> execute(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      throw ValidationFailure('Имя пользователя и пароль не могут быть пустыми');
    }

    if (password.length < 3) {
      throw ValidationFailure('Пароль должен быть не менее 3 символов');
    }

    try {
      final user = await repository.login(username, password);
      return 'Успешный вход: ${user.username}';
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw AuthFailure('Ошибка входа: $e');
    }
  }
}