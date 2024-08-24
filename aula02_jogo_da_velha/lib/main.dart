import 'dart:ffi';
import 'package:aula02_jogo_da_velha/model/jogo_da_velha.dart';
import 'package:aula02_jogo_da_velha/view/celula.dart';
import 'package:flutter/material.dart';

void main() {
  JogoDaVelha jogo = JogoDaVelha();

  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: Text('Jogo da Velha')),
      body: Center(
        child: GridView.count(
            crossAxisCount: 3, children: construirConteudo(jogo)),
      ),
    ),
  ));
}

construirConteudo(jogo) {
  List<Widget> celulasTabuleiro = [];
  for (int i = 0; i < 9; i++) {
    celulasTabuleiro.add(Celula(
      jogo: jogo,
      posicao: i,
    ));
  }

  return celulasTabuleiro;
}
