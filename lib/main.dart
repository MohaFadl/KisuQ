import 'package:flutter/material.dart';
import 'package:flutter_flip_card/flutter_flip_card.dart';
import 'Home.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: StartingApp(),
  ));
}

class StartingApp extends StatefulWidget {
  const StartingApp({super.key});

  @override
  State<StartingApp> createState() => _StartingAppState();
}

class _StartingAppState extends State<StartingApp> {
  final flipo = FlipCardController();
  final flipo2 = FlipCardController();
  bool isFlipping = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff202020),
      body: FlipCard(
        animationDuration: Duration(milliseconds: 500),
        frontWidget: HomePage(),
        backWidget: Center(child: Text("Page Two")),
        controller: flipo2,
        rotateSide: RotateSide.top,
        onTapFlipping: false,
      ),
      floatingActionButton: FlipCard(
        controller: flipo,
        rotateSide: RotateSide.left,
        animationDuration: Duration(milliseconds: 500),
        onTapFlipping: false,
        frontWidget: FloatingActionButton(
          onPressed: () async {
            if (isFlipping) return;
            setState(() => isFlipping = true);
            flipo.flipcard();
            flipo2.flipcard();
            await Future.delayed(Duration(milliseconds: 500));
            setState(() => isFlipping = false);
          },
        ),
        backWidget: FloatingActionButton(
          onPressed: () async {
            if (isFlipping) return;
            setState(() => isFlipping = true);
            flipo.flipcard();
            flipo2.flipcard();
            await Future.delayed(Duration(milliseconds: 500));
            setState(() => isFlipping = false);
          },
          backgroundColor: Colors.red,
        ),
      ),
      floatingActionButtonLocation:
      FloatingActionButtonLocation.miniCenterFloat,
    );
  }
}


