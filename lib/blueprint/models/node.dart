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
  /// 端口位置
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
  /// 节点位置
  Position position;
  /// 节点输入端口
  final List<NodePort> inputs;
  /// 节点输出端口
  final List<NodePort> outputs;
  /// 节点数据
  final Map<String, dynamic> data;

  NodeData({
    required this.id,
    required this.type,
    required this.title,
    required this.position,
    this.inputs = const [],
    this.outputs = const [],
    this.data = const {},
  });

  /// 复制节点
  NodeData copyWith({
    String? id,
    String? type,
    String? title,
    Position? position,
    List<NodePort>? inputs,
    List<NodePort>? outputs,
    Map<String, dynamic>? data,
  }) {
    return NodeData(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      position: position ?? this.position,
      inputs: inputs ?? this.inputs,
      outputs: outputs ?? this.outputs,
      data: data ?? this.data,
    );
  }

  /// 更新指定端口的位置
  void updatePortPosition(String portId, Offset position) {
    // 查找并更新输入端口
    final inputIndex = inputs.indexWhere((p) => p.id == portId);
    if (inputIndex != -1) {
      inputs[inputIndex] = inputs[inputIndex].copyWith(position: position);
      return;
    }
    
    // 查找并更新输出端口
    final outputIndex = outputs.indexWhere((p) => p.id == portId);
    if (outputIndex != -1) {
      outputs[outputIndex] = outputs[outputIndex].copyWith(position: position);
    }
  }

  /// 更新所有端口的位置
  void updatePortsPosition(Position displayPosition, double scale) {
    // 更新所有端口的位置，使用显示位置
    for (var port in [...inputs, ...outputs]) {
      final portOffset = port.type == PortType.input 
          ? Offset(24.0, 32.0 + inputs.indexOf(port) * 24.0)
          : Offset(176.0, 32.0 + outputs.indexOf(port) * 24.0);
      
      port.updatePosition(Offset(
        displayPosition.x + portOffset.dx * scale,
        displayPosition.y + portOffset.dy * scale,
      ));
    }
  }

  /// 更新节点位置
  void updatePosition(Position newPosition) {
    position = newPosition;
  }
} 