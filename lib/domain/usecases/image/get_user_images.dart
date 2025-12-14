import '../../../core/failure/app_failure.dart';
import '../../../core/models/hex_image.dart';
import '../../interfaces/repositories/image_repository.dart';

class GetUserImagesUseCase {
  final ImageRepository repository;

  GetUserImagesUseCase(this.repository);

  Future<List<HexImage>> execute(String userId) async {
    if (userId.isEmpty) {
      throw ValidationFailure('ID пользователя не может быть пустым');
    }

    try {
      return await repository.getUserImages(userId);
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw ImageFailure('Ошибка получения изображений: $e');
    }
  }
}