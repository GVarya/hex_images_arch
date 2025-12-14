class AppColor {
  final int value;

  const AppColor(this.value);

  int get a => (value >> 24) & 0xFF;
  int get r => (value >> 16) & 0xFF;
  int get g => (value >> 8) & 0xFF;
  int get b => value & 0xFF;

  static const AppColor white = AppColor(0xFFFFFFFF);
  static const AppColor black = AppColor(0xFF000000);
  static const AppColor blue = AppColor(0xFF2196F3);
  static const AppColor red = AppColor(0xFFF44336);
  static const AppColor green = AppColor(0xFF4CAF50);
  static const AppColor transparent = AppColor(0x00000000);

  factory AppColor.fromRGBO(int r, int g, int b, double opacity) {
    final a = (opacity * 255).round();
    return AppColor((a << 24) | (r << 16) | (g << 8) | b);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AppColor &&
              runtimeType == other.runtimeType &&
              value == other.value;

  @override
  int get hashCode => value.hashCode;
}