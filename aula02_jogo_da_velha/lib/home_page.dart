import 'package:aula02_jogo_da_velha/model/jogo_da_velha.dart';
import 'package:aula02_jogo_da_velha/view/celula.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  JogoDaVelha jogo = JogoDaVelha();
  String turnoAtual = 'Turno de O';
  String vencedor = '';

  void atualizarEstado() {
    setState(() {
      turnoAtual = 'Turno de ${jogo.obterVezDoJogador()}';
      if (jogo.verificaVencedor()) {
        print(jogo.verificaVencedor());
        jogo.turno_atual *= -1; //pois a vitoria foi na jogada anterior
        vencedor = jogo.obterVezDoJogador();
        criarReinicio();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Jogo da Velha - $turnoAtual')),
        body: Center(
          child: GridView.count(
              crossAxisCount: 3, children: construirConteudo(jogo)),
        ),
        bottomNavigationBar: criarReinicio());
  }

  construirConteudo(jogo) {
    List<Widget> celulasTabuleiro = [];
    for (int i = 0; i < 9; i++) {
      celulasTabuleiro.add(Celula(
        jogo: jogo,
        posicao: i,
        algumaCelulaClicada: atualizarEstado,
      ));
    }

    return celulasTabuleiro;
  }

  Widget criarReinicio() {
    if (jogo.verificaVencedor()) {
      return Container(
          height: 200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    vencedor.isEmpty ? '' : 'Vencedor: $vencedor',
                    style: TextStyle(fontSize: 30),
                  )),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    jogo.reiniciar();
                    print(jogo.tabuleiro[4]);
                  });
                },
                child: Text('Reiniciar Partida'),
              ),
            ],
          ));
    } else
      return Container(
        height: 50,
      );
  }
}
