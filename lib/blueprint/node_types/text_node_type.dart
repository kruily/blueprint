
import 'package:blueprint/blueprint/models/area.dart';
import 'package:blueprint/blueprint/models/node.dart';
import 'package:blueprint/blueprint/models/node_style.dart';
import 'package:blueprint/blueprint/models/node_type.dart';
import 'package:blueprint/blueprint/widgets/node_widget.dart';
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
  NodeStyle get style => NodeStyle(
    width: 180,
    height: 100,
    borderRadius: 4,
    backgroundColor: const Color(0xFF2B2B2B),
    borderColor: const Color(0xFF454545),
    borderWidth: 1,
  );

  @override
  Widget? buildContent(BuildContext context, NodeData node,NodeWidget widget) {
    return TextField(
      decoration: InputDecoration(
        hintText: '请输入文本',
      ),
    );
  }

  @override
  NodeData createNode({required String id, required Position position}) {
    return NodeData(
      id: id,
      type: typeId,
      title: name,
      area: Area(position: position, width: 180, height: 100),
    );
  }
}