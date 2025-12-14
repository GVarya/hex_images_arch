import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/failure/app_failure.dart';
import '../../core/models/user.dart';
import '../providers/dependencies_provider.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final AppFailure? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    AppFailure? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  AuthNotifier(this.ref) : super(const AuthState()) {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final repository = ref.read(authRepositoryProvider);
    final user = await repository.getCurrentUser();
    if (user != null) {
      state = state.copyWith(user: user);
    }
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final useCase = ref.read(loginUseCaseProvider);
      await useCase.execute(username, password);

      final repository = ref.read(authRepositoryProvider);
      final user = await repository.getCurrentUser();
      state = state.copyWith(user: user, isLoading: false);
    } on AppFailure catch (e) {
      state = state.copyWith(error: e, isLoading: false);
      rethrow;
    } catch (e) {
      state = state.copyWith(
        error: const AuthFailure('Неизвестная ошибка'),
        isLoading: false,
      );
      rethrow;
    }
  }

  Future<void> register(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final useCase = ref.read(registerUseCaseProvider);
      await useCase.execute(username, password);

      final repository = ref.read(authRepositoryProvider);
      final user = await repository.getCurrentUser();
      state = state.copyWith(user: user, isLoading: false);
    } on AppFailure catch (e) {
      state = state.copyWith(error: e, isLoading: false);
      rethrow;
    } catch (e) {
      state = state.copyWith(
        error: const AuthFailure('Неизвестная ошибка'),
        isLoading: false,
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.logout();
      state = const AuthState(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: const AuthFailure('Ошибка при выходе'),
        isLoading: false,
      );
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});