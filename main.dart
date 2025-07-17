
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    GameWidget(
      game: BookBalanceGame(),
    ),
  );
}

class BookBalanceGame extends FlameGame with TapDetector, HasCollisionDetection {
  late Book book;
  late Player player;
  int score = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    camera.viewport = FixedResolutionViewport(Vector2(360, 640));

    player = Player()
      ..position = Vector2(size.x / 2 - 24, size.y - 80)
      ..anchor = Anchor.center;
    add(player);

    spawnNewBook();
  }

  void spawnNewBook() {
    book = Book()
      ..position = Vector2(size.x / 2, 0)
      ..anchor = Anchor.center;
    add(book);
  }

  @override
  void onTap() {
    if (!book.isDropping) {
      book.startDrop();
    }
    super.onTap();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Simple collision check
    if (book.isDropping &&
        book.position.y >= player.position.y - 20 &&
        (book.position.x - player.position.x).abs() < 40) {
      // Successful catch
      score += 1;
      player.stackHeight += 12;
      book.removeFromParent();
      spawnNewBook();
    }

    // Fail condition
    if (book.position.y > size.y) {
      overlays.add('GameOver');
      pauseEngine();
    }
  }
}

class Player extends SpriteComponent {
  double stackHeight = 0;

  Player() : super(size: Vector2(48, 48));

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('player.png');
  }

  @override
  void update(double dt) {
    // Simple sway animation based on stack height
    x = x + (stackHeight / 100) * (dt * 20) * (sin(timer * 2));
    super.update(dt);
  }
}

class Book extends SpriteComponent {
  bool isDropping = false;
  double speed = 150;

  Book() : super(size: Vector2(40, 20));

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('book.png');
  }

  void startDrop() {
    isDropping = true;
  }

  @override
  void update(double dt) {
    if (!isDropping) {
      // swing left and right
      x = x + sin(timer * 2) * 100 * dt;
    } else {
      y += speed * dt;
    }
    super.update(dt);
  }
}
