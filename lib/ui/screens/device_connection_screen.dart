// lib/presentation/screens/device_connection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/device.dart';
import '../providers/device_provider.dart';

class DeviceConnectionScreen extends ConsumerStatefulWidget {
  const DeviceConnectionScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DeviceConnectionScreen> createState() => _DeviceConnectionScreenState();
}

class _DeviceConnectionScreenState extends ConsumerState<DeviceConnectionScreen> {
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    // Загружаем сохраненные устройства при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(deviceProvider.notifier).loadSavedDevices();
    });
  }

  Future<void> _startScan() async {
    setState(() => _isScanning = true);

    try {
      await ref.read(deviceProvider.notifier).scanDevices();
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceState = ref.watch(deviceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Подключение к устройству'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: deviceState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Доступные устройства',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isScanning ? null : _startScan,
                      icon: _isScanning
                          ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                      )
                          : const Icon(Icons.search),
                      label: Text(
                        _isScanning ? 'Сканирование...' : 'Сканировать устройства',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (deviceState.foundDevices.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Найденные устройства',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    ...deviceState.foundDevices.map((device) => _buildDeviceCard(
                      device: device,
                      onConnect: _connectDevice,
                      onSave: _saveDevice,
                    )),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Сохранённые устройства',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (deviceState.savedDevices.isEmpty)
                    _buildEmptyDevices()
                  else
                    ...deviceState.savedDevices.map((device) => _buildDeviceCard(
                      device: device,
                      onConnect: _connectDevice,
                      onDelete: _deleteDevice,
                      isSaved: true,
                    )),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyDevices() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text('Нет сохранённых устройств'),
      ),
    );
  }

  Future<void> _connectDevice(Device device) async {
    await ref.read(deviceProvider.notifier).toggleDeviceConnection(device.id);
  }

  Future<void> _saveDevice(Device device) async {
    await ref.read(deviceProvider.notifier).saveDevice(device);
  }

  Future<void> _deleteDevice(Device device) async {
    await ref.read(deviceProvider.notifier).deleteDevice(device.id);
  }

  Widget _buildDeviceCard({
    required Device device,
    required Function(Device) onConnect,
    Function(Device)? onSave,
    Function(Device)? onDelete,
    bool isSaved = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        device.macAddress,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Размер: ${device.width}×${device.height}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: device.isConnected
                        ? Colors.green[100]
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    device.isConnected ? 'Подключено' : 'Отключено',
                    style: TextStyle(
                      fontSize: 12,
                      color: device.isConnected
                          ? Colors.green[800]
                          : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => onConnect(device),
                  icon: Icon(
                    device.isConnected ? Icons.link_off : Icons.link,
                  ),
                  label: Text(
                    device.isConnected ? 'Отключить' : 'Подключить',
                  ),
                ),
                if (onSave != null)
                  TextButton.icon(
                    onPressed: () => onSave(device),
                    icon: const Icon(Icons.bookmark_border),
                    label: const Text('Сохранить'),
                  )
                else if (onDelete != null)
                  TextButton.icon(
                    onPressed: () => onDelete(device),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Удалить'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}