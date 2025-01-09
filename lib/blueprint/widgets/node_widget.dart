import 'package:blueprint/blueprint/models/node_type.dart';
import 'package:blueprint/blueprint/services/node_registry.dart';
import 'package:flutter/material.dart';
import '../models/node.dart';

/// 节点组件
class NodeWidget extends StatefulWidget {
  /// 节点数据
  final NodeData data;
  
  /// 是否选中
  final bool isSelected;
  
  /// 选中回调
  final Function(NodeWidget node)? onSelected;

  /// 拖拽更新回调
  final Function(NodeWidget node, Offset offset)? onDragUpdate;

  /// 拖拽结束回调
  final Function(NodeWidget node)? onDragEnd;


  const NodeWidget({
    super.key,
    required this.data,
    this.onSelected,
    this.isSelected = false,
    this.onDragUpdate,
    this.onDragEnd,
  });

  @override
  State<NodeWidget> createState() => _NodeWidgetState();
}

/// 节点组件状态
class _NodeWidgetState extends State<NodeWidget> {

  @override
  Widget build(BuildContext context) {
    NodeType? nodeType = NodeRegistry().getNodeType(widget.data.type);
    return MouseRegion(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: () => widget.onSelected?.call(widget),
            onPanUpdate: (details) {
              widget.onDragUpdate?.call(widget, details.delta);
            },
            onPanEnd: (_) => widget.onDragEnd?.call(widget),
            child: Container(
              width: nodeType?.style.width,
              height: nodeType?.style.height,
              decoration: BoxDecoration(
                color: nodeType?.style.backgroundColor,
                borderRadius: BorderRadius.circular(nodeType?.style.borderRadius ?? 4),
                border: Border.all(
                  color: widget.isSelected
                      ? Colors.blue
                      : nodeType?.style.borderColor ?? Colors.transparent,
                  width: nodeType?.style.borderWidth ?? 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  nodeType?.buildTitle(context, widget.data, widget) ?? const SizedBox(),
                  Expanded(
                    child: Padding(
                      padding: nodeType?.style.padding ?? EdgeInsets.zero,
                      child: nodeType?.buildContent(context, widget.data, widget) ?? 
                          const SizedBox(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
