import 'package:blueprint/blueprint/models/node.dart';
import 'package:blueprint/blueprint/models/node_type.dart';
import 'package:blueprint/blueprint/models/position.dart';
import 'package:flutter/material.dart';

/// 加法节点类型
class MathNodeType extends NodeType {
  @override
  String get typeId => 'math.add';

  @override
  String get name => '加法节点';

  @override
  String get description => '将两个数字相加';

  @override
  IconData get icon => Icons.add;

  @override
  NodeData createNode({required String id, required Position position}) {
    return NodeData(
      id: id,
      type: typeId,
      title: name,
      position: position,
      inputs: [
        NodePort(
          id: '${id}_num1',
          label: '数字1',
          type: PortType.input,
        ),
        NodePort(
          id: '${id}_num2',
          label: '数字2',
          type: PortType.input,
        ),
      ],
      outputs: [
        NodePort(
          id: '${id}_sum',
          label: '结果',
          type: PortType.output,
        ),
      ],
    );
  }

  @override
  Widget? buildCustomContent(BuildContext context, NodeData node) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: const Text(
        '+',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  bool validateInputs(NodeData node, Map<String, dynamic> inputs) {
    return inputs.containsKey('num1') && 
           inputs.containsKey('num2') &&
           inputs['num1'] is num &&
           inputs['num2'] is num;
  }

  @override
  Map<String, dynamic>? process(NodeData node, Map<String, dynamic> inputs) {
    if (!validateInputs(node, inputs)) return null;
    
    final num1 = inputs['num1'] as num;
    final num2 = inputs['num2'] as num;
    return {'sum': num1 + num2};
  }
} 