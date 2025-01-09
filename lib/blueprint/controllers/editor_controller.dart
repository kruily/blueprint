import 'package:blueprint/blueprint/models/area.dart';
import 'package:blueprint/blueprint/models/connection.dart';
import 'package:blueprint/blueprint/models/node.dart';
import 'package:blueprint/blueprint/models/node_style.dart';
import 'package:blueprint/blueprint/services/node_registry.dart';
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
  /// 单例模式
  static final EditorController _instance = EditorController._internal();

  /// 私有构造函数
  EditorController._internal();

  /// 获取单例实例
  factory EditorController() {
    return _instance;
  }

  /// 当前选中的节点
  NodeWidget? _selectedNode;
  /// 节点样式
  NodeStyle _style = const NodeStyle();
  /// 所有节点列表
  List<NodeData> _nodes = [];
  /// 当前编辑器状态
  EditorState _editorState = EditorState.idle;
  /// 节点键值对
  final Map<String, GlobalKey> _nodeKeys = {};
  /// 端口键值对
  final Map<String, GlobalKey> _portKeys = {};
  /// 添加连接列表
  final List<Connection> _connections = [];


  // 获取当前选中的节点
  NodeWidget? get selectedNode => _selectedNode;
  // 获取当前编辑器状态
  EditorState get editorState => _editorState;
  // 获取所有节点
  List<NodeData> get nodes => _nodes;
  // 获取节点键值对
  Map<String, GlobalKey> get nodeKeys => _nodeKeys;
  // 获取端口键值对
  Map<String, GlobalKey> get portKeys => _portKeys;
  // 获取节点样式
  NodeStyle get style => _style;
  // 获取连接列表
  List<Connection> get connections => _connections;

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

  /// 创建端口键
  Map<String, GlobalKey> createPortKeys(String nodeId) {
    final node = nodes.firstWhere((node) => node.id == nodeId);
    final nodeType = NodeRegistry().getNodeType(node.type);
    for(var port in nodeType!.ports) {
      if(!portKeys.containsKey("${node.id}@${port.id}")) {
        portKeys["${node.id}@${port.id}"] = GlobalKey();
      }
    }
    return portKeys;
  }

  /// 更新节点位置
  void updateNodePosition(String nodeId, Offset delta) {
    final index = nodes.indexWhere((node) => node.id == nodeId);
    if (index != -1) {
      final node = nodes[index];
      // 更新节点位置
      node.area.position = Position(
        node.area.position.x + delta.dx,
        node.area.position.y + delta.dy,
      );
      
      // 更新端口位置
      for (var port in node.ports) {
        port.area.position = Position(
          port.area.position.x + delta.dx, // 保持相对位置
          port.area.position.y + delta.dy,
        );
      }
      notifyListeners();
    }
  }

  void updateAllNodePosition(Offset delta) {
    for (var node in nodes) {
      // 更新节点位置
      node.area.position = Position(
        node.area.position.x + delta.dx,
        node.area.position.y + delta.dy,
      );
      
      // 更新端口位置
      for (var port in node.ports) {
        port.area.position = Position(
          port.area.position.x + delta.dx,
          port.area.position.y + delta.dy,
        );
      }
    }
    notifyListeners();
  }

  // 添加连接
  void addConnection(String sourceNodeId, String sourcePortId, String targetNodeId, String targetPortId) {
    _connections.add(Connection(
      id: '${sourceNodeId}_${sourcePortId}_${targetNodeId}_${targetPortId}',
      sourceNodeId: sourceNodeId,
      sourcePortId: sourcePortId,
      targetNodeId: targetNodeId,
      targetPortId: targetPortId,
    ));
    notifyListeners();
  }

  /// 删除连接
  void deleteConnection(Connection connection) {
    _connections.remove(connection);
    notifyListeners();
  }
}