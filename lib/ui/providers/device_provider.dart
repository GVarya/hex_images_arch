import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/failure/app_failure.dart';
import '../../core/models/device.dart';
import '../providers/dependencies_provider.dart';

class DeviceState {
  final List<Device> savedDevices;
  final List<Device> foundDevices;
  final bool isLoading;
  final AppFailure? error;

  const DeviceState({
    this.savedDevices = const [],
    this.foundDevices = const [],
    this.isLoading = false,
    this.error,
  });

  DeviceState copyWith({
    List<Device>? savedDevices,
    List<Device>? foundDevices,
    bool? isLoading,
    AppFailure? error,
  }) {
    return DeviceState(
      savedDevices: savedDevices ?? this.savedDevices,
      foundDevices: foundDevices ?? this.foundDevices,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class DeviceNotifier extends StateNotifier<DeviceState> {
  final Ref ref;

  DeviceNotifier(this.ref) : super(const DeviceState()) {
    _subscribeToDevices();
  }

  void _subscribeToDevices() {
    final repository = ref.read(deviceRepositoryProvider);
    repository.devicesStream.listen((devices) {
      if (mounted) {
        state = state.copyWith(savedDevices: devices);
      }
    });
  }

  Future<void> loadSavedDevices() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final useCase = ref.read(getDevicesUseCaseProvider);
      final devices = await useCase.execute();
      state = state.copyWith(savedDevices: devices, isLoading: false);
    } on AppFailure catch (e) {
      state = state.copyWith(error: e, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: const DeviceFailure('Ошибка загрузки устройств'),
        isLoading: false,
      );
    }
  }

  Future<void> scanDevices() async {
    state = state.copyWith(error: null);

    try {
      final useCase = ref.read(scanDevicesUseCaseProvider);
      final devices = await useCase.execute();
      state = state.copyWith(foundDevices: devices);
    } on AppFailure catch (e) {
      state = state.copyWith(error: e);
      rethrow;
    } catch (e) {
      state = state.copyWith(
        error: const DeviceFailure('Ошибка сканирования устройств'),
      );
      rethrow;
    }
  }

  Future<void> toggleDeviceConnection(String deviceId) async {
    try {
      final repository = ref.read(deviceRepositoryProvider);
      final device = state.savedDevices.firstWhere(
            (d) => d.id == deviceId,
        orElse: () => state.foundDevices.firstWhere((d) => d.id == deviceId),
      );

      if (device.isConnected) {
        await repository.disconnectFromDevice(deviceId);
      } else {
        await repository.connectToDevice(deviceId);
      }
    } catch (e) {
      throw const DeviceFailure('Ошибка подключения к устройству');
    }
  }

  Future<void> saveDevice(Device device) async {
    try {
      final repository = ref.read(deviceRepositoryProvider);
      await repository.saveDevice(device);
    } catch (e) {
      throw const DeviceFailure('Ошибка сохранения устройства');
    }
  }

  Future<void> deleteDevice(String deviceId) async {
    try {
      final repository = ref.read(deviceRepositoryProvider);
      await repository.deleteDevice(deviceId);
    } catch (e) {
      throw const DeviceFailure('Ошибка удаления устройства');
    }
  }
}

final deviceProvider = StateNotifierProvider<DeviceNotifier, DeviceState>(
      (ref) => DeviceNotifier(ref),
);