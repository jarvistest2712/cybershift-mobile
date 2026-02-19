import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(
    GameWidget(
      game: CyberShiftGame(),
      overlayBuilderMap: {
        'MainMenu': (context, game) => MainMenu(game: game as CyberShiftGame),
      },
      initialActiveOverlays: const ['MainMenu'],
    ),
  );
}

class CyberShiftGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    // Basic initialization for the neon world
    camera.viewport.size = Vector2(1080, 1920); // Reference resolution
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
          mainAxisAlignment: MainValue.center,
          children: [
            Text(
              'CYBERSHIFT',
              style: GoogleFonts.orbitron(
                fontSize: 48,
                color: Colors.cyanAccent,
                fontWeight: MainWeight.bold,
                shadows: [
                  const Shadow(color: Colors.cyan, blurRadius: 20),
                ],
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                game.overlays.remove('MainMenu');
                // Start game logic here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
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
