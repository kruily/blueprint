import 'package:blueprint/blueprint/controllers/editor_controller.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../controllers/canvas_controller.dart';
import 'grid_painter.dart';
import '../models/position.dart';
import '../models/node.dart';
import 'node_widget.dart';
import '../services/node_registry.dart';


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

  @override
  void initState() {
    super.initState();
    _ec.setNodes([
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
        type: 'math.add',
        title: '加法节点',
        position: const Position(100, 100),
      ),
      NodeRegistry().getNodeType('math.add')?.createNode(
        id: '2',
        position: const Position(200, 100),
      ) ?? NodeData(
        id: '2',
        type: 'math.add',
        title: '加法节点',
        position: const Position(200, 100),
      ),
    ]);
  }

  // 处理节点拖拽
  void _handleNodeDrag(String nodeId, Offset delta) {
    if (_ec.editorState != EditorState.idle && _ec.editorState != EditorState.draggingNode) return;
    
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
      
      // 处理平移
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

                // 主要内容区域
                Stack(
                  fit: StackFit.expand,
                  children: [
                    // 节点层
                    ..._ec.nodes.map((node) => _buildNode(node)),
                  ],
                ),
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
      (node.position.x + _canvasController.offset.x) * _canvasController.scale,
      (node.position.y + _canvasController.offset.y) * _canvasController.scale,
    );
    final nodeKey = _ec.createNodeKey(node.id);
    return Positioned(
      left: nodePosition.dx,
      top: nodePosition.dy,
      child: Transform.scale(
        scale: _canvasController.scale,
        child: NodeWidget(
          key: nodeKey,
          data: node,
          isSelected: node == _ec.selectedNode,
          onSelected: (node) => setState(() => print(node)),
          onDragUpdate: (node, delta) => _handleNodeDrag(node.data.id, delta),
          onDragEnd: (node) => _handleNodeDragEnd(),
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

  @override
  void dispose() {
    _canvasController.dispose();
    _ec.reset();
    super.dispose();
  }
} 