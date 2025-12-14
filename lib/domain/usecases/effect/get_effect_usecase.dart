import '../../../core/failure/app_failure.dart';
import '../../../core/models/effect.dart';
import '../../interfaces/repositories/effect_repository.dart';

class GetEffectsUseCase {
  final EffectRepository repository;

  GetEffectsUseCase(this.repository);

  Future<List<Effect>> execute() async {
    try {
      return await repository.getAvailableEffects();
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw EffectFailure('Ошибка получения эффектов: $e');
    }
  }
}