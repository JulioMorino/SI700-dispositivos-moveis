import 'package:flutter/material.dart';

class PrimeiraTela extends StatefulWidget {
  const PrimeiraTela({Key? key}) : super(key: key);

  @override
  State<PrimeiraTela> createState() => _PrimeiraTelaState();
}

class _PrimeiraTelaState extends State<PrimeiraTela> {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffe14d39), Color(0xffe87a6c)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
                padding: EdgeInsets.all(15),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(width: 3),
                  ),
                  child: Image.network(
                    'https://raw.githubusercontent.com/JulioMorino/ComputacaoGrafica/main/texturas/01_gato_persa.webp',
                  ),
                )),
            Text(
              'Imagem retirada do repositorio de atividades da disciplina ST765 da Unicamp',
              style: TextStyle(color: Colors.white, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            Text(
              'Disponível em: ',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            Text(
              'https://github.com/JulioMorino/ComputacaoGrafica',
              style: TextStyle(color: Colors.white, fontSize: 15),
            )
          ],
        ));
  }
}
