import 'package:aula02_jogo_da_velha/model/jogo_da_velha.dart';
import 'package:aula02_jogo_da_velha/model/painel.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  JogoDaVelha jogo = JogoDaVelha();
  Painel painel_do_jogo = Painel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text('Jogo da Velha - ' + painel_do_jogo.apresentacao)),
      body: Center(
        child: GridView.count(
            crossAxisCount: 3,
            children: painel_do_jogo.construirConteudo(jogo)),
      ),
    );
  }
}
