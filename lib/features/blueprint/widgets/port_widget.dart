import 'package:blueprint/core/models/position.dart';
import 'package:flutter/material.dart';
import '../models/node.dart';

/// 端口组件
class PortWidget extends StatefulWidget {
  /// 端口
  final NodePort port;
  /// 是否是输入端口
  final bool isInput;
  /// 文本样式
  final TextStyle textStyle;
  /// 端口拖拽开始回调
  final Function(NodePort, Offset)? onPortDragStart;
  /// 端口拖拽更新回调
  final Function(Offset)? onPortDragUpdate;
  /// 端口拖拽结束回调
  final Function()? onPortDragEnd;
  /// 端口进入回调
  final Function(NodePort)? onPortEnter;
  /// 缩放比例
  final double scale;
  /// 偏移量
  final Offset offset;
  /// 端口位置
  final Position position;

  const PortWidget({
    super.key,
    required this.port,
    required this.isInput,
    required this.textStyle,
    required this.scale,
    required this.offset,
    required this.position,
    this.onPortDragStart,
    this.onPortDragUpdate,
    this.onPortDragEnd,
    this.onPortEnter,
  });

  @override
  State<PortWidget> createState() => _PortWidgetState();
}

/// 端口组件状态
class _PortWidgetState extends State<PortWidget> {
  /// 端口键
  final GlobalKey _portKey = GlobalKey();

  void _updatePortPosition() {
    if (_portKey.currentContext != null) {
      final RenderBox box = _portKey.currentContext!.findRenderObject() as RenderBox;
      final Offset localPosition = box.localToGlobal(Offset.zero);
      widget.port.updatePosition(localPosition);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updatePortPosition();
    });
  }

  @override
  void didUpdateWidget(PortWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当画布或节点位置变化时更新位置
    if (oldWidget.scale != widget.scale || 
        oldWidget.offset != widget.offset ||
        oldWidget.position != widget.position) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updatePortPosition();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!widget.isInput) Text(
            widget.port.label,
            style: widget.textStyle,
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (details) {
              widget.onPortDragStart?.call(widget.port, details.globalPosition);
            },
            onPanUpdate: (details) {
              widget.onPortDragUpdate?.call(details.globalPosition);
            },
            onPanEnd: (_) {
              widget.onPortDragEnd?.call();
            },
            child: MouseRegion(
              onEnter: (_) {
                widget.onPortEnter?.call(widget.port);
              },
              child: Container(
                key: _portKey,
                width: 16,
                height: 16,
                margin: EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: widget.port.color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.port.color,
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
          if (widget.isInput) Text(
            widget.port.label,
            style: widget.textStyle,
          ),
        ],
      ),
    );
  }
} 