import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gartic_with_flutter/model/drawing_point.dart';
import 'package:gartic_with_flutter/model/game.dart';
import 'package:gartic_with_flutter/model/message.dart';
import 'package:gartic_with_flutter/screens/game.dart';

class DrawWidget extends StatefulWidget {
  const DrawWidget({super.key});

  @override
  State<DrawWidget> createState() => _DrawWidgetState();
}

class _DrawWidgetState extends State<DrawWidget> {
  static const platform = MethodChannel("game/exchange");

  var avaiableColors = [
    Colors.black,
    Colors.red,
    Colors.amber,
    Colors.blue,
    Colors.green,
    Colors.brown
  ];

  var randomWords = [
    "banana",
    "batata",
    "pato",
    "vassoura",
    "lua",
    "ruiva",
    "lápis"
  ];

  var historyDrawingPoints = <DrawingPoint>[];
  var drawingPoints = <DrawingPoint>[];

  var selectedColor = Colors.black;
  var selectedWidth = 2.0;

  Random random = Random();

  DrawingPoint? currentDrawingPoint;
  String? element = "";
  bool showText = true;
  bool showNewWordText = false;
  Game? game;
  bool? minhaVez;

  @override
  void initState() {
    super.initState();
    _configureMethodChannelCallback();
  }

  _configureMethodChannelCallback() {
    platform.setMethodCallHandler((call) async {
      print("Voltou para o flutter: $call");

      final action = call.method;
      final arguments = call.arguments.toString().replaceAll("\"", "");
      final splitted = arguments.split("|");

      if (action == "sendAction") {
        final message = Message(splitted[0], element!);

        if (message.user == (game!.creator ? 'p2' : 'p1')) {
          setState(() {
            minhaVez = true;
            element;
          });
        }
      }
    });
  }

  void generateWord() {
    print("isMounted: $mounted");
    if (mounted) {
      int randomIndex = random.nextInt(randomWords.length);
      element = randomWords[randomIndex];
      print("element: $element");

      if (mounted) {
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              showNewWordText = false;
            });
          }
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Adicione o 'if' aqui
          if (showNewWordText)
            Center(
              child: AnimatedOpacity(
                duration: const Duration(seconds: 5),
                opacity: showText ? 1.0 : 0.0,
                child: Text(
                  element ?? "batata",
                  style: const TextStyle(fontSize: 20, color: Colors.black),
                ),
              ),
            ),

          GestureDetector(
            onPanStart: (details) {
              setState(() {
                currentDrawingPoint = DrawingPoint(
                    id: DateTime.now().microsecondsSinceEpoch,
                    offsets: [
                      details.localPosition,
                    ],
                    color: selectedColor,
                    width: selectedWidth);

                if (currentDrawingPoint == null) return;
                drawingPoints.add(currentDrawingPoint!);
                historyDrawingPoints = List.of(drawingPoints);
              });
            },
            onPanUpdate: (details) {
              setState(() {
                if (currentDrawingPoint == null) return;

                currentDrawingPoint = currentDrawingPoint?.copyWith(
                  offsets: currentDrawingPoint!.offsets
                    ..add(details.localPosition),
                );
                drawingPoints.last = currentDrawingPoint!;
                historyDrawingPoints = List.of(drawingPoints);
              });
            },
            onPanEnd: (_) {
              currentDrawingPoint = null;
            },
            child: CustomPaint(
              painter: DrawingPainter(
                drawingPoints: drawingPoints,
              ),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ),
            ),
          ),

          /// color pallet
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 16,
            right: 16,
            child: SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: avaiableColors.length,
                separatorBuilder: (_, __) {
                  return const SizedBox(width: 8);
                },
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedColor = avaiableColors[index];
                      });
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: avaiableColors[index],
                        shape: BoxShape.circle,
                      ),
                      foregroundDecoration: BoxDecoration(
                        border: selectedColor == avaiableColors[index]
                            ? Border.all(color: Color(0xFF1C3E66), width: 4)
                            : null,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          Positioned(
            top: 40,
            right: -3,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  print("Apertou o botão");
                  showText = true;
                  showNewWordText = true;
                  generateWord();
                });
              },
              child: const Text('Gerar Palavra'),
            ),
          ),

          /// pencil size
          Positioned(
            top: MediaQuery.of(context).padding.top + 80,
            right: 0,
            bottom: 150,
            child: RotatedBox(
              quarterTurns: 3, // 270 degree
              child: Slider(
                value: selectedWidth,
                min: 1,
                max: 20,
                onChanged: (value) {
                  setState(() {
                    selectedWidth = value;
                  });
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "Undo",
            onPressed: () {
              if (drawingPoints.isNotEmpty && historyDrawingPoints.isNotEmpty) {
                setState(() {
                  drawingPoints.removeLast();
                });
              }
            },
            child: const Icon(Icons.undo),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: "Redo",
            onPressed: () {
              setState(() {
                if (drawingPoints.length < historyDrawingPoints.length) {
                  // 6 length 7
                  final index = drawingPoints.length;
                  drawingPoints.add(historyDrawingPoints[index]);
                }
              });
            },
            child: const Icon(Icons.redo),
          ),
        ],
      ),
    );
  }

  Future<bool> _sendAction(
      String action, Map<String, dynamic> arguments) async {
    try {
      final result = await platform.invokeMethod(action, arguments);
      if (result) {
        return true;
      }
    } on PlatformException catch (e) {
      print("Ocorreu erro ao enviar ação para o nativo: $e");
    }

    return false;
  }
}
