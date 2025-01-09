/// 连接线数据模型
class Connection {
  /// 连接ID
  final String id;
  /// 源节点ID
  final String sourceNodeId;
  /// 源端口ID
  final String sourcePointId;
  /// 目标节点ID
  final String targetNodeId;
  /// 目标端口ID
  final String targetPointId;

  const Connection({
    required this.id,
    required this.sourceNodeId,
    required this.sourcePointId,
    required this.targetNodeId,
    required this.targetPointId,
  });

  @override
  String toString() {
    return 'Connection{id: $id, source: $sourceNodeId:$sourcePointId -> target: $targetNodeId:$targetPointId}';
  }
} 