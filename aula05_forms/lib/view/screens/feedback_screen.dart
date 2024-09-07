import 'package:flutter/material.dart';

class FeedbackScreen extends StatelessWidget {
  final Future<String?> futureResult;

  const FeedbackScreen({super.key, required this.futureResult});

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
    return Center(
      child: Column(
        children: [
          Text('Dados submetidos com sucesso!'),
          Icon(Icons.check_circle)
        ],
      ),
    );
  }

  errorMessage(snapshot) {
    return Center(
      child: Column(
        children: [
          Text(snapshot.data),
        ],
      ),
    );
  }

  unknownErrorMessage() {
    return Center(
      child: Column(
        children: [Text('Um erro desconhecido ocorreu.'), Icon(Icons.error)],
      ),
    );
  }
}
