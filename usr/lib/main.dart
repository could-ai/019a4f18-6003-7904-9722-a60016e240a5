import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MAX FIRE - Naija Battle Royale Prototype by Prof Maxwell Clement',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late Timer _timer;
  late AnimationController _controller;

  // Constants
  static const double screenWidth = 800;
  static const double screenHeight = 600;
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color red = Colors.red;
  static const Color gold = Color.fromRGBO(255, 215, 0, 1);
  static const Color blue = Colors.blue;

  // Game objects
  late Player player;
  late List<House> houses;
  List<String> instructions = [
    "WASD/Arrows: Move around Oshodi",
    "SPACE: Kelebu Taunt (+1 Kill)",
    "Enter blue houses to loot red guns!",
    "Prof Maxwell Clement - Eternal 999 Kills",
    "Booyah when all looted! Earnings: +₦500/kill"
  ];
  String statusMessage = "MAX FIRE Prototype Starting... Created by Prof Maxwell Clement";

  @override
  void initState() {
    super.initState();
    player = Player(400, 300);
    houses = [
      House(100, 100),
      House(600, 400),
      House(200, 500),
    ];
    for (var house in houses) {
      house.generateGuns();
    }
    _controller = AnimationController(
      duration: const Duration(milliseconds: 16), // ~60 FPS
      vsync: this,
    )..repeat();
    _controller.addListener(update);
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  void update() {
    setState(() {
      // Update game logic here if needed
    });
  }

  void handleKeyPress(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      final key = event.logicalKey;
      if (key == LogicalKeyboardKey.arrowLeft || key == LogicalKeyboardKey.keyA) {
        player.x -= 5;
      } else if (key == LogicalKeyboardKey.arrowRight || key == LogicalKeyboardKey.keyD) {
        player.x += 5;
      } else if (key == LogicalKeyboardKey.arrowUp || key == LogicalKeyboardKey.keyW) {
        player.y -= 5;
      } else if (key == LogicalKeyboardKey.arrowDown || key == LogicalKeyboardKey.keyS) {
        player.y += 5;
      } else if (key == LogicalKeyboardKey.space) {
        setState(() {
          statusMessage = "Kelebu Chant: Who dey breet?! +1 Kill!";
          player.kills += 1;
        });
      }
    }
  }

  void checkCollisions() {
    for (var house in houses) {
      if (player.x < house.x + house.width &&
          player.x + player.width > house.x &&
          player.y < house.y + house.height &&
          player.y + player.height > house.y) {
        for (var gun in List<Gun>.from(house.guns)) {
          if (player.x < gun.x + gun.width &&
              player.x + player.width > gun.x &&
              player.y < gun.y + gun.height &&
              player.y + player.height > gun.y) {
            setState(() {
              statusMessage = "Looted: ${gun.name} from house! +1 Kill (+₦500 to MoMo)";
              house.guns.remove(gun);
              player.kills += 1;
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    checkCollisions();
    return Scaffold(
      appBar: AppBar(
        title: const Text('MAX FIRE'),
      ),
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: handleKeyPress,
        child: Container(
          color: white,
          child: Stack(
            children: [
              CustomPaint(
                size: Size(screenWidth, screenHeight),
                painter: GamePainter(player: player, houses: houses),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: instructions.map((instr) => Text(instr, style: const TextStyle(color: Colors.white, fontSize: 16))).toList(),
                  ),
                ),
              ),
              Positioned(
                top: 50,
                left: 10,
                child: Text(statusMessage, style: const TextStyle(color: Colors.black, fontSize: 18, backgroundColor: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Player {
  double x, y;
  double width = 20, height = 20;
  int kills = 999;
  bool alive = true;

  Player(this.x, this.y);
}

class Gun {
  double x, y;
  double width = 15, height = 15;
  String name = "Agege Bread Bomb";

  Gun(this.x, this.y);
}

class House {
  double x, y;
  double width = 50, height = 50;
  List<Gun> guns = [];

  House(this.x, this.y);

  void generateGuns() {
    int numGuns = Random().nextInt(3) + 1;
    for (int i = 0; i < numGuns; i++) {
      guns.add(Gun(x + Random().nextDouble() * 40, y + Random().nextDouble() * 40));
    }
  }
}

class GamePainter extends CustomPainter {
  final Player player;
  final List<House> houses;

  GamePainter({required this.player, required this.houses});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Draw player
    paint.color = const Color.fromRGBO(255, 215, 0, 1);
    canvas.drawRect(Rect.fromLTWH(player.x, player.y, player.width, player.height), paint);

    // Draw kill count
    final textPainter = TextPainter(
      text: TextSpan(text: 'Kills: ${player.kills}', style: const TextStyle(color: Colors.black, fontSize: 24)),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(player.x, player.y - 30));

    // Draw houses and guns
    for (var house in houses) {
      paint.color = Colors.blue;
      canvas.drawRect(Rect.fromLTWH(house.x, house.y, house.width, house.height), paint);

      // Draw "House" text
      final houseTextPainter = TextPainter(
        text: const TextSpan(text: 'House', style: TextStyle(color: Colors.white, fontSize: 16)),
        textDirection: TextDirection.ltr,
      );
      houseTextPainter.layout();
      houseTextPainter.paint(canvas, Offset(house.x + 10, house.y + 10));

      for (var gun in house.guns) {
        paint.color = Colors.red;
        canvas.drawRect(Rect.fromLTWH(gun.x, gun.y, gun.width, gun.height), paint);

        // Draw "Bomb" text
        final bombTextPainter = TextPainter(
          text: const TextSpan(text: 'Bomb', style: TextStyle(color: Colors.white, fontSize: 12)),
          textDirection: TextDirection.ltr,
        );
        bombTextPainter.layout();
        bombTextPainter.paint(canvas, Offset(gun.x, gun.y - 20));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}