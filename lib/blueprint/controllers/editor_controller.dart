import 'package:blueprint/blueprint/models/node.dart';
import 'package:blueprint/blueprint/models/node_style.dart';
import 'package:blueprint/blueprint/models/position.dart';
import 'package:blueprint/blueprint/widgets/node_widget.dart';
import 'package:flutter/material.dart';


/// 编辑器状态枚举
enum EditorState {
  idle,
  draggingNode,
  draggingConnection,
  panning
}

class EditorController extends ChangeNotifier {

  /// 当前选中的节点
  NodeWidget? _selectedNode;
  /// 节点样式
  NodeStyle _style = const NodeStyle();
  /// 所有节点列表
  List<NodeData> _nodes = [];
  /// 当前编辑器状态
  EditorState _editorState = EditorState.idle;
  /// 节点键值对
  Map<String, GlobalKey> _nodeKeys = {};

  // 获取当前选中的节点
  NodeWidget? get selectedNode => _selectedNode;
  // 获取当前编辑器状态
  EditorState get editorState => _editorState;
  // 获取所有节点
  List<NodeData> get nodes => _nodes;
  // 获取节点键值对
  Map<String, GlobalKey> get nodeKeys => _nodeKeys;
  // 获取节点样式
  NodeStyle get style => _style;

  void setSelectedNode(NodeWidget? node) {
    _selectedNode = node;
    notifyListeners();
  }

  void setEditorState(EditorState state) {
    _editorState = state;
    notifyListeners();
  }

  void setNodes(List<NodeData> nodes) {
    _nodes = nodes;
    notifyListeners();
  }

  void setStyle(NodeStyle style) {
    _style = style;
    notifyListeners();
  }

  void reset() {
    _selectedNode = null;
    _editorState = EditorState.idle;
    notifyListeners();
  }

  /// 创建节点键
  GlobalKey createNodeKey(String id) {
    if(!nodeKeys.containsKey(id)) {
      final key = GlobalKey();
      nodeKeys[id] = key;
    }
    return nodeKeys[id]!;
  }

  /// 更新节点位置
  void updateNodePosition(String nodeId, Offset delta){
    final index = nodes.indexWhere((node) => node.id == nodeId);
    if (index != -1) {
      final node = nodes[index];
      node.position = Position(
        node.position.x + delta.dx,
        node.position.y + delta.dy,
      );
    }
    notifyListeners();
  }
}