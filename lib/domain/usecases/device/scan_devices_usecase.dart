import '../../../core/failure/app_failure.dart';
import '../../../core/models/device.dart';
import '../../interfaces/repositories/device_repository.dart';

class ScanDevicesUseCase {
  final DeviceRepository repository;

  ScanDevicesUseCase(this.repository);

  Future<List<Device>> execute() async {
    try {
      return await repository.scanForDevices();
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw DeviceFailure('Ошибка сканирования устройств: $e');
    }
  }
}