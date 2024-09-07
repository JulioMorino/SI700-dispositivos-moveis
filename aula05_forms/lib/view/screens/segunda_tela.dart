import 'package:flutter/material.dart';

class SegundaTela extends StatefulWidget {
  const SegundaTela({Key? key}) : super(key: key);

  @override
  State<SegundaTela> createState() => _SegundaTelaState();
}

class _SegundaTelaState extends State<SegundaTela> {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff95c5ec), Colors.blue],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 120,
              backgroundImage: NetworkImage(
                  'https://raw.githubusercontent.com/ulissesdias/si700/main/e_forms_intro/assets/images/ulisses.gif'),
            ),
            Text(
              'Professor Ulisses Dias',
              style: TextStyle(color: Colors.white, fontSize: 25),
            )
          ],
        ));
  }
}
