import '../../../core/models/effect.dart';

abstract class EffectRepository {
  Future<List<Effect>> getAvailableEffects();
  Future<void> applyEffect({
    required String imageId,
    required String effectId,
    required double intensity,
    required double speed,
  });
}