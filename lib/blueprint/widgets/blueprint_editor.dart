import 'dart:math';

import 'package:blueprint/blueprint/controllers/editor_controller.dart';
import 'package:blueprint/blueprint/models/area.dart';
import 'package:blueprint/blueprint/models/node_type.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../controllers/canvas_controller.dart';
import 'grid_painter.dart';
import '../models/node.dart';
import 'node_widget.dart';
import '../services/node_registry.dart';
import 'connection_painter.dart';

/// 蓝图编辑器
class BlueprintEditor extends StatefulWidget {
  const BlueprintEditor({super.key});

  @override
  State<BlueprintEditor> createState() => _BlueprintEditorState();
}

/// 蓝图编辑器状态
class _BlueprintEditorState extends State<BlueprintEditor> {
  /// 画布控制器
  final CanvasController _canvasController = CanvasController();

  /// 编辑器控制器
  final EditorController _ec = EditorController();

  /// 添加临时连接线的状态
  NodePort? _draggingPort;
  Offset? _currentDragPosition;

  @override
  void initState() {
    super.initState();
    _ec.setNodes([
      NodeRegistry().getNodeType('text')?.createNode(
                id: 'text_node',
                position: const Position(100, 100),
              ) ??
          NodeData(
            id: 'text_node',
            type: 'text',
            title: '文本节点',
          ),
      NodeRegistry().getNodeType('math.add')?.createNode(
                id: '1',
                position: const Position(100, 100),
              ) ??
          NodeData(
            id: '1',
            type: 'math.add',
            title: '加法节点',
          ),
      NodeRegistry().getNodeType('math.add')?.createNode(
                id: '2',
                position: const Position(200, 100),
              ) ??
          NodeData(
            id: '2',
            type: 'math.add',
            title: '加法节点',
          ),
    ]);
  }

