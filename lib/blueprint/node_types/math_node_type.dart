import 'package:blueprint/blueprint/models/node.dart';
import 'package:blueprint/blueprint/models/node_style.dart';
import 'package:blueprint/blueprint/models/node_type.dart';
import 'package:blueprint/blueprint/models/position.dart';
import 'package:flutter/material.dart';

/// 加法节点类型
class MathNodeType extends NodeType {
  String get typeId => 'math.add';

  String get name => '加法节点';

  String get description => '将两个数字相加';

  IconData? get icon => Icons.add;

  NodeStyle get style => NodeStyle(
        width: 300,
        height: 120,
        borderRadius: 4,
        backgroundColor: const Color(0xFF2B2B2B),
        borderColor: const Color(0xFF454545),
        borderWidth: 1,
      );

  @override
  NodeData createNode({required String id, required Position position}) {
    return NodeData(
      id: id,
      type: typeId,
      title: name,
      position: position,
    );
  }

  @override
  Widget buildContent(
      BuildContext context, NodeData node, StatefulWidget widget) {
    // 自定义内容渲染
    return Container(
        width: 300,
        height: 120,
        color: Colors.red,
        child: Column(
          children: [
            Text('A + B', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text(
              node.data['result']?.toString() ?? '等待输入...',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ));
  }
}
