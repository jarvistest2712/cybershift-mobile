import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'player.dart';
import 'obstacle.dart';

void main() {
  runApp(
    GameWidget(
      game: CyberShiftGame(),
      overlayBuilderMap: {
        'MainMenu': (context, game) => MainMenu(game: game as CyberShiftGame),
        'GameOver': (context, game) => GameOver(game: game as CyberShiftGame),
      },
      initialActiveOverlays: const ['MainMenu'],
    ),
  );
}

class CyberShiftGame extends FlameGame with TapDetector, HasCollisionDetection {
  late DataPacket player;
  late double columnWidth;
  double spawnTimer = 0;
  int score = 0;
  bool isPlaying = false;

  @override
  Future<void> onLoad() async {
    columnWidth = size.x / 5;
    player = DataPacket();
    player.position = Vector2(size.x / 2, size.y * 0.8);
    player.targetX = player.x;
  }

  void startGame() {
    isPlaying = true;
    score = 0;
    add(player);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isPlaying) return;

    spawnTimer += dt;
    if (spawnTimer > 1.5) {
      _spawnObstacle();
      spawnTimer = 0;
      score++;
    }
  }

  void _spawnObstacle() {
    final randomColumn = Random().nextInt(5);
    final obstacle = DataCorruption(
      position: Vector2((randomColumn * columnWidth) + (columnWidth / 2), -50),
      speed: 300.0 + (score * 5),
    );
    add(obstacle);
  }

  @override
  void onTapDown(TapDownInfo info) {
    if (!isPlaying) return;
    
    // Simple tap left/right logic
    if (info.eventPosition.global.x < size.x / 2) {
      player.move(-1, columnWidth);
    } else {
      player.move(1, columnWidth);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (isPlaying) {
      TextPainter(
        text: TextSpan(
          text: 'SCORE: $score',
          style: GoogleFonts.orbitron(color: Colors.white, fontSize: 24),
        ),
        textDirection: TextDirection.ltr,
      )..layout().paint(canvas, const Offset(20, 40));
    }
  }
}

class MainMenu extends StatelessWidget {
  final CyberShiftGame game;
  const MainMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'CYBERSHIFT',
              style: GoogleFonts.orbitron(
                fontSize: 48,
                color: Colors.cyanAccent,
                fontWeight: FontWeight.bold,
                shadows: [const Shadow(color: Colors.cyan, blurRadius: 20)],
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                game.overlays.remove('MainMenu');
                game.startGame();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                side: const BorderSide(color: Colors.cyanAccent),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
              child: Text(
                'START MISSION',
                style: GoogleFonts.orbitron(color: Colors.cyanAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GameOver extends StatelessWidget {
  final CyberShiftGame game;
  const GameOver({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.black.withOpacity(0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('MISSION FAILED', style: GoogleFonts.orbitron(color: Colors.redAccent, fontSize: 32)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => game.overlays.remove('GameOver'),
              child: const Text('RETRY'),
            ),
          ],
        ),
      ),
    );
  }
}
