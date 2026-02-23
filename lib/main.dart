import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'player.dart';
import 'obstacle.dart';
import 'store.dart';
import 'effects.dart';

StoreService? _storeService;
StoreService get storeService {
  if (_storeService == null) {
    throw Exception("StoreService not initialized. Call init() first.");
  }
  return _storeService!;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _storeService = StoreService();
  await _storeService!.init();
  
  runApp(
    GameWidget(
      game: CyberShiftGame(),
      overlayBuilderMap: {
        'MainMenu': (context, game) => MainMenu(game: game as CyberShiftGame),
        'GameOver': (context, game) => GameOver(game: game as CyberShiftGame),
        'Store': (context, game) => UpgradeStore(game: game as CyberShiftGame),
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
  bool _gameOverTriggered = false;

  @override
  Future<void> onLoad() async {
    columnWidth = size.x / 5;
    player = DataPacket(onHit: gameOver);
  }

  void startGame() {
    children.whereType<DataCorruption>().forEach((child) => child.removeFromParent());
    
    isPlaying = true;
    _gameOverTriggered = false;
    score = 0;
    spawnTimer = 0;
    
    player.shieldPoints = storeService.shieldLevel;
    player.speedMultiplier = 1.0 + (storeService.speedLevel * 0.2);
    
    player.currentColumn = 2;
    player.position = Vector2(size.x / 2, size.y * 0.8);
    player.targetX = player.x;
    
    if (!children.contains(player)) add(player);
    
    overlays.remove('MainMenu');
    overlays.remove('GameOver');
    overlays.remove('Store');
    resumeEngine();
  }

  void gameOver() {
    if (_gameOverTriggered) return;
    _gameOverTriggered = true;
    
    isPlaying = false;
    add(EffectFactory.createExplosion(player.position));
    pauseEngine();
    storeService.addBits(score);
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
          text: 'BITS: $score',
          style: GoogleFonts.orbitron(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
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
            Text('CYBERSHIFT', style: GoogleFonts.orbitron(fontSize: 48, color: Colors.cyanAccent, fontWeight: FontWeight.bold, shadows: [const Shadow(color: Colors.cyan, blurRadius: 25)])),
            const SizedBox(height: 60),
            _menuButton('INITIATE ESCAPE', () => game.startGame()),
            const SizedBox(height: 20),
            _menuButton('UPGRADE SYSTEM', () => game.overlays.add('Store')),
            const SizedBox(height: 40),
            ValueListenableBuilder<int>(
              valueListenable: storeService.bitsNotifier,
              builder: (context, bits, child) {
                return Text('STORED BITS: $bits', style: GoogleFonts.orbitron(color: Colors.cyan, fontSize: 16));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        decoration: BoxDecoration(border: Border.all(color: Colors.cyanAccent, width: 2)),
        child: Text(label, style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontSize: 20)),
      ),
    );
  }
}

class UpgradeStore extends StatefulWidget {
  final CyberShiftGame game;
  const UpgradeStore({super.key, required this.game});

  @override
  State<UpgradeStore> createState() => _UpgradeStoreState();
}

class _UpgradeStoreState extends State<UpgradeStore> {
  final List<UpgradeItem> items = [
    UpgradeItem(name: 'DATA SHIELD', key: StoreService.keyShieldLevel, baseCost: 100, description: 'Survive one collision per level'),
    UpgradeItem(name: 'SIGNAL BOOST', key: StoreService.keySpeedLevel, baseCost: 150, description: 'Faster lateral movement'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('SYSTEM UPGRADES', style: GoogleFonts.orbitron(color: Colors.cyanAccent)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.cyanAccent), onPressed: () => widget.game.overlays.remove('Store')),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: ValueListenableBuilder<int>(
              valueListenable: storeService.bitsNotifier,
              builder: (context, bits, child) {
                return Text('AVAILABLE BITS: $bits', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 20));
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final level = storeService.box.get(item.key, defaultValue: 0);
                final cost = item.getCost(level);
                return ListTile(
                  title: Text(item.name, style: GoogleFonts.orbitron(color: Colors.cyanAccent)),
                  subtitle: Text('${item.description}\nLevel: $level', style: const TextStyle(color: Colors.grey)),
                  trailing: ValueListenableBuilder<int>(
                    valueListenable: storeService.bitsNotifier,
                    builder: (context, bits, child) {
                      return ElevatedButton(
                        onPressed: bits >= cost ? () {
                          setState(() => storeService.buyUpgrade(item.key, cost));
                        } : null,
                        child: Text('BUY: $cost'),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
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
          decoration: BoxDecoration(color: Colors.black, border: Border.all(color: Colors.redAccent, width: 2)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('DATA CORRUPTED', style: GoogleFonts.orbitron(color: Colors.redAccent, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text('EARNED BITS: ${game.score}', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 40),
              _actionButton('RETRY', () => game.startGame()),
              const SizedBox(height: 10),
              _actionButton('STORE', () => game.overlays.add('Store')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton(String label, VoidCallback onTap) {
    return TextButton(onPressed: onTap, child: Text('[ $label ]', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 16)));
  }
}
