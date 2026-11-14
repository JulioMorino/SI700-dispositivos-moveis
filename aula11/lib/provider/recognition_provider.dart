import 'dart:typed_data';

import '../recognition/similarity.dart';
import 'embedding_service.dart';
import 'reference_index_provider.dart';

/// Reconhece a rocha TODA no celular: modelo ONNX local + referências do Firestore.
///
/// Antes (v0.2) este provider mandava a foto por HTTP para um servidor Python no PC.
/// A assinatura e o formato da resposta continuaram iguais, por isso o BLoC e a tela
/// quase não mudaram: essa é a vantagem de isolar o acesso a dados no Provider.
class RecognitionProvider {
  static RecognitionProvider helper = RecognitionProvider._createInstance();
  RecognitionProvider._createInstance();

  /// Pré-carrega o modelo e a base (chamado ao abrir a tela, para a 1ª foto ser rápida).
  Future<void> prepare() async {
    await Future.wait([
      EmbeddingService.helper.load(),
      ReferenceIndexProvider.helper.load(),
    ]);
  }

  /// Devolve o mesmo formato do antigo servidor:
  /// {"status": "match", "name", "description", "lithology", "minerals", "score"}
  /// {"status": "no_match", "score"} | {"status": "not_rock", "rock_probability"}
  Future<Map<String, dynamic>> recognize(Uint8List bytes) async {
    final ReferenceIndex index = await ReferenceIndexProvider.helper.load();
    final Float32List query = await EmbeddingService.helper.embed(bytes);
    final RecognitionResult r = decide(query, index.rocks, index.config);

    switch (r.status) {
      case RecognitionStatus.notRock:
        return {"status": "not_rock", "rock_probability": r.rockProbability};
      case RecognitionStatus.noMatch:
        return {"status": "no_match", "score": r.score};
      case RecognitionStatus.match:
        return {
          "status": "match",
          "id": r.rock!.id,
          "name": r.rock!.name,
          "lithology": r.rock!.lithology,
          "minerals": r.rock!.minerals,
          "description": r.rock!.description,
          "score": r.score,
        };
    }
  }
}
