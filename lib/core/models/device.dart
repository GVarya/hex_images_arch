import 'package:equatable/equatable.dart';

class Device extends Equatable {
  final String id;
  final String name;
  final String macAddress;
  final int width;
  final int height;
  final bool isConnected;

  const Device({
    required this.id,
    required this.name,
    required this.macAddress,
    required this.width,
    required this.height,
    required this.isConnected,
  });

  @override
  List<Object?> get props => [id, name, macAddress, width, height, isConnected];

  Device copyWith({
    String? id,
    String? name,
    String? macAddress,
    int? width,
    int? height,
    bool? isConnected,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      macAddress: macAddress ?? this.macAddress,
      width: width ?? this.width,
      height: height ?? this.height,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}