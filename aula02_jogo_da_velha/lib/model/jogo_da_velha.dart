class JogoDaVelha {
  List<int> tabuleiro = [0, 0, 0, 0, 0, 0, 0, 0, 0];
// 1  =>  turno do X
//-1  =>  turno do O
  int turno_atual = -1;

  jogar(int posicao) {
    if (!verificaVencedor()) {
      if (tabuleiro[posicao] == 0) {
        tabuleiro[posicao] = turno_atual;
        turno_atual *= -1;
        return true;
      }
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

  verificaVencedor() {
    if (tabuleiro.every((valor) => valor == 0))
      return false; //ainda eh primeira rodada

    if (tabuleiro[0] == tabuleiro[1] &&
        tabuleiro[1] == tabuleiro[2] &&
        tabuleiro[0] != 0) return true;
    if (tabuleiro[3] == tabuleiro[4] &&
        tabuleiro[4] == tabuleiro[5] &&
        tabuleiro[3] != 0) return true;
    if (tabuleiro[6] == tabuleiro[7] &&
        tabuleiro[7] == tabuleiro[8] &&
        tabuleiro[6] != 0) return true;

    if (tabuleiro[0] == tabuleiro[3] &&
        tabuleiro[3] == tabuleiro[6] &&
        tabuleiro[0] != 0) return true;
    if (tabuleiro[1] == tabuleiro[4] &&
        tabuleiro[4] == tabuleiro[7] &&
        tabuleiro[1] != 0) return true;
    if (tabuleiro[2] == tabuleiro[5] &&
        tabuleiro[5] == tabuleiro[8] &&
        tabuleiro[2] != 0) return true;

    if (tabuleiro[0] == tabuleiro[4] &&
        tabuleiro[4] == tabuleiro[8] &&
        tabuleiro[0] != 0) return true;
    if (tabuleiro[2] == tabuleiro[4] &&
        tabuleiro[4] == tabuleiro[6] &&
        tabuleiro[2] != 0) return true;

    return false;
  }

  reiniciar() {
    tabuleiro.fillRange(0, tabuleiro.length, 0);
    turno_atual = -1;
  }
}
