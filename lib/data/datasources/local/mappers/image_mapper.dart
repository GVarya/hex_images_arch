import 'package:flutter/material.dart';
import '../../../../core/models/color.dart';
import '../../../../core/models/hex_image.dart';

class ImageMapper {
  static Map<String, dynamic> toMap(HexImage image) {
    return {
      'id': image.id,
      'title': image.title,
      'description': image.description,
      'width': image.width,
      'height': image.height,
      'data': _colorsToList(image.data.cast<List<AppColor>>()),
      'createdAt': image.createdAt.toIso8601String(),
      'updatedAt': image.updatedAt.toIso8601String(),
      'userId': image.userId,
    };
  }

  static HexImage fromMap(Map<String, dynamic> map) {
    final data = map['data'];
    List<List<AppColor>> colorGrid = [];

    if (data is List) {
      colorGrid = _listToColors(data);
    }

    return HexImage(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      width: (map['width'] as num).toInt(),
      height: (map['height'] as num).toInt(),
      data: colorGrid,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      userId: map['userId'] as String,
    );
  }

  static Color toFlutterColor(AppColor color) {
    return Color(color.value);
  }

  static AppColor fromFlutterColor(Color color) {
    return AppColor(color.value);
  }

  static List<List<int>> _colorsToList(List<List<AppColor>> colors) {
    return colors.map((row) => row.map((color) => color.value).toList()).toList();
  }

  static List<List<AppColor>> _listToColors(List<dynamic> list) {
    return list.map<List<AppColor>>((row) {
      if (row is List) {
        return row.map<AppColor>((value) {
          if (value is int) {
            return AppColor(value);
          } else if (value is num) {
            return AppColor(value.toInt());
          }
          return AppColor.white;
        }).toList();
      }
      return [AppColor.white];
    }).toList();
  }

  static List<List<AppColor>> createEmptyGrid(int width, int height) {
    return List.generate(
      height,
          (y) => List.generate(width, (x) => AppColor.white),
    );
  }

  static List<List<AppColor>> createTestGrid(int width, int height) {
    return List.generate(
      height,
          (y) => List.generate(
        width,
            (x) {
          final r = (x * 255 ~/ width).clamp(0, 255);
          final g = (y * 255 ~/ height).clamp(0, 255);
          final b = 128;
          return AppColor.fromRGBO(r, g, b, 1.0);
        },
      ),
    );
  }
}