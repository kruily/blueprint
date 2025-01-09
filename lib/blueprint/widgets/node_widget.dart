import 'package:blueprint/blueprint/models/area.dart';
import 'package:blueprint/blueprint/models/node_type.dart';
import 'package:flutter/material.dart';
import '../models/node.dart';

/// 节点组件
class NodeWidget extends StatefulWidget {
  /// 节点数据
  final NodeData data;

  /// 节点类型
  final NodeType nodeType;

  /// 是否选中
  final bool isSelected;

  /// 选中回调
  final Function(NodeWidget node)? onSelected;

  /// 拖拽更新回调
  final Function(NodeWidget node, Offset offset)? onDragUpdate;

  /// 拖拽结束回调
  final Function(NodeWidget node)? onDragEnd;

  /// 端口选中回调
  final Function(NodePort port)? onPortSelected;

  /// 端口键值对
  final Map<String, GlobalKey> portKeys;

  /// 端口位置更新回调
  final Function(List<NodePort> ports)? onPortPositionsUpdated;

  /// 端口拖拽开始回调
  final Function(NodePort port)? onPortDragStart;

  /// 端口拖拽更新回调
  final Function(Offset position)? onPortDragUpdate;

  /// 端口拖拽结束回调
  final Function()? onPortDragEnd;

  const NodeWidget({
    super.key,
    required this.nodeType,
    required this.data,
    required this.portKeys,
    this.onSelected,
    this.isSelected = false,
    this.onDragUpdate,
    this.onDragEnd,
    this.onPortSelected,
    this.onPortPositionsUpdated,
    this.onPortDragStart,
    this.onPortDragUpdate,
    this.onPortDragEnd,
  });

  @override
  State<NodeWidget> createState() => _NodeWidgetState();
}

/// 节点组件状态
class _NodeWidgetState extends State<NodeWidget> {
  bool _isDraggingPort = false;

  @override
  void initState() {
    super.initState();
    // 使用 addPostFrameCallback 确保在布局完成后执行
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateNodePositions();
      _updatePortPositions();
    });
  }

  @override
  void didUpdateWidget(NodeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当节点位置、缩放等发生变化时更新端口位置
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateNodePositions();
      _updatePortPositions();
    });
  }

  /// 更新节点位置
  void _updateNodePositions() {
    final key = widget.key as GlobalKey;
    if (key.currentContext != null) {
      final RenderBox renderBox =
          key.currentContext!.findRenderObject() as RenderBox;
      widget.data.area = Area(
          position: Position(renderBox.localToGlobal(Offset.zero).dx,
              renderBox.localToGlobal(Offset.zero).dy),
          width: renderBox.size.width,
          height: renderBox.size.height);
    }
  }

  void _updatePortPositions() {
    for (var port in widget.data.ports) {
      final key = widget.portKeys["${widget.data.id}@${port.id}"];
      if (key?.currentContext != null) {
        final RenderBox renderBox =
            key?.currentContext!.findRenderObject() as RenderBox;
        final position = renderBox.localToGlobal(Offset.zero);
        // 转换为相对于节点的位置
        // final nodeBox = context.findRenderObject() as RenderBox;
        // final nodePosition = nodeBox.localToGlobal(Offset.zero);
        // final relativePosition = position - nodePosition;

        port.area = Area(
          position: Position(position.dx, position.dy),
          width: renderBox.size.width,
          height: renderBox.size.height,
        );
      }
    }

    // 通知位置更新
    widget.onPortPositionsUpdated?.call(widget.data.ports);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: () => widget.onSelected?.call(widget),
            onPanUpdate: (details) {
              // 仅在未拖拽端口时处理节点拖拽
              if (!_isDraggingPort) {
                widget.onDragUpdate?.call(widget, details.delta);
              }
            },
            onPanEnd: (_) => widget.onDragEnd?.call(widget),
            child: Container(
              width: widget.nodeType.style.width,
              height: widget.nodeType.style.height,
              decoration: BoxDecoration(
                color: widget.nodeType.style.backgroundColor,
                borderRadius:
                    BorderRadius.circular(widget.nodeType.style.borderRadius),
                border: Border.all(
                  color: widget.isSelected
                      ? Colors.blue
                      : widget.nodeType.style.borderColor,
                  width: widget.nodeType.style.borderWidth,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 标题
                  widget.nodeType.buildTitle(context, widget.data, widget) ??
                      const SizedBox(),
                  // 内容区域
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 输入端口
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...widget.data.ports
                                .where((port) => port.type == PortType.input)
                                .map((port) =>
                                    widget.nodeType.buildPort(
                                        context,
                                        port,
                                        widget.portKeys[
                                            "${widget.data.id}@${port.id}"]!,
                                        (port) => widget.onPortSelected
                                            ?.call(port),
                                        (isDragging) => setState(() => _isDraggingPort = isDragging),
                                        widget.onPortDragStart,
                                        widget.onPortDragUpdate,
                                        widget.onPortDragEnd) ??
                                    const SizedBox())
                          ],
                        ),
                        // 内容
                        Expanded(
                          child: Padding(
                            padding: widget.nodeType.style.padding,
                            child: widget.nodeType.buildContent(
                                    context, widget.data, widget) ??
                                const SizedBox(),
                          ),
                        ),
                        // 输出端口
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ...widget.data.ports
                                .where((port) => port.type == PortType.output)
                                .map((port) =>
                                    widget.nodeType.buildPort(
                                        context,
                                        port,
                                        widget.portKeys[
                                            "${widget.data.id}@${port.id}"]!,
                                        (port) => widget.onPortSelected
                                            ?.call(port),
                                        (isDragging) => setState(() => _isDraggingPort = isDragging),
                                        widget.onPortDragStart,
                                        widget.onPortDragUpdate,
                                        widget.onPortDragEnd) ??
                                    const SizedBox())
                          ],
                        ),
                      ],
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
