import '../../../core/failure/app_failure.dart';
import '../../../core/models/hex_image.dart';
import '../../interfaces/repositories/image_repository.dart';


class UpdateImageUseCase {
  final ImageRepository repository;

  UpdateImageUseCase(this.repository);

  Future<void> execute(HexImage image) async {
    if (image.id.isEmpty) {
      throw ValidationFailure('ID изображения не может быть пустым');
    }

    if (image.title.isEmpty) {
      throw ValidationFailure('Название изображения не может быть пустым');
    }

    try {
      await repository.updateImage(image.copyWith(updatedAt: DateTime.now()));
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw ImageFailure('Ошибка обновления изображения: $e');
    }
  }
}