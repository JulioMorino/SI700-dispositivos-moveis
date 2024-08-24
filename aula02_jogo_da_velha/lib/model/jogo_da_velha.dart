class JogoDaVelha {
  List<int> tabuleiro = [0, 0, 0, 0, 0, 0, 0, 0, 0];
// 1  =>  turno do X
//-1  =>  turno do O
  int turno_atual = -1;

  jogar(int posicao) {
    if (tabuleiro[posicao] == 0) {
      tabuleiro[posicao] = turno_atual;
      turno_atual *= -1;
      return true;
    }
    return false;
  }

  obterEstadoPosicao(int posicao) {
    switch (tabuleiro[posicao]) {
      case 0:
        return ' ';

      case 1:
        return 'X';

      case -1:
        return 'O';
    }
  }

  obterVezDoJogador() {
    switch (turno_atual) {
      case 1:
        return 'X';

      case -1:
        return 'O';
    }
  }
}
