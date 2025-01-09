import 'package:flutter/material.dart';
import '../models/node.dart';

class ConnectionPainter extends CustomPainter {
  final NodePort startPort;
  final NodePort endPort;
  final double scale;
  final bool isSelected;

  ConnectionPainter({
    required this.startPort,
    required this.endPort,
    this.scale = 1.0,
    this.isSelected = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isSelected ? Colors.blue : Colors.blue.withOpacity(0.6)
      ..strokeWidth = isSelected ? 3.0 : 2.0
      ..style = PaintingStyle.stroke;

    final start = Offset(
      startPort.area.position.x + startPort.area.width / 2,
      startPort.area.position.y + startPort.area.height / 2,
    );
    
    final end = Offset(
      endPort.area.position.x + endPort.area.width / 2,
      endPort.area.position.y + endPort.area.height / 2,
    );

    // 绘制贝塞尔曲线
    final controlPoint1 = Offset(
      start.dx + (end.dx - start.dx) * 0.5,
      start.dy,
    );
    final controlPoint2 = Offset(
      start.dx + (end.dx - start.dx) * 0.5,
      end.dy,
    );

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        end.dx,
        end.dy,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ConnectionPainter oldDelegate) => true;
}

class DraggingConnectionPainter extends CustomPainter {
  final NodePort startPort;
  final Offset currentPosition;
  final double scale;

  DraggingConnectionPainter({
    required this.startPort,
    required this.currentPosition,
    this.scale = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.5)  // 半透明
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final start = Offset(
      startPort.area.position.x + startPort.area.width / 2,
      startPort.area.position.y + startPort.area.height / 2,
    );

    // 绘制贝塞尔曲线
    final controlPoint1 = Offset(
      start.dx + (currentPosition.dx - start.dx) * 0.5,
      start.dy,
    );
    final controlPoint2 = Offset(
      start.dx + (currentPosition.dx - start.dx) * 0.5,
      currentPosition.dy,
    );

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        currentPosition.dx,
        currentPosition.dy,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(DraggingConnectionPainter oldDelegate) => true;
} 