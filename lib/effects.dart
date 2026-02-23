import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class EffectFactory {
  static ParticleSystemComponent createExplosion(Vector2 position) {
    final rnd = Random();
    return ParticleSystemComponent(
      particle: Particle.generate(
        count: 20,
        lifespan: 0.8,
        generator: (i) => AcceleratedParticle(
          acceleration: Vector2(0, 100),
          speed: Vector2(rnd.nextDouble() * 200 - 100, rnd.nextDouble() * 200 - 100),
          position: position.clone(),
          child: CircleParticle(
            radius: 2,
            paint: Paint()..color = Colors.redAccent,
          ),
        ),
      ),
    );
  }

  static ParticleSystemComponent createScoreBurst(Vector2 position) {
    return ParticleSystemComponent(
      particle: Particle.generate(
        count: 10,
        lifespan: 0.5,
        generator: (i) => MovingParticle(
          to: position + Vector2(0, -50),
          from: position,
          child: CircleParticle(
            radius: 1.5,
            paint: Paint()..color = Colors.cyanAccent,
          ),
        ),
      ),
    );
  }
}