  // 处理节点拖拽
  void _handleNodeDrag(String nodeId, Offset delta) {
    if (_ec.editorState != EditorState.idle &&
        _ec.editorState != EditorState.draggingNode) return;

    setState(() {
      final scaledDelta = delta / _canvasController.scale;
      _ec.updateNodePosition(nodeId, scaledDelta);
      _ec.setEditorState(EditorState.draggingNode);
    });
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      // 处理缩放
      if (details.scale != 1.0) {
        final newScale = _canvasController.scale * details.scale;
        if (newScale >= 0.1 && newScale <= 5.0) {
          _canvasController.updateScale(newScale);
        }
      }
      
      // 处理平移 - 恢复原来的代码
      final newOffset = Position(
        _canvasController.offset.x + details.focalPointDelta.dx / _canvasController.scale,
        _canvasController.offset.y + details.focalPointDelta.dy / _canvasController.scale,
      );
      _canvasController.updateOffset(newOffset);
      
      _ec.setEditorState(EditorState.panning);
    });
  }

  /// 处理缩放开始
  void _handleScaleStart(ScaleStartDetails details) {
    setState(() {
      _ec.setEditorState(EditorState.panning);
    });
  }

  /// 处理缩放结束
  void _handleScaleEnd(ScaleEndDetails details) {
    setState(() {
      _ec.setEditorState(EditorState.idle);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          // 处理键盘事件
        },
        child: Listener(
          onPointerSignal: (pointerSignal) {
            if (pointerSignal is PointerScrollEvent) {
              setState(() {
                // 计算新的缩放值
                final scaleFactor =
                    pointerSignal.scrollDelta.dy > 0 ? 0.95 : 1.05;
                final newScale = _canvasController.scale * scaleFactor;

                // 限制缩放范围
                if (newScale >= 0.1 && newScale <= 5.0) {
                  // 获取鼠标位置相对于画布的偏移
                  final mousePosition = pointerSignal.position;
                  final oldOffset = Offset(
                      _canvasController.offset.x, _canvasController.offset.y);

                  // 更新缩放
                  _canvasController.updateScale(newScale);

                  // 调整偏移以保持鼠标位置不变
                  final newOffset = Position(
                    oldOffset.dx -
                        (mousePosition.dx * (scaleFactor - 1) / newScale),
                    oldOffset.dy -
                        (mousePosition.dy * (scaleFactor - 1) / newScale),
                  );
                  _canvasController.updateOffset(newOffset);
                }
              });
            }
          },
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onScaleStart: _handleScaleStart,
            onScaleUpdate: _handleScaleUpdate,
            onScaleEnd: _handleScaleEnd,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 背景网格
                CustomPaint(
                  painter: GridPainter(
                    scale: _canvasController.scale,
                    offset: Offset(
                      _canvasController.offset.x,
                      _canvasController.offset.y,
                    ),
                  ),
                ),

                // 暂时注释掉连接线层
                /*
                ..._ec.connections.map((connection) {
                  final startNode = _ec.nodes
                      .firstWhere((node) => node.id == connection.sourceNodeId);
                  final endNode = _ec.nodes
                      .firstWhere((node) => node.id == connection.targetNodeId);
                  final startPort = startNode.ports
                      .firstWhere((port) => port.id == connection.sourcePortId);
                  final endPort = endNode.ports
                      .firstWhere((port) => port.id == connection.targetPortId);

                  return GestureDetector(
                    onTapDown: (details) {
                      // 检查点击是否在连接线上
                      if (_isPointNearConnection(details.globalPosition, startPort, endPort)) {
                        setState(() {
                          // 取消其他连接的选中状态
                          for (var conn in _ec.connections) {
                            conn.isSelected = false;
                          }
                          connection.isSelected = true;
                        });
                      }
                    },
                    child: CustomPaint(
                      painter: ConnectionPainter(
                        startPort: startPort,
                        endPort: endPort,
                        scale: _canvasController.scale,
                        isSelected: connection.isSelected,
                      ),
                    ),
                  );
                }),
                */

                // 临时连接线也暂时注释掉
                /*
                if (_draggingPort != null && _currentDragPosition != null)
                  CustomPaint(
                    painter: DraggingConnectionPainter(
                      startPort: _draggingPort!,
                      currentPosition: _currentDragPosition!,
                      scale: _canvasController.scale,
                    ),
                  ),
                */

                // 节点层
                ..._ec.nodes.map((node) => _buildNode(node)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建节点
  Widget _buildNode(NodeData node) {
    final nodePosition = Offset(
      node.area.position.x * _canvasController.scale + _canvasController.offset.x * _canvasController.scale,
      node.area.position.y * _canvasController.scale + _canvasController.offset.y * _canvasController.scale,
    );
    final nodeKey = _ec.createNodeKey(node.id);
    final portKeys = _ec.createPortKeys(node.id);
    return Positioned(
      left: nodePosition.dx,
      top: nodePosition.dy,
      child: Transform.scale(
        scale: _canvasController.scale,
        child: NodeWidget(
          key: nodeKey,
          portKeys: portKeys,
          data: node,
          // 节点类型
          nodeType: NodeRegistry().getNodeType(node.type) ?? NodeType.unknown,
          // 是否选中
          isSelected: node == _ec.selectedNode,
          // 节点选中回调
          onSelected: (node) => setState(() => print(
              "${node.data.area.position.x}, ${node.data.area.position.y}")),
          // 端口选中回调
          onPortSelected: (port) => setState(
              () => print("${port.area.position.x}, ${port.area.position.y}")),
          // 节点拖拽更新回调
          onDragUpdate: (node, delta) => _handleNodeDrag(node.data.id, delta),
          // 节点拖拽结束回调
          onDragEnd: (node) => _handleNodeDragEnd(),
          // 端口拖拽开始回调
          onPortDragStart: (port) => _handlePortDragStart(port),
          // 端口拖拽更新回调
          onPortDragUpdate: (position) => _handlePortDragUpdate(position),
          // 端口拖拽结束回调
          onPortDragEnd: () => _handlePortDragEnd(),
        ),
      ),
    );
  }

  ///  添加节点拖拽结束的处理
  void _handleNodeDragEnd() {
    setState(() {
      _ec.setEditorState(EditorState.idle);
    });
  }

  // 添加处理端口拖拽的方法
  void _handlePortDragStart(NodePort port) {
    setState(() {
      _draggingPort = port;
      _currentDragPosition = Offset(
        port.area.position.x,
        port.area.position.y,
      );
    });
  }

  void _handlePortDragUpdate(Offset position) {
    setState(() {
      _currentDragPosition = position;
    });
  }

  void _handlePortDragEnd() {
    if (_draggingPort != null && _currentDragPosition != null) {
      // 检查当前位置是否有可连接的端口
      final targetPort = _findPortAtPosition(_currentDragPosition!);
      if (targetPort != null) {
        if (_draggingPort!.type == PortType.input &&
            targetPort.type == PortType.input) {
          _draggingPort = null;
          _currentDragPosition = null;
          return;
        }
        // 找到源节点和目标节点的ID
        final sourceNodeId = _findNodeIdByPort(_draggingPort!);
        final targetNodeId = _findNodeIdByPort(targetPort);

        if (sourceNodeId != null && targetNodeId != null) {
          // 添加连接
          _ec.addConnection(
            sourceNodeId,
            _draggingPort!.id,
            targetNodeId,
            targetPort.id,
          );
        }
      }
    }

    setState(() {
      _draggingPort = null;
      _currentDragPosition = null;
    });
  }

  // 查找指定位置的端口
  NodePort? _findPortAtPosition(Offset position) {
    for (var node in _ec.nodes) {
      for (var port in node.ports) {
        final portRect = Rect.fromLTWH(
          port.area.position.x,
          port.area.position.y,
          port.area.width,
          port.area.height,
        );
        if (portRect.contains(position)) {
          return port;
        }
      }
    }
    return null;
  }

  // 根据端口查找节点ID
  String? _findNodeIdByPort(NodePort port) {
    for (var node in _ec.nodes) {
      if (node.ports.contains(port)) {
        return node.id;
      }
    }
    return null;
  }

  // 添加检测点是否在连接线附近的方法
  bool _isPointNearConnection(Offset point, NodePort startPort, NodePort endPort) {
    final start = Offset(
      startPort.area.position.x + startPort.area.width / 2,
      startPort.area.position.y + startPort.area.height / 2,
    );
    final end = Offset(
      endPort.area.position.x + endPort.area.width / 2,
      endPort.area.position.y + endPort.area.height / 2,
    );

    // 简单的距离检测
    const threshold = 10.0;
    return _distanceToLine(point, start, end) < threshold;
  }

  double _distanceToLine(Offset point, Offset start, Offset end) {
    final numerator = ((end.dx - start.dx) * (start.dy - point.dy) -
            (start.dx - point.dx) * (end.dy - start.dy))
        .abs();
    final denominator =
        sqrt(pow(end.dx - start.dx, 2) + pow(end.dy - start.dy, 2));
    return numerator / denominator;
  }

  @override
  void dispose() {
    _canvasController.dispose();
    _ec.reset();
    super.dispose();
  }
}
