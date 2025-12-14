import 'dart:async';
import '../../../core/models/device.dart';

class DeviceLocalDataSource {
  final List<Device> _devices = [
    Device(
      id: '1',
      name: 'Hexagon Display 1',
      macAddress: 'AA:BB:CC:DD:EE:01',
      width: 16,
      height: 16,
      isConnected: false,
    ),
    Device(
      id: '2',
      name: 'Hexagon Display 2',
      macAddress: 'AA:BB:CC:DD:EE:02',
      width: 32,
      height: 32,
      isConnected: false,
    ),
  ];

  final StreamController<List<Device>> _devicesController =
  StreamController<List<Device>>.broadcast();

  Future<List<Device>> getSavedDevices() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_devices);
  }

  Future<List<Device>> scanForDevices() async {
    await Future.delayed(const Duration(seconds: 2));

    final foundDevices = [
      Device(
        id: '3',
        name: 'Hexagon Display NEW',
        macAddress: 'AA:BB:CC:DD:EE:FF',
        width: 24,
        height: 24,
        isConnected: false,
      ),
      Device(
        id: '4',
        name: 'LED Panel Pro',
        macAddress: 'AA:BB:CC:DD:EE:AA',
        width: 20,
        height: 20,
        isConnected: false,
      ),
    ];

    return foundDevices;
  }

  Future<void> saveDevice(Device device) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!_devices.any((d) => d.macAddress == device.macAddress)) {
      _devices.add(device);
      _devicesController.add(List.from(_devices));
    }
  }

  Future<void> deleteDevice(String deviceId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _devices.removeWhere((d) => d.id == deviceId);
    _devicesController.add(List.from(_devices));
  }

  Future<void> updateDeviceConnection(String deviceId, bool isConnected) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _devices.indexWhere((d) => d.id == deviceId);
    if (index != -1) {
      _devices[index] = _devices[index].copyWith(isConnected: isConnected);
      _devicesController.add(List.from(_devices));
    }
  }

  Stream<List<Device>> get devicesStream => _devicesController.stream;

  void dispose() {
    _devicesController.close();
  }
}