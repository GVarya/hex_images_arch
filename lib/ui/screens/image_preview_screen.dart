import 'package:flutter/material.dart';

class ImagePreviewScreen extends StatefulWidget {
  final String? projectName;
  final int gridWidth;
  final int gridHeight;

  const ImagePreviewScreen({
    Key? key,
    this.projectName,
    this.gridWidth = 16,
    this.gridHeight = 16,
  }) : super(key: key);

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  late List<List<Color>> _previewGrid;
  String _selectedDeviceId = '1';
  bool _isSending = false;
  double _sendProgress = 0;

  final List<DeviceOption> _connectedDevices = [
    DeviceOption(
      id: '1',
      name: 'Hexagon Display 1',
      width: 16,
      height: 16,
    ),
    DeviceOption(
      id: '2',
      name: 'Hexagon Display 2',
      width: 32,
      height: 32,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _generatePreview();
  }

  void _generatePreview() {
    setState(() {
      _previewGrid = List.generate(
        widget.gridHeight,
            (y) => List.generate(
          widget.gridWidth,
              (x) {
            final random = (x + y) % 3;
            if (random == 0) return Colors.blue.shade300;
            if (random == 1) return Colors.purple.shade200;
            return Colors.pink.shade200;
          },
        ),
      );
    });
  }

  Future<void> _sendToDevice() async {
    setState(() {
      _isSending = true;
      _sendProgress = 0;
    });

    for (int i = 0; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 15));
      if (mounted) {
        setState(() {
          _sendProgress = i / 100;
        });
      }
    }

    if (mounted) {
      setState(() {
        _isSending = false;
        _sendProgress = 1.0;
      });

      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Успешно!'),
        content: const Text(
          'Изображение отправлено на устройство и отображается на экране',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedDevice = _connectedDevices.firstWhere(
          (d) => d.id == _selectedDeviceId,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectName ?? 'Предпросмотр'),
        elevation: 0,
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(6),
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widget.gridWidth,
                  crossAxisSpacing: 0.5,
                  mainAxisSpacing: 0.5,
                ),
                itemCount: widget.gridWidth * widget.gridHeight,
                itemBuilder: (context, index) {
                  final x = index % widget.gridWidth;
                  final y = index ~/ widget.gridWidth;

                  return Container(
                    decoration: BoxDecoration(
                      color: _previewGrid[y][x],
                      border: Border.all(
                        color: Colors.grey[200]!,
                        width: 0.3,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Размер: ${widget.gridWidth}×${widget.gridHeight}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _generatePreview,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Обновить'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    backgroundColor: Colors.blue.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Text(
              'Информация',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Проект:',
              widget.projectName ?? 'Без названия',
            ),
            _buildInfoRow(
              'Размер:',
              '${widget.gridWidth}×${widget.gridHeight} пикселей',
            ),
            _buildInfoRow(
              'Элементов:',
              '${widget.gridWidth * widget.gridHeight}',
            ),
            _buildInfoRow(
              'Размер файла:',
              '~${(widget.gridWidth * widget.gridHeight * 3 / 1024).toStringAsFixed(1)} КБ',
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Text(
              'Целевое устройство',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            if (_connectedDevices.isEmpty)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  border: Border.all(color: Colors.amber[200]!),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.amber[700], size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Нет подключённых устройств',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: DropdownButton<String>(
                  value: _selectedDeviceId,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedDeviceId = value;
                      });
                    }
                  },
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: _connectedDevices.map((device) {
                    return DropdownMenuItem<String>(
                      value: device.id,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              device.name,
                              style: const TextStyle(fontSize: 13),
                            ),
                            Text(
                              '${device.width}×${device.height}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                border: Border.all(color: Colors.blue[100]!),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue[700], size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Устройство: ${selectedDevice.width}×${selectedDevice.height}',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (_isSending) ...[
              const Divider(height: 1),
              const SizedBox(height: 8),
              Text(
                'Отправка на устройство...',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: _sendProgress,
                  minHeight: 6,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation(
                    Colors.blue.shade600,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(_sendProgress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSending ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Вернуться', style: TextStyle(fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _connectedDevices.isEmpty || _isSending
                        ? null
                        : _sendToDevice,
                    icon: _isSending
                        ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(
                          Colors.blue.shade50,
                        ),
                      ),
                    )
                        : const Icon(Icons.send, size: 16),
                    label: const Text('Отправить', style: TextStyle(fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      backgroundColor: Colors.blue.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[900],
              ),
            ),
          ],
        ));
    }
}


class DeviceOption {
  final String id;
  final String name;
  final int width;
  final int height;

  DeviceOption({
    required this.id,
    required this.name,
    required this.width,
    required this.height,
  });
}