import '../../core/models/device.dart';
import '../../domain/interfaces/repositories/device_repository.dart';
import '../datasources/local/device_local_datasource.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final DeviceLocalDataSource _localDataSource;

  DeviceRepositoryImpl(this._localDataSource);

  @override
  Future<List<Device>> getSavedDevices() async {
    return await _localDataSource.getSavedDevices();
  }

  @override
  Future<List<Device>> scanForDevices() async {
    return await _localDataSource.scanForDevices();
  }

  @override
  Future<void> saveDevice(Device device) async {
    await _localDataSource.saveDevice(device);
  }

  @override
  Future<void> deleteDevice(String deviceId) async {
    await _localDataSource.deleteDevice(deviceId);
  }

  @override
  Future<void> connectToDevice(String deviceId) async {
    await _localDataSource.updateDeviceConnection(deviceId, true);
  }

  @override
  Future<void> disconnectFromDevice(String deviceId) async {
    await _localDataSource.updateDeviceConnection(deviceId, false);
  }

  @override
  Stream<List<Device>> get devicesStream => _localDataSource.devicesStream;
}