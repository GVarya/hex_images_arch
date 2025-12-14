import 'package:equatable/equatable.dart';

import 'color.dart';

class HexImage extends Equatable {
  final String id;
  final String title;
  final String? description;
  final int width;
  final int height;
  final List<List<AppColor>> data;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;

  const HexImage({
    required this.id,
    required this.title,
    this.description,
    required this.width,
    required this.height,
    required this.data,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
  });

  bool get isLarge => width > 64 || height > 64;
  bool get isStandard => width <= 32 && height <= 32;
  int get pixelCount => width * height;

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    width,
    height,
    data,
    createdAt,
    updatedAt,
    userId,
  ];

  HexImage copyWith({
    String? id,
    String? title,
    String? description,
    int? width,
    int? height,
    List<List<AppColor>>? data,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
  }) {
    return HexImage(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      width: width ?? this.width,
      height: height ?? this.height,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
    );
  }

  HexImage.empty({
    required String userId,
    String title = 'Новый проект',
    int width = 16,
    int height = 16,
  }) : this(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    title: title,
    description: null,
    width: width,
    height: height,
    data: List.generate(
      height,
          (y) => List.generate(width, (x) => AppColor.white),
    ),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    userId: userId,
  );
}