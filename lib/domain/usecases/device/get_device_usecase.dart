import '../../../core/failure/app_failure.dart';
import '../../../core/models/device.dart';
import '../../interfaces/repositories/device_repository.dart';

class GetDevicesUseCase {
  final DeviceRepository repository;

  GetDevicesUseCase(this.repository);

  Future<List<Device>> execute() async {
    try {
      return await repository.getSavedDevices();
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw DeviceFailure('Ошибка получения устройств: $e');
    }
  }
}