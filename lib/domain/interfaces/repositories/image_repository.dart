import '../../../core/models/hex_image.dart';

abstract class ImageRepository {
  Future<List<HexImage>> getUserImages(String userId);
  Future<HexImage?> getImageById(String id);
  Future<String> createImage(HexImage image);
  Future<void> updateImage(HexImage image);
  Future<void> deleteImage(String id);
  Stream<List<HexImage>> get imagesStream;
}