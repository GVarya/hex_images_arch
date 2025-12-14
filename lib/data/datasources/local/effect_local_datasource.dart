import '../../../core/models/effect.dart';
import '../../../core/models/color.dart';

class EffectLocalDataSource {
  final List<Effect> _effects = [
    Effect(
      id: 'clock',
      name: 'Часы',
      description: 'Отображение времени на экране',
      colorValue: const AppColor(0xFF2196F3).value,
    ),
    Effect(
      id: 'rainbow',
      name: 'Переливание цветом',
      description: 'Плавное изменение цветовой палитры',
      colorValue: const AppColor(0xFFF44336).value,
    ),
    Effect(
      id: 'pulse',
      name: 'Пульс',
      description: 'Ритмичное изменение яркости',
      colorValue: const AppColor(0xFFE91E63).value,
    ),
    Effect(
      id: 'wave',
      name: 'Волны',
      description: 'Волнообразное движение цветов',
      colorValue: const AppColor(0xFF00BCD4).value,
    ),
    Effect(
      id: 'fire',
      name: 'Огонь',
      description: 'Эффект горящего огня',
      colorValue: const AppColor(0xFFFF9800).value,
    ),
    Effect(
      id: 'snow',
      name: 'Снег',
      description: 'Падающие снежинки',
      colorValue: const AppColor(0xFF64B5F6).value,
    ),
    Effect(
      id: 'matrix',
      name: 'Матрица',
      description: 'Эффект матричного кода',
      colorValue: const AppColor(0xFF4CAF50).value,
    ),
    Effect(
      id: 'plasma',
      name: 'Плазма',
      description: 'Анимированная плазма',
      colorValue: const AppColor(0xFF9C27B0).value,
    ),
  ];

  Future<List<Effect>> getAvailableEffects() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_effects);
  }

  Future<void> applyEffect({
    required String imageId,
    required String effectId,
    required double intensity,
    required double speed,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
  }
}