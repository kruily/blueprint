/// 位置数据模型
class Position {
  final double x;
  final double y;

  const Position(this.x, this.y);

  Position operator +(Position other) => Position(x + other.x, y + other.y);
  Position operator -(Position other) => Position(x - other.x, y - other.y);
} 