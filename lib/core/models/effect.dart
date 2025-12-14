import 'package:equatable/equatable.dart';

class Effect extends Equatable {
  final String id;
  final String name;
  final String description;
  final int colorValue;

  const Effect({
    required this.id,
    required this.name,
    required this.description,
    required this.colorValue,
  });

  @override
  List<Object?> get props => [id, name, description, colorValue];
}