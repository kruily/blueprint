import 'package:flutter/material.dart';

/// 网格绘制器
class GridPainter extends CustomPainter {
  final double scale;
  final Offset offset;
  
  GridPainter({
    required this.scale,
    required this.offset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1;

    // 计算网格大小
    const gridSize = 20.0;
    final scaledGridSize = gridSize * scale;
    
    // 计算需要绘制的网格线数量
    final horizontalLines = (size.height / scaledGridSize).ceil();
    final verticalLines = (size.width / scaledGridSize).ceil();

    // 绘制横线
    for (var i = 0; i <= horizontalLines; i++) {
      final y = i * scaledGridSize + offset.dy % scaledGridSize;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // 绘制竖线
    for (var i = 0; i <= verticalLines; i++) {
      final x = i * scaledGridSize + offset.dx % scaledGridSize;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) {
    return oldDelegate.scale != scale || oldDelegate.offset != offset;
  }
} 