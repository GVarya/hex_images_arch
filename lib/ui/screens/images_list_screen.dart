import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/hex_image.dart';
import '../providers/auth_provider.dart';
import '../providers/image_provider.dart';
import '../widgets/image_item.dart';
import 'image_editor_screen.dart';
import 'image_preview_screen.dart';

class ImagesListScreen extends ConsumerStatefulWidget {
  const ImagesListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ImagesListScreen> createState() => _ImagesListScreenState();
}

class _ImagesListScreenState extends ConsumerState<ImagesListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadImages();
    });
  }

  Future<void> _loadImages() async {
    final user = ref.read(authProvider).user;
    if (user != null) {
      await ref.read(imageProvider.notifier).loadUserImages(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final imageState = ref.watch(imageProvider);
    final user = authState.user;
    final images = imageState.images;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Пользователь не авторизован')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои проекты'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: imageState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : images.isEmpty
          ? _buildEmptyState(context)
          : RefreshIndicator(
        onRefresh: () => _loadImages(),
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: images.length,
          itemBuilder: (context, index) {
            final image = images[index];
            return ImageItem(
              image: image,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImageEditorScreen(
                      imageId: image.id,
                    ),
                  ),
                );
              },
              onPreview: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImagePreviewScreen(
                      projectName: image.title,
                      gridWidth: image.width,
                      gridHeight: image.height,
                    ),
                  ),
                );
              },
              onDelete: () {
                _showDeleteDialog(context, image);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ImageEditorScreen(imageId: null),
            ),
          );
        },
        tooltip: 'Создать изображение',
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, HexImage image) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить изображение?'),
        content: Text(
          'Вы уверены, что хотите удалить изображение "${image.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(imageProvider.notifier).deleteImage(image.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${image.title} удалено')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ошибка удаления')),
                );
              }
            },
            child: const Text(
              'Удалить',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.hexagon_outlined,
                size: 80,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 20),
              Text(
                'У вас пока нет изображений',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Создайте первое изображение или импортируйте из файла',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ImageEditorScreen(imageId: null),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Создать изображение'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}