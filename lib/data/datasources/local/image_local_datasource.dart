import 'dart:async';
import '../../../core/models/hex_image.dart';
import 'mappers/image_mapper.dart';

class ImageLocalDataSource {
  final Map<String, dynamic> _storage = {};
  final StreamController<List<HexImage>> _imagesController =
  StreamController<List<HexImage>>.broadcast();
  final List<HexImage> _images = [];

  ImageLocalDataSource() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final imagesData = _storage['images'] as List? ?? [];
    _images.clear();
    _images.addAll(imagesData.map((data) =>
        ImageMapper.fromMap(data as Map<String, dynamic>)));
    _imagesController.add(List.from(_images));
  }

  Future<void> _saveToStorage() async {
    _storage['images'] = _images.map((img) => ImageMapper.toMap(img)).toList();
    _imagesController.add(List.from(_images));
  }

  Future<List<HexImage>> getUserImages(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _images.where((img) => img.userId == userId).toList();
  }

  Future<HexImage?> getImageById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _images.firstWhere((img) => img.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<String> createImage(HexImage image) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _images.add(image);
    await _saveToStorage();
    return image.id;
  }

  Future<void> updateImage(HexImage image) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _images.indexWhere((img) => img.id == image.id);
    if (index != -1) {
      _images[index] = image;
      await _saveToStorage();
    }
  }

  Future<void> deleteImage(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _images.removeWhere((img) => img.id == id);
    await _saveToStorage();
  }

  Stream<List<HexImage>> get imagesStream => _imagesController.stream;

  void dispose() {
    _imagesController.close();
  }
}