import 'package:blueprint/blueprint/models/area.dart';
import 'package:flutter/material.dart';

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
  /// 端口区域(相对于节点)
  Area area = Area(position: Position(0, 0), width: 0, height: 0);
  /// 是否处于悬停状态
  bool isHovered = false;
  
  NodePort({
    required this.id,
    required this.label,
    required this.type,
    this.color = Colors.blue,
    Area? area,
  }) : area = area ?? Area(position: Position(0, 0), width: 0, height: 0);


  /// 复制连接点
  NodePort copyWith({
    String? id,
    String? label,
    PortType? type,
    Color? color,
    Area? area,
  }) {
    return NodePort(
      id: id ?? this.id,
      label: label ?? this.label,
      type: type ?? this.type,
      color: color ?? this.color,
      area: area ?? this.area,
    );
  }

  /// 更新端口位置
  void updatePosition(Area newArea) {
    area = newArea;
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
  /// 节点端口
  final List<NodePort> ports;
  /// 节点区域
  Area area;

  NodeData({
    required this.id,
    required this.type,
    required this.title,
    this.ports = const [],
    Area? area,
    this.data = const {},
  }) : area = area ?? Area(position: Position(0, 0), width: 0, height: 0);
} 