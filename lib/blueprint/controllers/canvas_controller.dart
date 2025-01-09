import 'package:blueprint/blueprint/models/area.dart';
import 'package:flutter/material.dart';

/// 画布控制器，管理缩放和平移
class CanvasController extends ChangeNotifier {
  /// 当前缩放比例
  double _scale = 1.0;
  /// 当前偏移量
  Position _offset = const Position(0, 0);
  
  // 获取当前缩放
  double get scale => _scale;
  // 获取当前偏移
  Position get offset => _offset;

  // 更新缩放
  void updateScale(double newScale) {
    _scale = newScale.clamp(0.1, 2.0);
    notifyListeners();
  }

  // 更新偏移
  void updateOffset(Position newOffset) {
    _offset = newOffset;
    notifyListeners();
  }

  // 重置画布
  void reset() {
    _scale = 1.0;
    _offset = const Position(0, 0);
    notifyListeners();
  }
} 