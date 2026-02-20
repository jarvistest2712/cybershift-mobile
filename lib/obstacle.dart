import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

class DataCorruption extends PositionComponent with CollisionCallbacks {
  final double speed;
  
  DataCorruption({required Vector2 position, required this.speed}) 
      : super(position: position, size: Vector2.all(50));

  @override
  Future<void> onLoad() async {
    anchor = Anchor.center;
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    y += speed * dt;
    
    if (y > 2000) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.redAccent
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 15);
    
    canvas.drawCircle(Offset(size.x/2, size.y/2), size.x/2, paint);
    canvas.drawCircle(Offset(size.x/2, size.y/2), size.x/2, Paint()..color = Colors.redAccent);
  }
}
