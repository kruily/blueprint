import 'package:blueprint/blueprint/controllers/connection_layer_controller.dart';
import 'package:blueprint/blueprint/models/connection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../controllers/canvas_controller.dart';
import 'grid_painter.dart';
import '../models/position.dart';
import '../models/node.dart';
import 'node_widget.dart';
import '../services/node_registry.dart';
import '../models/node_style.dart';
import 'connection_layer.dart';

/// 编辑器状态枚举
enum EditorState {
  idle,
  draggingNode,
  draggingConnection,
  panning
}

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
  /// 连接管理控制器
  final ConnectionLayerController _connectionLayerController = ConnectionLayerController();
  /// 节点样式
  final NodeStyle style = const NodeStyle();
  /// 所有节点列表
  List<NodeData> nodes = [];
  /// 当前选中的节点
  NodeData? _selectedNode;
  /// 当前编辑器状态
  EditorState _editorState = EditorState.idle;
  /// 所有连接列表
  final List<Connection> _connections = [];      
  /// 端口键映射
  final Map<String, GlobalKey> _portKeys = {};

  @override
  void initState() {
    super.initState();
    nodes = [
      NodeRegistry().getNodeType('text')?.createNode(
        id: 'text_node',
        position: const Position(100, 100),
      ) ?? NodeData(
        id: 'text_node',
        type: 'text',
        title: '文本节点',
        position: const Position(100, 100),
      ),
      NodeRegistry().getNodeType('math.add')?.createNode(
        id: '1',
        position: const Position(100, 100),
      ) ?? NodeData(
        id: '1',
        type: 'default',
        title: '默认节点',
        position: const Position(100, 100),
      ),
      NodeRegistry().getNodeType('math.add')?.createNode(
        id: '2',
        position: const Position(200, 100),
      ) ?? NodeData(
        id: '2',
        type: 'default',
        title: '默认节点',
        position: const Position(200, 100),
      ),
    ];
    // 初始化所有端口的 key
    for (var node in nodes) {
      for (var port in [...node.inputs, ...node.outputs]) {
        _portKeys[port.id] = GlobalKey();
      }
    }
  }

  // 处理节点拖拽
  void _handleNodeDrag(String nodeId, Offset delta) {
    if (_editorState != EditorState.idle && _editorState != EditorState.draggingNode) return;
    
    setState(() {
      final index = nodes.indexWhere((node) => node.id == nodeId);
      if (index != -1) {
        final node = nodes[index];
        final scaledDelta = delta / _canvasController.scale;
        // 更新节点的实际位置
        node.position = Position(
          node.position.x + scaledDelta.dx,
          node.position.y + scaledDelta.dy,
        );
        // 计算显示位置
        final displayPosition = Position(
          (node.position.x + _canvasController.offset.x) * _canvasController.scale,
          (node.position.y + _canvasController.offset.y) * _canvasController.scale,
        );
        // 更新端口位置
        node.updatePortsPosition(displayPosition, _canvasController.scale);
        _editorState = EditorState.draggingNode;
      }
    });
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      // 处理缩放
      if (details.scale != 1.0) {
        final newScale = _canvasController.scale * details.scale;
        if (newScale >= 0.1 && newScale <= 5.0) {
          _canvasController.updateScale(newScale);
          // 触发所有节点更新
          _updateAllNodesPosition();
        }
      }
      
      // 处理平移
      final newOffset = Position(
        _canvasController.offset.x + details.focalPointDelta.dx / _canvasController.scale,
        _canvasController.offset.y + details.focalPointDelta.dy / _canvasController.scale,
      );
      _canvasController.updateOffset(newOffset);
      // 触发所有节点更新
      _updateAllNodesPosition();
      
      _editorState = EditorState.panning;
    });
  }

  void _updateAllNodesPosition() {
    for (var node in nodes) {
      // 只更新端口位置，不改变节点实际位置
      final displayPosition = Position(
        (node.position.x + _canvasController.offset.x) * _canvasController.scale,
        (node.position.y + _canvasController.offset.y) * _canvasController.scale,
      );
      // 只更新端口位置，不更新节点位置
      node.updatePortsPosition(displayPosition, _canvasController.scale);
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    print('Scale start');  // 添加调试日志
    setState(() {
      _editorState = EditorState.panning;
    });
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    setState(() {
      _editorState = EditorState.idle;
    });
  }

  // 检查端口是否已连接
  bool isPortConnected(NodePort port) {
    try {
      return _connections.any((conn) => 
        conn.sourcePortId == port.id || conn.targetPortId == port.id
      );
    } catch (e) {
      print('Error checking port connection: $e');
      return false;
    }
  }

  void _createConnection(NodeData startNode, NodePort startPort, NodePort endPort) {
    if (startPort.type == endPort.type) return;
    
    final isStartPortOutput = startPort.type == PortType.output;
    final sourceNode = isStartPortOutput ? startNode : nodes.firstWhere((n) => n.outputs.contains(endPort));
    final targetNode = isStartPortOutput ? nodes.firstWhere((n) => n.inputs.contains(endPort)) : startNode;
    final sourcePort = isStartPortOutput ? startPort : endPort;
    final targetPort = isStartPortOutput ? endPort : startPort;
    
    setState(() {
      _connections.add(Connection(
        id: 'conn_${_connections.length}',
        sourceNodeId: sourceNode.id,
        sourcePortId: sourcePort.id,
        targetNodeId: targetNode.id,
        targetPortId: targetPort.id,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Listener(
        onPointerSignal: (pointerSignal) {
          if (pointerSignal is PointerScrollEvent) {
            setState(() {
              // 计算新的缩放值
              final scaleFactor = pointerSignal.scrollDelta.dy > 0 ? 0.95 : 1.05;
              final newScale = _canvasController.scale * scaleFactor;
              
              // 限制缩放范围
              if (newScale >= 0.1 && newScale <= 5.0) {
                // 获取鼠标位置相对于画布的偏移
                final mousePosition = pointerSignal.position;
                final oldOffset = Offset(_canvasController.offset.x, _canvasController.offset.y);
                
                // 更新缩放
                _canvasController.updateScale(newScale);
                
                // 调整偏移以保持鼠标位置不变
                final newOffset = Position(
                  oldOffset.dx - (mousePosition.dx * (scaleFactor - 1) / newScale),
                  oldOffset.dy - (mousePosition.dy * (scaleFactor - 1) / newScale),
                );
                _canvasController.updateOffset(newOffset);
              }
            });
          }
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
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

              // 主要内容区域
              Stack(
                fit: StackFit.expand,
                children: [
                  // 连接层
                  ConnectionLayer(
                    nodes: nodes,
                    controller: _connectionLayerController,
                    scale: _canvasController.scale,
                    offset: Offset(_canvasController.offset.x, _canvasController.offset.y),
                    onConnectionCreated: _createConnection,
                  ),
                  // 节点层
                  ...nodes.map((node) => _buildNode(node)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNode(NodeData node) {
    final nodePosition = Offset(
      (node.position.x + _canvasController.offset.x) * _canvasController.scale,
      (node.position.y + _canvasController.offset.y) * _canvasController.scale,
    );
    
    return Positioned(
      left: nodePosition.dx,
      top: nodePosition.dy,
      child: Transform.scale(
        scale: _canvasController.scale,
        child: NodeWidget(
          key: ValueKey(node.id),
          data: node,
          scale: _canvasController.scale,
          offset: Offset(_canvasController.offset.x, _canvasController.offset.y),
          position: node.position,
          isSelected: node == _selectedNode,
          onSelected: () => setState(() => _selectedNode = node),
          onDragUpdate: (delta) => _handleNodeDrag(node.id, delta),
          onDragEnd: _handleNodeDragEnd,
          onPortDragStart: (node, port, position) {
            setState(() {
              _connectionLayerController.startConnection(node, port, position);
              _editorState = EditorState.draggingConnection;
            });
          },
          onPortDragUpdate: (position) {
            setState(() {
              _connectionLayerController.updateConnection(position);
              // 查找可连接的端口
              _connectionLayerController.findAttachablePort(nodes, position);
            });
          },
          onPortDragEnd: () {
            setState(() {
              _connectionLayerController.endConnection();
              _handleNodeDragEnd();
            });
          },
        ),
      ),
    );
  }

  // 添加节点拖拽结束的处理
  void _handleNodeDragEnd() {
    setState(() {
      _editorState = EditorState.idle;
    });
  }

  @override
  void dispose() {
    _canvasController.dispose();
    super.dispose();
  }
} 