import 'package:aula02_jogo_da_velha/model/jogo_da_velha.dart';
import 'package:aula02_jogo_da_velha/view/celula.dart';
import 'package:flutter/material.dart';

class Painel {
  String apresentacao = 'Turno de ';

  construirConteudo(jogo) {
    void algumaCelulaClicada() {
      apresentacao = 'Turno de ${jogo.obterVezDoJogador()}';
      print(apresentacao);
    }

    List<Widget> celulasTabuleiro = [];
    for (int i = 0; i < 9; i++) {
      celulasTabuleiro.add(Celula(
        jogo: jogo,
        posicao: i,
        algumaCelulaClicada: algumaCelulaClicada,
      ));
    }

    return celulasTabuleiro;
  }
}
