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
  int contaTurnos = 0;

  void atualizarEstado() {
    setState(() {
      contaTurnos++;

      turnoAtual = 'Turno de ${jogo.obterVezDoJogador()}';
      if (jogo.verificaVencedor()) {
        jogo.turno_atual *= -1; //pois a vitoria foi na jogada anterior
        vencedor = jogo.obterVezDoJogador();
        criarReinicio();
      } else if (contaTurnos == 9 && vencedor == '') {
        criarReinicio(); //deu velha
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Jogo da Velha - $turnoAtual',
            style: TextStyle(color: Colors.white, fontSize: 30),
          ),
          backgroundColor: Color.fromARGB(255, 41, 82, 245),
        ),
        body: Center(
          child: GridView.count(
              crossAxisCount: 3, children: construirConteudo(jogo)),
        ),
        bottomNavigationBar: Container(
            height: 220,
            color: Color.fromARGB(255, 41, 82, 245),
            child: criarReinicio()));
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
    if (contaTurnos == 9 || jogo.verificaVencedor()) {
      return Container(
          height: 200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    vencedor.isEmpty ? 'Deu velha!' : 'Vencedor: $vencedor',
                    style: TextStyle(fontSize: 30, color: Colors.white),
                  )),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    jogo.reiniciar();
                    contaTurnos = 0;
                    turnoAtual = 'Turno de ${jogo.obterVezDoJogador()}';
                    vencedor = '';
                  });
                },
                child: Text('Reiniciar Partida'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Color.fromARGB(255, 21, 67, 253),
                  backgroundColor: Colors.white,
                  textStyle:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  padding: EdgeInsets.all(25),
                ),
              ),
            ],
          ));
    }

    return Container(
      height: 50,
    );
  }
}
