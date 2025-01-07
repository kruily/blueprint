import 'package:blueprint/core/models/position.dart';
import 'package:flutter/material.dart';
import '../models/node.dart';
import '../models/node_style.dart';
import '../widgets/port_widget.dart';

/// 节点组件
class NodeWidget extends StatefulWidget {
  /// 节点数据
  final NodeData data;
  /// 节点样式
  final NodeStyle style;
  /// 选中回调
  final VoidCallback? onSelected;
  /// 是否选中
  final bool isSelected;
  /// 拖拽更新回调
  final Function(Offset)? onDragUpdate;
  /// 拖拽结束回调
  final VoidCallback? onDragEnd;
  /// 端口拖拽开始回调
  final Function(NodeData, NodePort, Offset)? onPortDragStart;
  /// 端口拖拽更新回调
  final Function(Offset)? onPortDragUpdate;
  /// 端口拖拽结束回调
  final Function()? onPortDragEnd;
  /// 缩放比例
  final double scale;
  /// 偏移量
  final Offset offset;
  /// 节点位置
  final Position position;

  const NodeWidget({
    super.key,
    required this.data,
    this.style = const NodeStyle(),
    this.onSelected,
    this.isSelected = false,
    this.onDragUpdate,
    this.onDragEnd,
    this.onPortDragStart,
    this.onPortDragUpdate,
    this.onPortDragEnd,
    this.scale = 1.0,
    this.offset = Offset.zero,
    required this.position,
  });

  @override
  State<NodeWidget> createState() => _NodeWidgetState();
}

/// 节点组件状态
class _NodeWidgetState extends State<NodeWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onSelected,
      onPanUpdate: (details) {
        widget.onDragUpdate?.call(details.delta);
      },
      onPanEnd: (_) => widget.onDragEnd?.call(),
      child: Container(
        width: widget.style.width,
        height: widget.style.height,
        decoration: BoxDecoration(
          color: widget.style.backgroundColor,
          borderRadius: BorderRadius.circular(widget.style.borderRadius),
          border: Border.all(
            color: widget.isSelected ? Colors.blue : widget.style.borderColor,
            width: widget.style.borderWidth,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 标题栏
            Container(
              padding: widget.style.padding,
              decoration: BoxDecoration(
                color: widget.style.borderColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(widget.style.borderRadius),
                  topRight: Radius.circular(widget.style.borderRadius),
                ),
              ),
              child: Text(
                widget.data.title,
                style: widget.style.titleStyle,
              ),
            ),
            // 内容区域
            Expanded(
              child: Padding(
                padding: widget.style.padding,
                child: Row(
                  children: [
                    // 输入端口列表
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.data.inputs.map((port) => 
                        _buildPort(port, true),
                      ).toList(),
                    ),
                    // 中间内容
                    Expanded(
                      child: Center(
                        child: Text('+', style: TextStyle(fontSize: 20)),
                      ),
                    ),
                    // 输出端口列表
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: widget.data.outputs.map((port) => 
                        _buildPort(port, false),
                      ).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建端口
  Widget _buildPort(NodePort port, bool isInput) {
    return PortWidget(
      port: port,
      isInput: isInput,
      textStyle: widget.style.titleStyle.copyWith(fontSize: 11),
      scale: widget.scale,
      offset: widget.offset,
      position: widget.position,
      onPortDragStart: (port, position) {
        widget.onPortDragStart?.call(widget.data, port, position);
      },
      onPortDragUpdate: widget.onPortDragUpdate,
      onPortDragEnd: widget.onPortDragEnd,
      onPortEnter: (port) {
        print('Port entered: ${port.id} at position: ${port.position}');
      },
    );
  }
} 