import 'package:blueprint/blueprint/models/node_style.dart';
import 'package:blueprint/blueprint/models/position.dart';
import 'package:blueprint/blueprint/widgets/node_widget.dart';
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

  /// 节点样式
  NodeStyle get style;
  
  /// 创建节点实例
  NodeData createNode({
    required String id,
    required Position position,
  });

  /// 构建标题栏
  Widget? buildTitle(BuildContext context, NodeData node, NodeWidget widget) {
    return Container(
      padding: style.padding,
      decoration: BoxDecoration(
        color: style.borderColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(style.borderRadius),
          topRight: Radius.circular(style.borderRadius),
        ),
      ),
      child: Text(
        node.title,
        style: style.titleStyle,
      ),
    );
  }
  
  /// 构建节点内容
  Widget? buildContent(BuildContext context, NodeData node, NodeWidget widget);
} 