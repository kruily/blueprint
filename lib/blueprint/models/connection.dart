/// 连接线数据模型
class Connection {
  /// 连接ID
  final String id;
  /// 源节点ID
  final String sourceNodeId;
  /// 源端口ID
  final String sourcePortId;
  /// 目标节点ID
  final String targetNodeId;
  /// 目标端口ID
  final String targetPortId;
  /// 是否选中
  bool isSelected = false;

  Connection({
    required this.id,
    required this.sourceNodeId,
    required this.sourcePortId,
    required this.targetNodeId,
    required this.targetPortId,
  });

  @override
  String toString() {
    return 'Connection{id: $id, source: $sourceNodeId:$sourcePortId -> target: $targetNodeId:$targetPortId}';
  }
} 