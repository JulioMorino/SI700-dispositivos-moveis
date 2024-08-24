import 'package:aula02_jogo_da_velha/model/jogo_da_velha.dart';
import 'package:flutter/material.dart';

class Celula extends StatefulWidget {
  final JogoDaVelha jogo;
  final int posicao;

  const Celula({
    super.key,
    required this.jogo,
    required this.posicao,
  });

  @override
  State<Celula> createState() => _CelulaState();
}

class _CelulaState extends State<Celula> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _fazerJogada();
      },
      child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(border: Border.all(color: Colors.blue)),
          child: _buildContent()),
    );
  }

  Widget _buildContent() {
    return Center(
      child: Text(widget.jogo.obterEstadoPosicao(widget.posicao)),
    );
  }

  _fazerJogada() {
    if (widget.jogo.jogar(widget.posicao)) {
      setState(() {});
    }
  }
}
