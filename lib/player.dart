import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'obstacle.dart';

class DataPacket extends PositionComponent with CollisionCallbacks {
  static const double sizeVal = 60.0;
  int currentColumn = 2; 
  double targetX = 0;
  final Function onHit;
  
  int shieldPoints = 0;
  double speedMultiplier = 1.0;

  DataPacket({required this.onHit});

  @override
  Future<void> onLoad() async {
    size = Vector2.all(sizeVal);
    anchor = Anchor.center;
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    // speedMultiplier affects how fast it lerps to target column
    x = lerpDouble(x, targetX, 0.2 * speedMultiplier) ?? x;
  }

  void move(int direction, double columnWidth) {
    currentColumn = (currentColumn + direction).clamp(0, 4);
    targetX = (currentColumn * columnWidth) + (columnWidth / 2);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is DataCorruption) {
      if (shieldPoints > 0) {
        shieldPoints--;
        other.removeFromParent(); // Destroy the obstacle
      } else {
        onHit();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.cyanAccent
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 10);
    
    // Draw Shield if active
    if (shieldPoints > 0) {
      canvas.drawCircle(
        Offset(size.x/2, size.y/2), 
        size.x, 
        Paint()..color = Colors.cyanAccent.withOpacity(0.3)
      );
    }

    canvas.drawRect(size.toRect(), paint);
    canvas.drawRect(size.toRect(), Paint()..color = Colors.cyanAccent);
  }
}
