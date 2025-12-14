import '../../core/models/effect.dart';
import '../../domain/interfaces/repositories/effect_repository.dart';
import '../datasources/local/effect_local_datasource.dart';

class EffectRepositoryImpl implements EffectRepository {
  final EffectLocalDataSource _localDataSource;

  EffectRepositoryImpl(this._localDataSource);

  @override
  Future<List<Effect>> getAvailableEffects() async {
    return await _localDataSource.getAvailableEffects();
  }

  @override
  Future<void> applyEffect({
    required String imageId,
    required String effectId,
    required double intensity,
    required double speed,
  }) async {
    await _localDataSource.applyEffect(
      imageId: imageId,
      effectId: effectId,
      intensity: intensity,
      speed: speed,
    );
  }
}