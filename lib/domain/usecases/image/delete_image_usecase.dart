import '../../../core/failure/app_failure.dart';
import '../../interfaces/repositories/image_repository.dart';

class DeleteImageUseCase {
  final ImageRepository repository;

  DeleteImageUseCase(this.repository);

  Future<void> execute(String imageId) async {
    if (imageId.isEmpty) {
      throw ValidationFailure('ID изображения не может быть пустым');
    }

    try {
      await repository.deleteImage(imageId);
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw ImageFailure('Ошибка удаления изображения: $e');
    }
  }
}