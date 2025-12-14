import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/failure/app_failure.dart';
import '../../core/models/effect.dart';
import '../providers/dependencies_provider.dart';


class EffectsScreen extends ConsumerStatefulWidget {
  const EffectsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EffectsScreen> createState() => _EffectsScreenState();
}

class _EffectsScreenState extends ConsumerState<EffectsScreen> {
  String? _selectedEffectId;
  bool _isApplying = false;
  double _effectIntensity = 0.5;
  double _effectSpeed = 0.5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(effectsProvider.notifier).loadEffects();
    });
  }

  void _selectEffect(String effectId) {
    setState(() {
      _selectedEffectId = effectId;
      _effectIntensity = 0.5;
      _effectSpeed = 0.5;
    });
  }

  Future<void> _applyEffect() async {
    if (_selectedEffectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите эффект')),
      );
      return;
    }

    setState(() => _isApplying = true);

    try {
      await ref.read(effectsProvider.notifier).applyEffect(
        effectId: _selectedEffectId!,
        intensity: _effectIntensity,
        speed: _effectSpeed,
      );

      _showApplyDialog();
    } on EffectFailure catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) {
        setState(() => _isApplying = false);
      }
    }
  }

  void _showApplyDialog() {
    final effectsState = ref.read(effectsProvider);
    final effect = effectsState.effects.firstWhere(
          (e) => e.id == _selectedEffectId,
      orElse: () => Effect(
        id: _selectedEffectId!,
        name: 'Выбранный эффект',
        description: '',
        colorValue: 0xFF2196F3,
      ),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Эффект применён'),
        content: Text('Эффект "${effect.name}" успешно применён к изображению'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _resetSettings() {
    setState(() {
      _selectedEffectId = null;
      _effectIntensity = 0.5;
      _effectSpeed = 0.5;
    });
  }

  IconData _getIconForEffect(String effectId) {
    switch (effectId) {
      case 'clock':
        return Icons.schedule;
      case 'rainbow':
        return Icons.gradient;
      case 'pulse':
        return Icons.favorite;
      case 'wave':
        return Icons.water;
      case 'fire':
        return Icons.local_fire_department;
      case 'snow':
        return Icons.cloud;
      case 'matrix':
        return Icons.border_all;
      case 'plasma':
        return Icons.flash_on;
      default:
        return Icons.auto_awesome;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectsState = ref.watch(effectsProvider);
    final selectedEffect = _selectedEffectId != null
        ? effectsState.effects.firstWhere(
          (e) => e.id == _selectedEffectId,
      orElse: () => Effect(
        id: _selectedEffectId!,
        name: 'Неизвестный эффект',
        description: '',
        colorValue: 0xFF757575,
      ),
    )
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Эффекты'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: effectsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Доступные эффекты',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: effectsState.effects.length,
                    itemBuilder: (context, index) {
                      final effect = effectsState.effects[index];
                      final isSelected = _selectedEffectId == effect.id;

                      return GestureDetector(
                        onTap: () => _selectEffect(effect.id),
                        child: Card(
                          elevation: isSelected ? 4 : 1,
                          color: isSelected
                              ? Color(effect.colorValue).withOpacity(0.1)
                              : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected
                                  ? Color(effect.colorValue)
                                  : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Color(effect.colorValue)
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  _getIconForEffect(effect.id),
                                  color: Color(effect.colorValue),
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                effect.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0),
                                child: Text(
                                  effect.description,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            if (selectedEffect != null) ..._buildEffectParameters(selectedEffect),
            if (selectedEffect == null && !effectsState.isLoading)
              _buildEmptySelection(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildEffectParameters(Effect selectedEffect) {
    return [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            const SizedBox(height: 12),
            Text(
              'Параметры: ${selectedEffect.name}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Интенсивность'),
                    Text(
                      '${(_effectIntensity * 100).toInt()}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Slider(
                  value: _effectIntensity,
                  onChanged: (value) {
                    setState(() {
                      _effectIntensity = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Скорость'),
                    Text(
                      '${(_effectSpeed * 100).toInt()}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Slider(
                  value: _effectSpeed,
                  onChanged: (value) {
                    setState(() {
                      _effectSpeed = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(selectedEffect.colorValue)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(selectedEffect.colorValue).withOpacity(0.3),
                          Color(selectedEffect.colorValue).withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getIconForEffect(selectedEffect.id),
                        size: 48,
                        color: Color(selectedEffect.colorValue),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Предпросмотр эффекта',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _resetSettings,
                    icon: const Icon(Icons.restore),
                    label: const Text('Сбросить'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isApplying ? null : _applyEffect,
                    icon: _isApplying
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Icon(Icons.check),
                    label: const Text('Применить'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildEmptySelection() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.touch_app,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Выберите эффект',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}