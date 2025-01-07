import 'package:blueprint/features/blueprint/models/connection.dart';
import 'package:blueprint/features/blueprint/models/node.dart';
import 'package:flutter/material.dart';

/// 连接管理控制器
class ConnectionLayerController extends ChangeNotifier {
  /// 所有连接
  final List<Connection> _connections = [];
  /// 获取所有连接
  List<Connection> get connections => _connections;

  /// 拖拽开始节点
  NodeData? _dragStartNode;
  /// 拖拽开始端口
  NodePort? _dragStartPort;
  /// 拖拽结束点
  Offset? _dragEndPoint;
  /// 当前可连接的目标端口
  NodePort? _attachablePort;  
  /// 当前可连接的目标节点
  NodeData? _attachableNode;  

  /// 获取拖拽开始节点
  NodeData? get dragStartNode => _dragStartNode;
  /// 获取拖拽开始端口
  NodePort? get dragStartPort => _dragStartPort;
  /// 获取拖拽结束点
  Offset? get dragEndPoint => _dragEndPoint;
  /// 获取当前可连接的目标端口
  NodePort? get attachablePort => _attachablePort;
  /// 获取当前可连接的目标节点
  NodeData? get attachableNode => _attachableNode;

  // 检查端口是否可连接
  bool canConnect(NodePort port1, NodePort port2) {
    // 不能连接相同类型的端口
    if (port1.type == port2.type) return false;
    // 不能自己连接自己
    if (port1 == port2) return false;
    // 检查是否已经连接
    return !_connections.any((conn) => 
      (conn.sourcePortId == port1.id && conn.targetPortId == port2.id) ||
      (conn.sourcePortId == port2.id && conn.targetPortId == port1.id)
    );
  }

  /// 检查端口是否在指定位置
  bool isPortAtPosition(NodePort port, Offset position) {
    final portRect = Rect.fromCircle(
      center: port.position,
      radius: 12.0,  // 检测范围
    );
    return portRect.contains(position);
  }

  /// 查找可连接的端口
  void findAttachablePort(List<NodeData> nodes, Offset position) {
    _attachablePort = null;
    _attachableNode = null;

    for (final node in nodes) {
      if (node == _dragStartNode) continue;

      for (final port in [...node.inputs, ...node.outputs]) {
        if (isPortAtPosition(port, position) && 
            _dragStartPort != null && 
            canConnect(_dragStartPort!, port)) {
          _attachablePort = port;
          _attachableNode = node;
          notifyListeners();
          return;
        }
      }
    }
    notifyListeners();
  }

  /// 创建连接
  void createConnection() {
    if (_dragStartNode != null && _dragStartPort != null && 
        _attachableNode != null && _attachablePort != null) {
      final isStartPortOutput = _dragStartPort!.type == PortType.output;
      final sourceNode = isStartPortOutput ? _dragStartNode! : _attachableNode!;
      final targetNode = isStartPortOutput ? _attachableNode! : _dragStartNode!;
      final sourcePort = isStartPortOutput ? _dragStartPort! : _attachablePort!;
      final targetPort = isStartPortOutput ? _attachablePort! : _dragStartPort!;

      _connections.add(Connection(
        id: 'conn_${_connections.length}',
        sourceNodeId: sourceNode.id,
        sourcePortId: sourcePort.id,
        targetNodeId: targetNode.id,
        targetPortId: targetPort.id,
      ));
      notifyListeners();
    }
  }

  void startConnection(NodeData node, NodePort port, Offset position) {
    _dragStartNode = node;
    _dragStartPort = port;
    _dragEndPoint = position;
    notifyListeners();
  }

  /// 更新连接
  void updateConnection(Offset position) {
    _dragEndPoint = position;
    notifyListeners();
  }

  /// 结束连接
  void endConnection() {
    if (_attachablePort != null) {
      createConnection();
    }
    reset();
  }

  /// 重置连接
  void reset() {
    _dragStartNode = null;
    _dragStartPort = null;
    _dragEndPoint = null;
    _attachablePort = null;
    _attachableNode = null;
    notifyListeners();
  }
}