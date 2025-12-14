import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/failure/app_failure.dart';
import '../../core/models/effect.dart';
import '../providers/dependencies_provider.dart';

class EffectsState {
  final List<Effect> effects;
  final bool isLoading;
  final AppFailure? error;

  const EffectsState({
    this.effects = const [],
    this.isLoading = false,
    this.error,
  });

  EffectsState copyWith({
    List<Effect>? effects,
    bool? isLoading,
    AppFailure? error,
  }) {
    return EffectsState(
      effects: effects ?? this.effects,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class EffectsNotifier extends StateNotifier<EffectsState> {
  final Ref ref;

  EffectsNotifier(this.ref) : super(const EffectsState());

  Future<void> loadEffects() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final useCase = ref.read(getEffectsUseCaseProvider);
      final effects = await useCase.execute();
      state = state.copyWith(effects: effects, isLoading: false);
    } on AppFailure catch (e) {
      state = state.copyWith(error: e, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: const EffectFailure('Ошибка загрузки эффектов'),
        isLoading: false,
      );
    }
  }

  Future<void> applyEffect({
    required String effectId,
    required double intensity,
    required double speed,
  }) async {
    try {
      final repository = ref.read(effectRepositoryProvider);
      await repository.applyEffect(
        imageId: 'demo',
        effectId: effectId,
        intensity: intensity,
        speed: speed,
      );
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw const EffectFailure('Ошибка применения эффекта');
    }
  }
}

final effectsProvider = StateNotifierProvider<EffectsNotifier, EffectsState>(
      (ref) => EffectsNotifier(ref),
);