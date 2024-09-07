import 'package:flutter/material.dart';

class FeedbackScreen extends StatelessWidget {
  final Future<String?> futureResult;

  FeedbackScreen({super.key, required this.futureResult});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: futureResult,
      builder: (context, snapshot) {
        //verificando estado do snapshot e retornando widget apropriado
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasData) {
          if (snapshot.data == "success") {
            return successMessage();
          } else {
            return errorMessage(snapshot);
          }
        } else {
          return unknownErrorMessage();
        }
      },
    );
  }

  successMessage() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Dados submetidos com sucesso!',
            style: TextStyle(
                color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
          ),
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 80,
          ),
          SizedBox(
            height: 70,
          ),
          Text(
            '(Para sair, toque em qualquer lugar fora desta tela)',
            style: TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  errorMessage(snapshot) {
    return Center(
      child: Column(
        children: [
          Text(
            snapshot.data,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 70,
          ),
          Text(
            '(Para sair, toque em qualquer lugar fora desta tela)',
            style: TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  unknownErrorMessage() {
    return const Center(
      child: Column(
        children: [
          Text(
            'Um erro desconhecido ocorreu.',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Icon(
            Icons.error,
            color: Colors.red,
            size: 80,
          ),
          SizedBox(
            height: 70,
          ),
          Text(
            '(Para sair, toque em qualquer lugar fora desta tela)',
            style: TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
