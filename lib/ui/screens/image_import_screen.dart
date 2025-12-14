import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/failure/app_failure.dart';
import '../../core/models/hex_image.dart';
import '../../data/datasources/local/mappers/image_mapper.dart';
import '../providers/auth_provider.dart';
import '../providers/image_provider.dart';

class ImageImportScreen extends ConsumerStatefulWidget {
  const ImageImportScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ImageImportScreen> createState() => _ImageImportScreenState();
}

class _ImageImportScreenState extends ConsumerState<ImageImportScreen> {
  bool _isImageSelected = false;
  bool _isConverting = false;
  double _conversionProgress = 0;
  final _widthController = TextEditingController(text: '16');
  final _heightController = TextEditingController(text: '16');
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _pickImage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выбрать изображение'),
        content: const Text('В реальном приложении откроется галерея'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _isImageSelected = true;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Изображение загружено')),
              );
            },
            child: const Text('Загрузить'),
          ),
        ],
      ),
    );
  }

  Future<void> _startConversion() async {
    final width = int.tryParse(_widthController.text);
    final height = int.tryParse(_heightController.text);
    final name = _nameController.text.trim();

    if (width == null || width <= 0 || width > 256) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ширина должна быть от 1 до 256')),
      );
      return;
    }

    if (height == null || height <= 0 || height > 256) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Высота должна быть от 1 до 256')),
      );
      return;
    }

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите название изображения')),
      );
      return;
    }

    setState(() {
      _isConverting = true;
      _conversionProgress = 0;
    });

    for (int i = 0; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 15));
      if (mounted) {
        setState(() {
          _conversionProgress = i / 100;
        });
      }
    }

    final user = ref.read(authProvider).user;
    if (user != null && mounted) {
      try {
        final grid = List.generate(
          height,
          (y) => List.generate(
            width,
            (x) => ImageMapper.fromFlutterColor(
              Colors.primaries[(x + y) % Colors.primaries.length],
            ),
          ),
        );

        final image = HexImage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: name,
          description: 'Импортированное изображение',
          width: width,
          height: height,
          data: grid,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          userId: user.id,
        );

        await ref.read(imageProvider.notifier).createImage(image);

        if (mounted) {
          setState(() {
            _isConverting = false;
          });

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Конвертация завершена'),
              content: Text('Изображение "$name" успешно создано'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } on AppFailure catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ошибка при создании изображения')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isConverting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Импорт изображения'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: InkWell(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: !_isImageSelected
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_search,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Нажмите для загрузки изображения',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'PNG, JPG до 1 МБ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          )
                        : Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.image,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: IconButton(
                                  onPressed: _pickImage,
                                  icon: const Icon(Icons.edit),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Название изображения',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Введите название',
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Размер сетки для конвертации',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Ширина (1-256)'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _widthController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            hintText: '16',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Высота (1-256)'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _heightController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            hintText: '16',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Параметры конвертации',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Сохранять пропорции'),
                subtitle: const Text('Масштабирование с сохранением соотношения сторон'),
                value: true,
                onChanged: (value) {},
              ),
              const SizedBox(height: 24),
              if (_isConverting) ...[
                const Text(
                  'Конвертация в процессе...',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _conversionProgress,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(_conversionProgress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isImageSelected && !_isConverting
                          ? () => Navigator.pop(context)
                          : null,
                      child: const Text('Отмена'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isImageSelected && !_isConverting
                          ? _startConversion
                          : null,
                      icon: _isConverting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.check),
                      label: const Text('Конвертировать'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}