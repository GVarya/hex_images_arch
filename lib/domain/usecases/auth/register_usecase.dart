import '../../../core/failure/app_failure.dart';
import '../../interfaces/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<String> execute(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      throw ValidationFailure('Имя пользователя и пароль не могут быть пустыми');
    }

    if (username.length < 3) {
      throw ValidationFailure('Имя пользователя должно быть не менее 3 символов');
    }

    if (password.length < 3) {
      throw ValidationFailure('Пароль должен быть не менее 3 символов');
    }

    try {
      final user = await repository.register(username, password);
      return 'Успешная регистрация: ${user.username}';
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw AuthFailure('Ошибка регистрации: $e');
    }
  }
}