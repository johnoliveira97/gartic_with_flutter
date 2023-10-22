import 'package:flutter/material.dart';
import 'package:gartic_with_flutter/screens/game.dart';

void main() {
  runApp(const GarticApp());
}

class GarticApp extends StatelessWidget {
  const GarticApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gartic - Flutter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const GameWidget(),
    );
  }
}
