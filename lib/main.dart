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
    player = DataPacket(onHit: gameOver);
    player.position = Vector2(size.x / 2, size.y * 0.8);
    player.targetX = player.x;
  }

  void startGame() {
    // Clear existing obstacles
    children.whereType<DataCorruption>().forEach((child) => child.removeFromParent());
    
    isPlaying = true;
    score = 0;
    spawnTimer = 0;
    
    player.currentColumn = 2;
    player.position = Vector2(size.x / 2, size.y * 0.8);
    player.targetX = player.x;
    
    if (!children.contains(player)) {
      add(player);
    }
    
    overlays.remove('MainMenu');
    overlays.remove('GameOver');
    resumeEngine();
  }

  void gameOver() {
    isPlaying = false;
    pauseEngine();
    overlays.add('GameOver');
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isPlaying) return;

    spawnTimer += dt;
    if (spawnTimer > 1.2) {
      _spawnObstacle();
      spawnTimer = 0;
      score++;
    }
  }

  void _spawnObstacle() {
    final randomColumn = Random().nextInt(5);
    final obstacle = DataCorruption(
      position: Vector2((randomColumn * columnWidth) + (columnWidth / 2), -50),
      speed: 350.0 + (score * 8),
    );
    add(obstacle);
  }

  @override
  void onTapDown(TapDownInfo info) {
    if (!isPlaying) return;
    
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
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'SCORE: $score',
          style: GoogleFonts.orbitron(
            color: Colors.white, 
            fontSize: 24, 
            fontWeight: FontWeight.bold
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, const Offset(20, 50));
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
                shadows: [const Shadow(color: Colors.cyan, blurRadius: 25)],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'THE ROGUE DATA',
              style: GoogleFonts.orbitron(color: Colors.cyan, fontSize: 16),
            ),
            const SizedBox(height: 60),
            GestureDetector(
              onTap: () => game.startGame(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.cyanAccent, width: 2),
                  boxShadow: [
                    BoxShadow(color: Colors.cyanAccent.withOpacity(0.3), blurRadius: 10)
                  ]
                ),
                child: Text(
                  'INITIATE ESCAPE',
                  style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontSize: 20),
                ),
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
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.7),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.redAccent, width: 2),
            boxShadow: [
              BoxShadow(color: Colors.redAccent.withOpacity(0.5), blurRadius: 30)
            ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'DATA CORRUPTED',
                style: GoogleFonts.orbitron(color: Colors.redAccent, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'FINAL SCORE: ${game.score}',
                style: GoogleFonts.orbitron(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 40),
              TextButton(
                onPressed: () => game.startGame(),
                child: Text(
                  '[ RETRY_CONNECTION ]',
                  style: GoogleFonts.orbitron(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
