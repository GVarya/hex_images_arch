import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/auth_local_datasource.dart';
import '../../data/datasources/local/image_local_datasource.dart';
import '../../data/datasources/local/device_local_datasource.dart';
import '../../data/datasources/local/effect_local_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/image_repository_impl.dart';
import '../../data/repositories/device_repository_impl.dart';
import '../../data/repositories/effect_repository_impl.dart';
import '../../domain/interfaces/repositories/auth_repository.dart';
import '../../domain/interfaces/repositories/device_repository.dart';
import '../../domain/interfaces/repositories/effect_repository.dart';
import '../../domain/interfaces/repositories/image_repository.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../domain/usecases/device/get_device_usecase.dart';
import '../../domain/usecases/effect/get_effect_usecase.dart';
import '../../domain/usecases/image/create_image_usecase.dart';
import '../../domain/usecases/image/get_user_images.dart';
import '../../domain/usecases/image/update_image_usecase.dart';
import '../../domain/usecases/image/delete_image_usecase.dart';
import '../../domain/usecases/device/scan_devices_usecase.dart';
import 'device_provider.dart';
import 'effects_provider.dart';

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final dataSource = AuthLocalDataSource();
  ref.onDispose(() => dataSource.dispose());
  return dataSource;
});

final imageLocalDataSourceProvider = Provider<ImageLocalDataSource>((ref) {
  final dataSource = ImageLocalDataSource();
  ref.onDispose(() => dataSource.dispose());
  return dataSource;
});

final deviceLocalDataSourceProvider = Provider<DeviceLocalDataSource>((ref) {
  final dataSource = DeviceLocalDataSource();
  ref.onDispose(() => dataSource.dispose());
  return dataSource;
});

final effectLocalDataSourceProvider = Provider<EffectLocalDataSource>((ref) {
  return EffectLocalDataSource();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authLocalDataSourceProvider));
});

final imageRepositoryProvider = Provider<ImageRepository>((ref) {
  return ImageRepositoryImpl(ref.watch(imageLocalDataSourceProvider));
});

final deviceRepositoryProvider = Provider<DeviceRepository>((ref) {
  return DeviceRepositoryImpl(ref.watch(deviceLocalDataSourceProvider));
});

final effectRepositoryProvider = Provider<EffectRepository>((ref) {
  return EffectRepositoryImpl(ref.watch(effectLocalDataSourceProvider));
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.watch(authRepositoryProvider));
});

final getUserImagesUseCaseProvider = Provider<GetUserImagesUseCase>((ref) {
  return GetUserImagesUseCase(ref.watch(imageRepositoryProvider));
});

final createImageUseCaseProvider = Provider<CreateImageUseCase>((ref) {
  return CreateImageUseCase(ref.watch(imageRepositoryProvider));
});

final updateImageUseCaseProvider = Provider<UpdateImageUseCase>((ref) {
  return UpdateImageUseCase(ref.watch(imageRepositoryProvider));
});

final deleteImageUseCaseProvider = Provider<DeleteImageUseCase>((ref) {
  return DeleteImageUseCase(ref.watch(imageRepositoryProvider));
});

final getDevicesUseCaseProvider = Provider<GetDevicesUseCase>((ref) {
  return GetDevicesUseCase(ref.watch(deviceRepositoryProvider));
});

final scanDevicesUseCaseProvider = Provider<ScanDevicesUseCase>((ref) {
  return ScanDevicesUseCase(ref.watch(deviceRepositoryProvider));
});

final getEffectsUseCaseProvider = Provider<GetEffectsUseCase>((ref) {
  return GetEffectsUseCase(ref.watch(effectRepositoryProvider));
});

final deviceProvider = StateNotifierProvider<DeviceNotifier, DeviceState>((ref) {
  return DeviceNotifier(ref);
});

final effectsProvider = StateNotifierProvider<EffectsNotifier, EffectsState>((ref) {
  return EffectsNotifier(ref);
});