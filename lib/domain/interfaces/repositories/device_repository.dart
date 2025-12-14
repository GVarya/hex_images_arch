import '../../../core/models/device.dart';

abstract class DeviceRepository {
  Future<List<Device>> getSavedDevices();
  Future<List<Device>> scanForDevices();
  Future<void> saveDevice(Device device);
  Future<void> deleteDevice(String deviceId);
  Future<void> connectToDevice(String deviceId);
  Future<void> disconnectFromDevice(String deviceId);
  Stream<List<Device>> get devicesStream;
}