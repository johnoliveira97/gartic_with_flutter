import 'package:flutter/material.dart';
import 'package:gartic_with_flutter/screens/draw.dart';
import 'package:gartic_with_flutter/screens/game.dart';
import 'package:gartic_with_flutter/screens/alert-page.dart';

void main() {
  runApp(const GarticApp());
}

class GarticApp extends StatelessWidget {
  const GarticApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter - Adivinhação',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/success': (context) => AlertPageWidget(
            titulo: 'Palavra correta', imagem: 'images/5SM.gif'),
        '/error': (context) => AlertPageWidget(
            titulo: 'Palavra incorreta', imagem: 'images/boy.gif'),
        '/': (context) => const GameWidget(),
        '/draw': (context) => const DrawWidget(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
