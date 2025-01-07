import 'package:flutter/material.dart';

/// 节点样式配置
class NodeStyle {
  /// 节点宽度
  final double width;
  /// 节点高度
  final double height;
  /// 节点边框圆角
  final double borderRadius;
  /// 节点背景颜色
  final Color backgroundColor;
  /// 节点边框颜色
  final Color borderColor;
  /// 节点边框宽度
  final double borderWidth;
  /// 节点标题样式
  final TextStyle titleStyle;
  /// 节点内边距
  final EdgeInsets padding;
  /// 端口间距
  final double portSpacing;
  /// 端口大小
  final double portSize;

  const NodeStyle({
    this.width = 180,
    this.height = 100,
    this.borderRadius = 4,
    this.backgroundColor = const Color(0xFF2B2B2B),
    this.borderColor = const Color(0xFF454545),
    this.borderWidth = 1,
    this.titleStyle = const TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    this.padding = const EdgeInsets.symmetric(
      horizontal: 8,
      vertical: 6,
    ),
    this.portSpacing = 16,
    this.portSize = 6,
  });
} 