class JogoDaVelha{
  List<int> tabuleiro = [0,0,0,
                         0,0,0,
                         0,0,0];
// 1  =>  turno do X
//-1  =>  turno do O                         
  int turno_atual = -1;

  jogar(int posicao){
    if(tabuleiro[posicao] == 0){
      tabuleiro[posicao] = turno_atual;
    }
  }




}