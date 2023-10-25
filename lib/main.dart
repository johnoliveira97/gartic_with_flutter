import 'package:flutter/material.dart';
import 'package:gartic_with_flutter/screens/draw.dart';
import 'package:gartic_with_flutter/screens/game.dart';
import 'package:gartic_with_flutter/screens/sucesso.dart';

void main() {
  runApp(const GarticApp());
}

class GarticApp extends StatelessWidget {
  const GarticApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter - Gartic',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/success': (context) => const SucessoWidget(),
        '/': (context) => const GameWidget(),
        '/draw': (context) => const DrawWidget(),
      },
    );
  }
}
