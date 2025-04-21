import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flip_card/flutter_flip_card.dart';
import 'APIServices/GraphQLPain.dart';
import 'SearchPage/Home.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() async{
  await initHiveForFlutter();
  final client = initGraphQLClient();
  runApp(GraphQLProvider(
    client: client,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StartingApp(),
    ),
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
      body: FlutterSplashScreen.gif(
        gifPath: 'images/KitsuQSplash.gif',
        gifWidth: 269,
        gifHeight: 474,
        backgroundColor: Color(0xff202020),
        nextScreen: const Home(),
        duration: const Duration(milliseconds: 3000),
        onInit: () async {
          debugPrint("onInit");
        },
        onEnd: () async {
          debugPrint("onEnd 1");
        },
      )
    );
  }
}




