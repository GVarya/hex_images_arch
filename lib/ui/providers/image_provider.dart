import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/failure/app_failure.dart';
import '../../core/models/hex_image.dart';
import '../providers/dependencies_provider.dart';

class ImageState {
  final List<HexImage> images;
  final bool isLoading;
  final AppFailure? error;
  final HexImage? selectedImage;

  const ImageState({
    this.images = const [],
    this.isLoading = false,
    this.error,
    this.selectedImage,
  });

  ImageState copyWith({
    List<HexImage>? images,
    bool? isLoading,
    AppFailure? error,
    HexImage? selectedImage,
  }) {
    return ImageState(
      images: images ?? this.images,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedImage: selectedImage ?? this.selectedImage,
    );
  }
}



class ImageNotifier extends StateNotifier<ImageState> {
  final Ref ref;

  ImageNotifier(this.ref) : super(const ImageState()) {
    _subscribeToImages();
  }

  void _subscribeToImages() {
    final repository = ref.read(imageRepositoryProvider);
    repository.imagesStream.listen((images) {
      if (mounted) {
        state = state.copyWith(images: images);
      }
    });
  }

  Future<void> loadUserImages(String userId) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final useCase = ref.read(getUserImagesUseCaseProvider);
      final images = await useCase.execute(userId);
      state = state.copyWith(images: images, isLoading: false);
    } on AppFailure catch (e) {
      state = state.copyWith(error: e, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: const ImageFailure('Неизвестная ошибка'),
        isLoading: false,
      );
    }
  }

  Future<void> createImage(HexImage image) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final useCase = ref.read(createImageUseCaseProvider);
      await useCase.execute(image);
      state = state.copyWith(isLoading: false);
    } on AppFailure catch (e) {
      state = state.copyWith(error: e, isLoading: false);
      rethrow;
    } catch (e) {
      state = state.copyWith(
        error: const ImageFailure('Ошибка создания'),
        isLoading: false,
      );
      rethrow;
    }
  }

  Future<void> updateImage(HexImage image) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final useCase = ref.read(updateImageUseCaseProvider);
      await useCase.execute(image);
      state = state.copyWith(
        isLoading: false,
        selectedImage: image,
      );
    } on AppFailure catch (e) {
      state = state.copyWith(error: e, isLoading: false);
      rethrow;
    } catch (e) {
      state = state.copyWith(
        error: const ImageFailure('Ошибка обновления'),
        isLoading: false,
      );
      rethrow;
    }
  }

  Future<void> deleteImage(String imageId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final useCase = ref.read(deleteImageUseCaseProvider);
      await useCase.execute(imageId);
      state = state.copyWith(isLoading: false);
    } on AppFailure catch (e) {
      state = state.copyWith(error: e, isLoading: false);
      rethrow;
    } catch (e) {
      state = state.copyWith(
        error: const ImageFailure('Ошибка удаления'),
        isLoading: false,
      );
      rethrow;
    }
  }

  void selectImage(HexImage? image) {
    state = state.copyWith(selectedImage: image);
  }

  Future<HexImage?> getImageById(String id) async {
    final repository = ref.read(imageRepositoryProvider);
    return await repository.getImageById(id);
  }
}

final imageProvider = StateNotifierProvider<ImageNotifier, ImageState>((ref) {
  return ImageNotifier(ref);
});