class Area {
  /// 区域位置
  Position position;
  /// 区域宽度
  final double width;
  /// 区域高度
  final double height;

  Area({
    this.position = const Position(0, 0),
    this.width = 0,
    this.height = 0,
  });

  /// 获取区域中心点
  Position getCenter() {
    return Position(position.x + width / 2, position.y + height / 2);
  }
}

/// 位置数据模型
class Position {
  final double x;
  final double y;

  const Position(this.x, this.y);

  Position operator +(Position other) => Position(x + other.x, y + other.y);
  Position operator -(Position other) => Position(x - other.x, y - other.y);
} 