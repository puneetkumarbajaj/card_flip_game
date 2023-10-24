import 'package:flutter/material.dart';
import 'dart:math';

import 'package:provider/provider.dart';


void main() {
  runApp(
    ChangeNotifierProvider(
    create: (context) => GameState(),
    child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Card Flip Animation'),
        ),
        body: FlippingCardGrid(),
      ),
    );
  }
}

class FlippingCardGrid extends StatelessWidget {

  final List<String> imageUrls = [
    'assets/images/fox.png',
    'assets/images/hippo.png',
    'assets/images/horse.png',
    'assets/images/monkey.png',
    'assets/images/panda.png',
    'assets/images/parrot.png',
    'assets/images/rabbit.png',
    'assets/images/zoo.png',
    'assets/images/fox.png',
    'assets/images/hippo.png',
    'assets/images/horse.png',
    'assets/images/monkey.png',
    'assets/images/panda.png',
    'assets/images/parrot.png',
    'assets/images/rabbit.png',
    'assets/images/zoo.png'
  ]..shuffle();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
      ),
      itemBuilder: (context, index) {
        return FlipCard(imageUrl: imageUrls[index], index: index,);
      },
      itemCount: 16,
    );
  }
}

class FlipCard extends StatefulWidget {
  final String imageUrl;
  final int index;
  FlipCard({required this.imageUrl, required this.index});
  @override
  _FlipCardState createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool victoryDialogShown = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        bool isFlipped = gameState.cardsFlipped[widget.index];

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (isFlipped && _controller.value != 1.0) {
            _controller.forward();
          } else if (!isFlipped && _controller.value != 0.0) {
            _controller.reverse();
          }
        });
        if (gameState.checkVictory() && !victoryDialogShown) {
          victoryDialogShown = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Congratulations!'),
                  content: Text('You have matched all pairs!'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                        gameState.restartGame(); // Restart the game
                        victoryDialogShown = false; // Reset the flag
                      },
                      child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );});}

        return GestureDetector(
          onTap: () {
            if (_controller.isAnimating) {
              return;
            }
            gameState.flipCard(widget.index, widget.imageUrl);
          },
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..rotateY(pi * _controller.value),
                child: _controller.value <= 0.5 ? BackCard() : FrontCard(imageUrl: widget.imageUrl),
              );
            },
          ),
        );
      },
    );
  }
}


class FrontCard extends StatelessWidget {
  final String imageUrl;
  FrontCard({required this.imageUrl});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Container(
        width: 80,
        height: 100,
        child: Image.asset(imageUrl, fit: BoxFit.cover,),
      ),
    );
  }
}

class BackCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Container(
        width: 80,
        height: 100,
        child: Center(
          child: Image.asset("assets/images/hidden.png"),
        ),
      ),
    );
  }
}
class GameState extends ChangeNotifier {
  List<bool> cardsFlipped = List.generate(16, (_) => false);
  int? firstFlippedIndex;
  String? firstFlippedImageUrl;
  bool isFlippingBack = false;

  void flipCard(int index, String imageUrl) {
    if (isFlippingBack) return;

    if (firstFlippedIndex == null) {
      firstFlippedIndex = index;
      firstFlippedImageUrl = imageUrl;
      cardsFlipped[index] = true;
    } else if (firstFlippedIndex == index) {
      firstFlippedIndex = null;
      firstFlippedImageUrl = null;
      cardsFlipped[index] = false;
    } else if (firstFlippedImageUrl == imageUrl) {
      cardsFlipped[index] = true;
      firstFlippedIndex = null;
      firstFlippedImageUrl = null;
    } else {
      cardsFlipped[firstFlippedIndex!] = false;
      cardsFlipped[index] = true;
      isFlippingBack = true;
      Future.delayed(const Duration(seconds: 1), () {
        cardsFlipped[firstFlippedIndex!] = false;
        cardsFlipped[index] = false;
        firstFlippedIndex = null;
        firstFlippedImageUrl = null;
        isFlippingBack = false;
        notifyListeners();
      });
    }
    notifyListeners();
  }
  bool checkVictory() {
    return cardsFlipped.every((isFlipped) => isFlipped);
  }
  void restartGame() {
    cardsFlipped = List.generate(16, (_) => false);
    firstFlippedIndex = null;
    firstFlippedImageUrl = null;
    isFlippingBack = false;

    // If you have a list of card images, shuffle it here
    // cardImages.shuffle();

    notifyListeners();
  }
}


