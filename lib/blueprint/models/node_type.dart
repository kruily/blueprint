import 'package:blueprint/blueprint/controllers/editor_controller.dart';
import 'package:blueprint/blueprint/models/area.dart';
import 'package:blueprint/blueprint/models/node_style.dart';
import 'package:blueprint/blueprint/widgets/node_widget.dart';
import 'package:flutter/material.dart';
import 'node.dart';

/// 节点类型定义
abstract class NodeType {
  static var unknown;

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

  /// 节点端口
  List<NodePort> get ports => [];

  /// 端口键值对
  Map<String, GlobalKey> get portKeys => {};

  /// 创建节点实例
  NodeData createNode({
    required String id,
    required Position position,
  }) {
    // 创建节点
    final node = NodeData(
      id: id,
      type: typeId,
      title: name,
      ports: ports.map((port) => port.copyWith()).toList(), // 复制端口列表
      area: Area(position: position, width: style.width, height: style.height),
    );

    // 初始化端口位置
    for (var port in node.ports) {
      if (port.type == PortType.input) {
        port.area = Area(
          position: Position(0, port.area.position.y), // 左侧
          width: 12,
          height: 12,
        );
      } else {
        port.area = Area(
          position: Position(style.width, port.area.position.y), // 右侧
          width: 12,
          height: 12,
        );
      }
    }

    return node;
  }

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

  /// 构建节点端口
  Widget? buildPort(
    BuildContext context, 
    NodePort port, 
    GlobalKey key,
    Function(NodePort port) onPortSelected,
    Function(bool isDragging) onPortDragStateChanged,
    Function(NodePort port)? onPortDragStart,
    Function(Offset position)? onPortDragUpdate,
    Function()? onPortDragEnd,
  ) {
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 200),
        tween: Tween<double>(begin: 1.0, end: 1.0),
        builder: (context, double scale, child) {
          return Transform.scale(
            scale: scale,
            child: GestureDetector(
              onTap: () {
                onPortSelected.call(port);
              },
              onPanStart: (details) {
                onPortDragStateChanged(true);
                _dragStartPort = port;
                // 通知编辑器开始拖拽
                onPortDragStart?.call(port);
              },
              onPanUpdate: (details) {
                // 通知编辑器更新拖拽位置
                onPortDragUpdate?.call(details.globalPosition);

                _checkPortsUnderPosition(details.globalPosition, port);
              },
              onPanEnd: (details) {
                onPortDragStateChanged(false);
                _dragStartPort = null;
                // 通知编辑器结束拖拽
                onPortDragEnd?.call();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (port.type == PortType.input) ...[
                    _buildPortDot(port),
                  ],
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      port.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (port.type == PortType.output) ...[
                    _buildPortDot(port),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPortDot(NodePort port) {
    return StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
          onEnter: (_) => setState(() => port.isHovered = true),
          onExit: (_) => setState(() => port.isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: port.isHovered ? port.color.withOpacity(0.8) : port.color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: port.isHovered ? 2 : 1,
              ),
              boxShadow: port.isHovered
                  ? [
                      BoxShadow(
                        color: port.color.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      )
                    ]
                  : null,
            ),
          ),
        );
      },
    );
  }

  NodePort? _dragStartPort; // 添加拖拽开始的端口

  String _findNodeId(NodePort port) {
    for (var node in EditorController().nodes) {
      if (node.ports.contains(port)) {
        return node.id;
      }
    }
    return "unknown";
  }

  void _checkPortsUnderPosition(Offset position, NodePort sourcePort) {
    if (_dragStartPort == null) return;
    
    for (var node in EditorController().nodes) {
      for (var port in node.ports) {
        if (port != sourcePort && _isPositionInPort(position, port)) {
          print("从节点${_findNodeId(_dragStartPort!)}拖拽${_dragStartPort!.id}到节点${node.id}的${port.id}");
        }
      }
    }
  }

  // 检查位置是否在端口区域内
  bool _isPositionInPort(Offset position, NodePort port) {
    final portRect = Rect.fromLTWH(
      port.area.position.x,
      port.area.position.y,
      port.area.width,
      port.area.height,
    );
    return portRect.contains(position);
  }
}
