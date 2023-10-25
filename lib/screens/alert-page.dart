import 'package:flutter/material.dart';

class AlertPageWidget extends StatefulWidget {
  final String titulo;
  final String imagem;
  AlertPageWidget({super.key, required this.titulo, required this.imagem});

  @override
  State<AlertPageWidget> createState() => _AlertPageWidgetState();
}

class _AlertPageWidgetState extends State<AlertPageWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: AlertDialog(
          title: Text(widget.titulo),
          content: Image.asset(
            widget.imagem,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/draw'),
              child: const Text('Continuar'),
            ),
          ],
        ));
  }
}
