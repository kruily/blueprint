import '../models/node_type.dart';

/// 节点注册表
class NodeRegistry {
  /// 单例模式
  static final NodeRegistry _instance = NodeRegistry._internal();
  
  /// 获取单例实例
  factory NodeRegistry() {
    return _instance;
  }
  /// 私有构造函数
  NodeRegistry._internal();

  /// 节点类型映射
  final Map<String, NodeType> _nodeTypes = {};

  /// 注册节点类型
  void registerNodeType(NodeType nodeType) {
    _nodeTypes[nodeType.typeId] = nodeType;
  }

  /// 获取节点类型
  NodeType? getNodeType(String typeId) {
    return _nodeTypes[typeId];
  }

  /// 获取所有注册的节点类型
  List<NodeType> getAllNodeTypes() {
    return _nodeTypes.values.toList();
  }
} 