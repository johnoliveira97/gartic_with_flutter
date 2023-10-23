import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gartic_with_flutter/model/drawing_point.dart';
import 'package:gartic_with_flutter/model/game.dart';

class GameWidget extends StatefulWidget {
  const GameWidget({super.key});

  @override
  State<GameWidget> createState() => _GameWidgetState();
}

class _GameWidgetState extends State<GameWidget> {
  static const platform = MethodChannel("game/exchange");
  bool showText = true;
  Game? game;
  bool? minhaVez;

  @override
  void initState() {
    super.initState();
  }

  Widget _buildButton(String label, bool isCreator) => SizedBox(
        width: 300,
        child: OutlinedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.white),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            child: Padding(
                padding: EdgeInsets.all(8),
                child: Text(label,
                    style: TextStyle(fontSize: 36, color: Colors.black))),
            onPressed: () {
              _createGame(isCreator);
            }),
      );

  Future _createGame(bool isCreator) {
    final editingController = TextEditingController();
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text("Qual o nome do jogo?"),
            content: TextField(
              controller: editingController,
            ),
            actions: [
              ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    final result = await _sendAction(
                        "subscribe", {"channel": editingController.text});
                    if (result) {
                      setState(() {
                        game = Game(editingController.text, isCreator);
                        minhaVez = isCreator;
                      });
                    }
                    goToNextRoute(context, '/draw');
                  },
                  child: const Text("Jogar")),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancelar"))
            ],
          );
        });
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

  @override
  Widget build(BuildContext context) {
    var text = "Flutter - Gartic";
    return Scaffold(
      backgroundColor: Colors.blue,
      body: SingleChildScrollView(
          child: Stack(
        children: [
          SizedBox(
              height: 1000,
              width: 700,
              child: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                    Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              text,
                              style: const TextStyle(
                                  fontSize: 30, color: Colors.yellow),
                            )
                          ]),
                    ),
                    const SizedBox(height: 300),
                    (game == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                _buildButton("Criar", true),
                                const SizedBox(height: 10),
                                _buildButton("Entrar", false),
                              ])
                        : InkWell(
                            child: Text(
                            minhaVez == true
                                ? "Sua vez de desenhar!!"
                                : "Aguarde sua vez de desenhar!!",
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          )))
                  ]))),
        ],
      )),
    );
  }

  goToNextRoute(BuildContext context, String route) {
    return Navigator.pushNamed(context, route);
  }
}

Widget _buildGameScaffold() {
  return Scaffold();
}

Widget _buildWelcomeScaffold() {
  return Scaffold(
    backgroundColor: Colors.blue,
    body: SingleChildScrollView(),
  );
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint> drawingPoints;

  DrawingPainter({required this.drawingPoints});

  @override
  void paint(Canvas canvas, Size size) {
    for (var drawingPoint in drawingPoints) {
      final paint = Paint()
        ..color = drawingPoint.color
        ..isAntiAlias = true
        ..strokeWidth = drawingPoint.width
        ..strokeCap = StrokeCap.round;

      for (var i = 0; i < drawingPoint.offsets.length; i++) {
        var notLastOffset = i != drawingPoint.offsets.length - 1;

        if (notLastOffset) {
          final current = drawingPoint.offsets[i];
          final next = drawingPoint.offsets[i + 1];
          canvas.drawLine(current, next, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
