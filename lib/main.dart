import 'package:blueprint/shared/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'blueprint/widgets/blueprint_editor.dart';
import 'blueprint/services/node_registry.dart';
import 'blueprint/node_types/math_node_type.dart';

void main() {
  // 注册节点类型   
  NodeRegistry().registerNodeType(MathNodeType());
  
  runApp(const BlueprintEditorApp());
}

/// 蓝图编辑器应用
class BlueprintEditorApp extends StatelessWidget {
  const BlueprintEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '蓝图编辑器',
      theme: AppTheme.lightTheme,
      home: BlueprintEditor(),
    );
  }
}
