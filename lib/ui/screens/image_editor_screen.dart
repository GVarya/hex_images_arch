import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/color.dart';
import '../../core/models/hex_image.dart';
import '../../data/datasources/local/mappers/image_mapper.dart';
import '../providers/auth_provider.dart';
import '../providers/image_provider.dart';

class ImageEditorScreen extends ConsumerStatefulWidget {
  final String? imageId;

  const ImageEditorScreen({
    Key? key,
    this.imageId,
  }) : super(key: key);

  @override
  ConsumerState<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends ConsumerState<ImageEditorScreen> {
  late HexImage _image;
  late List<List<AppColor>> _grid;
  final _nameController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();

  Color _selectedFlutterColor = Colors.blue;
  AppColor get _selectedColor => ImageMapper.fromFlutterColor(_selectedFlutterColor);
  String _currentTool = 'brush';
  bool _isLoading = false;

  final List<Color> _colorPalette = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.pink,
    Colors.black,
    Colors.white,
    Colors.grey,
    Colors.brown,
  ];

  @override
  void initState() {
    super.initState();
    _initializeImage();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _initializeImage() async {
    setState(() => _isLoading = true);

    final user = ref.read(authProvider).user;
    if (user == null) {
      Navigator.pop(context);
      return;
    }

    if (widget.imageId != null) {
      final image = await ref.read(imageProvider.notifier).getImageById(widget.imageId!);
      if (image != null) {
        _image = image;
        _grid = image.data.cast<List<AppColor>>();
      } else {
        _createNewImage(user.id);
      }
    } else {
      _createNewImage(user.id);
    }

    _nameController.text = _image.title;
    _widthController.text = _image.width.toString();
    _heightController.text = _image.height.toString();

    setState(() => _isLoading = false);
  }

  void _createNewImage(String userId) {
    _image = HexImage.empty(userId: userId);
    _grid = _image.data.cast<List<AppColor>>();
  }

  void _paintCell(int x, int y) {
    if (x < 0 || x >= _image.width || y < 0 || y >= _image.height) return;

    setState(() {
      if (_currentTool == 'eraser') {
        _grid[y][x] = AppColor.white;
      } else {
        _grid[y][x] = _selectedColor;
      }
    });
  }

  void _fillArea(int startX, int startY) {
    if (startX < 0 || startX >= _image.width || startY < 0 || startY >= _image.height) {
      return;
    }

    final targetColor = _grid[startY][startX];
    final fillColor = _currentTool == 'eraser' ? AppColor.white : _selectedColor;

    if (targetColor == fillColor) return;

    final queue = <(int, int)>[];
    queue.add((startX, startY));

    while (queue.isNotEmpty) {
      final (x, y) = queue.removeAt(0);
      if (x < 0 || x >= _image.width || y < 0 || y >= _image.height) continue;
      if (_grid[y][x] != targetColor) continue;

      _grid[y][x] = fillColor;

      queue.add((x + 1, y));
      queue.add((x - 1, y));
      queue.add((x, y + 1));
      queue.add((x, y - 1));
    }

    setState(() {});
  }

  void _clearGrid() {
    setState(() {
      _grid = List.generate(
        _image.height,
            (y) => List.generate(_image.width, (x) => AppColor.white),
      );
    });
  }

  Future<void> _saveImage() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите название изображения')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedImage = _image.copyWith(
        title: name,
        data: _grid,
        updatedAt: DateTime.now(),
      );

      if (widget.imageId != null) {
        await ref.read(imageProvider.notifier).updateImage(updatedImage);
      } else {
        await ref.read(imageProvider.notifier).createImage(updatedImage);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Изображение "$name" сохранено')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка при сохранении')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.imageId != null ? 'Редактировать: ${_image.title}' : 'Новый проект'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveImage,
            tooltip: 'Сохранить',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Название проекта',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Ширина', style: TextStyle(fontSize: 12)),
                          const SizedBox(height: 4),
                          TextField(
                            controller: _widthController,
                            readOnly: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
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
                          const Text('Высота', style: TextStyle(fontSize: 12)),
                          const SizedBox(height: 4),
                          TextField(
                            controller: _heightController,
                            readOnly: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ..._colorPalette.map((color) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFlutterColor = color;
                          _currentTool = 'brush';
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          border: Border.all(
                            color: _selectedFlutterColor == color ? Colors.black : Colors.grey,
                            width: _selectedFlutterColor == color ? 3 : 1,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  )),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => setState(() => _currentTool = 'eraser'),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        border: Border.all(
                          color: _currentTool == 'eraser' ? Colors.black : Colors.grey,
                          width: _currentTool == 'eraser' ? 3 : 1,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.cleaning_services, size: 20),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _currentTool = 'fill'),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        border: Border.all(
                          color: _currentTool == 'fill' ? Colors.black : Colors.grey,
                          width: _currentTool == 'fill' ? 3 : 1,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.format_color_fill, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _image.width,
                  mainAxisSpacing: 1,
                  crossAxisSpacing: 1,
                ),
                itemCount: _image.width * _image.height,
                itemBuilder: (context, index) {
                  final x = index % _image.width;
                  final y = index ~/ _image.width;
                  final cellColor = ImageMapper.toFlutterColor(_grid[y][x]);

                  return GestureDetector(
                    onTap: () {
                      if (_currentTool == 'fill') {
                        _fillArea(x, y);
                      } else {
                        _paintCell(x, y);
                      }
                    },
                    child: Container(
                      color: cellColor,
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clearGrid,
                    child: const Text('Очистить'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveImage,
                    icon: const Icon(Icons.save),
                    label: const Text('Сохранить'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}