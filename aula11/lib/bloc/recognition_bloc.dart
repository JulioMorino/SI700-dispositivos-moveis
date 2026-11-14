import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../provider/recognition_provider.dart';
import '../provider/reference_index_provider.dart';

class RecognitionBloc extends Bloc<RecognitionEvent, RecognitionState> {
  RecognitionBloc() : super(RecognitionIdle()) {
    on<RecognizeRequest>((event, emit) async {
      // Mostra a foto na moldura já com o "carregando" por cima.
      emit(Recognizing(imageBytes: event.imageBytes));

      try {
        Map<String, dynamic> result =
            await RecognitionProvider.helper.recognize(event.imageBytes);

        switch (result["status"]) {
          case "match":
            emit(Recognized(
              imageBytes: event.imageBytes,
              name: result["name"] ?? "",
              lithology: result["lithology"] ?? "",
              description: result["description"] ?? "",
              minerals: List<String>.from(result["minerals"] ?? []),
              score: (result["score"] as num?)?.toDouble() ?? 0,
            ));
            break;
          case "not_rock":
            emit(NotRecognized(
              imageBytes: event.imageBytes,
              message:
                  "Não parece uma rocha. Tente fotografar o afloramento mais de perto.",
            ));
            break;
          default:
            emit(NotRecognized(
              imageBytes: event.imageBytes,
              message:
                  "Não foi possível encontrar registros desta rocha. Tente tirar uma foto melhor.",
            ));
        }
      } on RecognitionException catch (e) {
        // Erros "esperados", com mensagem pronta (ex.: base não publicada).
        emit(RecognitionError(imageBytes: event.imageBytes, message: e.message));
      } on FirebaseException catch (e) {
        debugPrint("Firestore: ${e.code} ${e.message}");
        emit(RecognitionError(
          imageBytes: event.imageBytes,
          message: e.code == "permission-denied"
              ? "Sem permissão para ler a base de rochas. Faça login novamente."
              : "Não foi possível carregar a base de rochas. Verifique a internet.",
        ));
      } catch (e) {
        debugPrint("Erro no reconhecimento: $e");
        emit(RecognitionError(
          imageBytes: event.imageBytes,
          message: "Não foi possível analisar a foto. Tente novamente.",
        ));
      }
    });

    on<ResetRecognition>((event, emit) => emit(RecognitionIdle()));

    // Carrega modelo e base em segundo plano ao abrir a tela. Erros aqui são
    // silenciosos: se falhar, o RecognizeRequest tenta de novo e mostra a mensagem.
    on<PrepareRecognition>((event, emit) async {
      try {
        await RecognitionProvider.helper.prepare();
      } catch (e) {
        debugPrint("Pré-carregamento falhou: $e");
      }
    });
  }
}

/*
 Eventos
*/
abstract class RecognitionEvent {}

class RecognizeRequest extends RecognitionEvent {
  final Uint8List imageBytes;
  RecognizeRequest({required this.imageBytes});
}

class ResetRecognition extends RecognitionEvent {}

class PrepareRecognition extends RecognitionEvent {}

/*
 Estados
*/
abstract class RecognitionState {}

class RecognitionIdle extends RecognitionState {}

/// Estados que já têm uma foto para mostrar na moldura.
abstract class RecognitionWithImage extends RecognitionState {
  final Uint8List imageBytes;
  RecognitionWithImage({required this.imageBytes});
}

class Recognizing extends RecognitionWithImage {
  Recognizing({required super.imageBytes});
}

class Recognized extends RecognitionWithImage {
  final String name;
  final String lithology;
  final String description;
  final List<String> minerals;
  final double score;

  Recognized({
    required super.imageBytes,
    required this.name,
    required this.lithology,
    required this.description,
    required this.minerals,
    required this.score,
  });
}

class NotRecognized extends RecognitionWithImage {
  final String message;
  NotRecognized({required super.imageBytes, required this.message});
}

class RecognitionError extends RecognitionWithImage {
  final String message;
  RecognitionError({required super.imageBytes, required this.message});
}
