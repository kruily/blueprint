
import 'package:blueprint/blueprint/models/node.dart';
import 'package:blueprint/blueprint/models/node_type.dart';
import 'package:blueprint/blueprint/models/position.dart';
import 'package:flutter/material.dart';

class TextNodeType extends NodeType {
  @override
  String get typeId => 'text';

  @override
  String get name => '文本节点';

  @override
  String get description => '文本节点';

  @override
  IconData get icon => Icons.text_fields;

  @override
  Widget? buildCustomContent(BuildContext context, NodeData node) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: '请输入文本',
        ),
      ),
    );
  }

  @override
  NodeData createNode({required String id, required Position position}) {
    return NodeData(
      id: id,
      type: typeId,
      title: name,
      position: position,
      inputs: [
        NodePort(
          id: '${id}_text',
          label: '文本',
          type: PortType.input,
        ),
      ],
      outputs: [
        NodePort(
          id: '${id}_text',
          label: '文本',
          type: PortType.output,
        ),
      ],
    );
  }
}