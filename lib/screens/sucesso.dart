import 'package:flutter/material.dart';

class SucessoWidget extends StatefulWidget {
  const SucessoWidget({super.key});

  @override
  State<SucessoWidget> createState() => _SucessoWidgetState();
}

class _SucessoWidgetState extends State<SucessoWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: AlertDialog(
      title: Text('Palavra correto!'),
      content: Image.asset(
        'images/5SM.gif',
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
