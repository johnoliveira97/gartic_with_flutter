import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gartic_with_flutter/model/drawing_point.dart';
import 'package:gartic_with_flutter/screens/game.dart';

class DrawWidget extends StatefulWidget {
  const DrawWidget({super.key});

  @override
  State<DrawWidget> createState() => _DrawWidgetState();
}

class _DrawWidgetState extends State<DrawWidget> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
    "mar",
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
  bool canDraw = false;
  bool isGuessing = false;
  int count = 5;
  int countToGuess = 30;
  late Timer timer;

  @override
  void initState() {
    super.initState();
  }

  void generateWord() {
    if (mounted) {
      int randomIndex = random.nextInt(randomWords.length);
      element = randomWords[randomIndex];

      if (mounted) {
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              showNewWordText = false;
            });
          }
        });

        startCountDown();
        timeToGuess();
      }
    }
  }

  void timeToGuess() {
    countToGuess = 10;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (count == 0 && countToGuess > 0) {
          countToGuess--;
        } else if (countToGuess == 0) {
          isGuessing = true;
          timer.cancel();
        }
      });
    });
  }

  void startCountDown() {
    count = 5;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (count > 0) {
          count--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (showNewWordText && count >= 0)
            Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  Text(
                    'Prepare-se: $count segundos para começar!',
                    style: const TextStyle(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                  AnimatedOpacity(
                    duration: const Duration(seconds: 5),
                    opacity: showText ? 1.0 : 0.0,
                    child: Text(
                      "Desenhe a palavra: $element",
                      style: const TextStyle(fontSize: 24, color: Colors.black),
                    ),
                  ),
                ])),

          GestureDetector(
            onPanStart: (details) {
              if (count == 0 && !isGuessing) {
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
              }
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
                            ? Border.all(
                                color: const Color(0xFF1C3E66), width: 4)
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
                  drawingPoints.clear();
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
          if (isGuessing)
            SizedBox(
              width: 200,
              child: Center(
                child: Card(
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                        key: formKey,
                        child: TextFormField(
                            decoration: const InputDecoration(
                              hintText: 'Digite sua resposta',
                              labelText: 'Resposta: ',
                            ),
                            onFieldSubmitted: (String? text) async {
                              if (text.toString().toLowerCase() ==
                                  element.toString().toLowerCase()) {
                                Navigator.pushNamed(context, '/success');
                              } else {
                                Navigator.pushNamed(context, '/error');
                              }
                            })),
                  ),
                ),
              ),
            ),
          if (!isGuessing)
            FloatingActionButton(
              heroTag: "Undo",
              onPressed: () {
                if (drawingPoints.isNotEmpty &&
                    historyDrawingPoints.isNotEmpty) {
                  setState(() {
                    drawingPoints.removeLast();
                  });
                }
              },
              child: const Icon(Icons.undo),
            ),
          const SizedBox(width: 16),
          if (!isGuessing)
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
}
