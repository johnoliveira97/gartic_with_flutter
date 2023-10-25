import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gartic_with_flutter/model/drawing_point.dart';

class GameWidget extends StatefulWidget {
  const GameWidget({super.key});

  @override
  State<GameWidget> createState() => _GameWidgetState();
}

class _GameWidgetState extends State<GameWidget> {
  static const platform = MethodChannel("game/exchange");
  bool showText = true;

  @override
  void initState() {
    super.initState();
  }

  Widget _buildButton(String label, bool isCreator) => SizedBox(
        width: 300,
        child: OutlinedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blueGrey[100]),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            child: Padding(
                padding: EdgeInsets.all(8),
                child: Text(label,
                    style: TextStyle(fontSize: 16, color: Colors.black))),
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
                        goToNextRoute(context, '/draw');
                      });
                      goToNextRoute(context, '/draw');
                    }
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
    var text = "Flutter - Adivinhação";
    return Scaffold(
      appBar: AppBar(
        title: Text(text),
        backgroundColor: Colors.blueGrey[100],
      ),
      backgroundColor: const Color.fromRGBO(150, 240, 238, 1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/home.jpeg',
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: _buildButton('Clique para iniciar', true),
            )
          ],
        ),
      ),
    );
  }

  goToNextRoute(BuildContext context, String route) {
    return Navigator.pushNamed(context, route);
  }
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
