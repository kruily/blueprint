import 'package:blueprint/blueprint/models/position.dart';
import 'package:flutter/material.dart';
import 'node.dart';

/// 节点类型定义
abstract class NodeType {
  /// 节点类型唯一标识
  String get typeId;
  
  /// 节点类型名称
  String get name;
  
  /// 节点类型描述
  String get description;
  
  /// 节点类型图标
  IconData? get icon;
  
  /// 创建节点实例
  NodeData createNode({
    required String id,
    required Position position,
  });
  
  /// 自定义节点内容构建器
  Widget? buildCustomContent(BuildContext context, NodeData node);
  
  /// 验证节点输入
  bool validateInputs(NodeData node, Map<String, dynamic> inputs) {
    return true;
  }
  
  /// 处理节点逻辑
  Map<String, dynamic>? process(NodeData node, Map<String, dynamic> inputs) {
    return null;
  }
} 