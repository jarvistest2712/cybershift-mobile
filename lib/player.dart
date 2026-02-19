import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class DataPacket extends PositionComponent {
  static const double size_val = 60.0;
  int currentColumn = 2; // Start in middle (0 to 4)
  double targetX = 0;

  @override
  Future<void> onLoad() async {
    size = Vector2.all(size_val);
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Smooth movement to target column
    x = lerpDouble(x, targetX, 0.2) ?? x;
  }

  void move(int direction, double columnWidth) {
    currentColumn = (currentColumn + direction).clamp(0, 4);
    targetX = (currentColumn * columnWidth) + (columnWidth / 2);
  }

  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.cyanAccent
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 10);
    
    canvas.drawRect(size.toRect(), paint);
    canvas.drawRect(size.toRect(), Paint()..color = Colors.cyanAccent);
  }
}
