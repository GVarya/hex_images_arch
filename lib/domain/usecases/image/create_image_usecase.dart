import '../../../core/failure/app_failure.dart';
import '../../../core/models/hex_image.dart';
import '../../interfaces/repositories/image_repository.dart';

class CreateImageUseCase {
  final ImageRepository repository;

  CreateImageUseCase(this.repository);

  Future<String> execute(HexImage image) async {
    if (image.title.isEmpty) {
      throw ValidationFailure('Название изображения не может быть пустым');
    }

    if (image.width <= 0 || image.width > 256) {
      throw ValidationFailure('Ширина должна быть от 1 до 256');
    }

    if (image.height <= 0 || image.height > 256) {
      throw ValidationFailure('Высота должна быть от 1 до 256');
    }

    try {
      return await repository.createImage(image);
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw ImageFailure('Ошибка создания изображения: $e');
    }
  }
}