import 'package:flutter/material.dart';
import 'position.dart';

/// 节点连接点类型
enum PortType {
  input,    // 输入端口
  output,   // 输出端口
}

/// 节点连接点(端口)
class NodePort {
  /// 端口ID
  final String id;
  /// 端口标签
  final String label;
  /// 端口类型
  final PortType type;
  /// 端口颜色
  final Color color;
  /// 端口位置(相对于节点)
  Offset position = Offset.zero;
  
  NodePort({
    required this.id,
    required this.label,
    required this.type,
    this.color = Colors.blue,
    Offset? position,
  }) {
    if (position != null) {
      this.position = position;
    }
  }

  /// 复制连接点
  NodePort copyWith({
    String? id,
    String? label,
    PortType? type,
    Color? color,
    Offset? position,
  }) {
    return NodePort(
      id: id ?? this.id,
      label: label ?? this.label,
      type: type ?? this.type,
      color: color ?? this.color,
      position: position ?? this.position,
    );
  }

  /// 更新端口位置
  void updatePosition(Offset newPosition) {
    position = newPosition;
  }
}

/// 节点数据模型
class NodeData {
  /// 节点ID
  final String id;
  /// 节点类型
  final String type;
  /// 节点标题
  final String title;
  /// 节点数据
  final Map<String, dynamic> data;
  /// 节点位置
  Position position;

  NodeData({
    required this.id,
    required this.type,
    required this.title,
    required this.position,
    this.data = const {},
  });
} 