import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class PowerUp extends PositionComponent with HasGameRef {
  final String type; // 'INVINCIBILITY' or 'X2'
  
  PowerUp({required Vector2 position, required this.type}) 
      : super(position: position, size: Vector2.all(40));

  @override
  Future<void> onLoad() async {
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);
    y += 200 * dt;
    if (y > 2000) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = type == 'X2' ? Colors.yellowAccent : Colors.purpleAccent
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 10);
    
    canvas.drawCircle(Offset(size.x/2, size.y/2), size.x/2, paint);
    canvas.drawCircle(Offset(size.x/2, size.y/2), size.x/2, Paint()..color = Colors.white);
  }
}
