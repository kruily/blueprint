import 'dart:ui';

import 'package:flutter/material.dart';

/// 连接绘制器
class ConnectionPainter extends CustomPainter {
  /// 起始点
  final Offset start;
  /// 结束点
  final Offset end;
  /// 颜色
  final Color color;
  /// 是否虚线
  final bool isDashed;
  /// 张力
  final double tension;

  const ConnectionPainter({
    required this.start,
    required this.end,
    this.color = Colors.blue,
    this.isDashed = false,
    this.tension = 0.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 打印调试信息

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    if (isDashed) {
      paint.strokeWidth = 1.5;
      paint.shader = null;
    } else {
      paint.shader = LinearGradient(
        colors: [color, color.withOpacity(0.7)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromPoints(start, end));
    }

    final path = Path();
    path.moveTo(start.dx, start.dy);

    // 使用更简单的贝塞尔曲线
    final midX = (start.dx + end.dx) / 2;
    path.cubicTo(
      midX, start.dy,  // 第一个控制点
      midX, end.dy,    // 第二个控制点
      end.dx, end.dy   // 终点
    );

    if (isDashed) {
      // 简化虚线绘制
      final dashPath = Path();
      const dashWidth = 5.0;
      const dashSpace = 5.0;
      double distance = 0.0;
      bool draw = true;

      final PathMetric pathMetric = path.computeMetrics().first;
      while (distance < pathMetric.length) {
        final double len = draw ? dashWidth : dashSpace;
        if (distance + len > pathMetric.length) {
          dashPath.addPath(
            pathMetric.extractPath(distance, pathMetric.length),
            Offset.zero,
          );
          break;
        }
        if (draw) {
          dashPath.addPath(
            pathMetric.extractPath(distance, distance + len),
            Offset.zero,
          );
        }
        distance += len;
        draw = !draw;
      }
      canvas.drawPath(dashPath, paint);
    } else {
      canvas.drawPath(path, paint);
    }

    // 绘制端点
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(start, 3, dotPaint);
    canvas.drawCircle(end, 3, dotPaint);
  }

  @override
  bool shouldRepaint(ConnectionPainter oldDelegate) {
    return oldDelegate.start != start ||
           oldDelegate.end != end ||
           oldDelegate.color != color ||
           oldDelegate.isDashed != isDashed;
  }
} 