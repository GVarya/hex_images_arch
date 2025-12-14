import '../../core/models/hex_image.dart';
import '../../domain/interfaces/repositories/image_repository.dart';
import '../datasources/local/image_local_datasource.dart';

class ImageRepositoryImpl implements ImageRepository {
  final ImageLocalDataSource _localDataSource;

  ImageRepositoryImpl(this._localDataSource);

  @override
  Future<List<HexImage>> getUserImages(String userId) async {
    return await _localDataSource.getUserImages(userId);
  }

  @override
  Future<HexImage?> getImageById(String id) async {
    return await _localDataSource.getImageById(id);
  }

  @override
  Future<String> createImage(HexImage image) async {
    return await _localDataSource.createImage(image);
  }

  @override
  Future<void> updateImage(HexImage image) async {
    await _localDataSource.updateImage(image);
  }

  @override
  Future<void> deleteImage(String id) async {
    await _localDataSource.deleteImage(id);
  }

  @override
  Stream<List<HexImage>> get imagesStream => _localDataSource.imagesStream;
}