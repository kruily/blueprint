import 'package:blueprint/blueprint/controllers/connection_layer_controller.dart';
import 'package:flutter/material.dart';
import '../models/node.dart';
import '../models/connection.dart';
import 'connection_painter.dart';

/// 连接层
class ConnectionLayer extends StatefulWidget {
  final ConnectionLayerController controller;
  final List<NodeData> nodes;
  final double scale;
  final Offset offset;
  final Function(NodeData, NodePort, NodePort) onConnectionCreated;

  const ConnectionLayer({
    super.key,
    required this.controller,
    required this.nodes,
    required this.scale,
    required this.offset,
    required this.onConnectionCreated,
  });

  @override
  State<ConnectionLayer> createState() => _ConnectionLayerState();
}

/// 连接层状态
class _ConnectionLayerState extends State<ConnectionLayer> {

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 绘制已存在的连接
        ...widget.controller.connections.map(_buildConnection),

        // 绘制临时连线
        if (widget.controller.dragStartPort != null && widget.controller.dragEndPoint != null)
          Positioned.fill(
            child: CustomPaint(
              painter: ConnectionPainter(
                start: widget.controller.dragStartPort!.position,
                end: widget.controller.dragEndPoint!,
                isDashed: true,
                color: widget.controller.dragStartPort!.color,
              ),
            ),
          ),
      ],
    );
  }

  /// 构建连接
  Widget _buildConnection(Connection connection) {
    try {
      final sourceNode = widget.nodes.firstWhere((node) => node.id == connection.sourceNodeId);
      final targetNode = widget.nodes.firstWhere((node) => node.id == connection.targetNodeId);
      final sourcePort = sourceNode.outputs.firstWhere((port) => port.id == connection.sourcePortId);
      final targetPort = targetNode.inputs.firstWhere((port) => port.id == connection.targetPortId);

      return CustomPaint(
        size: Size.infinite,
        painter: ConnectionPainter(
          start: sourcePort.position,
          end: targetPort.position,
          color: sourcePort.color,
        ),
      );
    } catch (e) {
      return const SizedBox();
    }
  }
} 