import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../recognition/similarity.dart';
import 'embedding_service.dart';

/// Rochas de referência + configuração, lidas do Firestore (enviadas por ml/upload_firestore.py).
class ReferenceIndex {
  final RecognitionConfig config;
  final List<RockReference> rocks;
  ReferenceIndex(this.config, this.rocks);
}

/// Erro com uma mensagem pronta para mostrar ao usuário.
class RecognitionException implements Exception {
  final String message;
  RecognitionException(this.message);
  @override
  String toString() => message;
}

class ReferenceIndexProvider {
  static ReferenceIndexProvider helper = ReferenceIndexProvider._createInstance();
  ReferenceIndexProvider._createInstance();

  final CollectionReference rockCollection =
      FirebaseFirestore.instance.collection("rocks");
  final DocumentReference configDoc =
      FirebaseFirestore.instance.collection("recognition_config").doc("current");

  ReferenceIndex? _cache;

  /// Carrega uma vez e guarda em memória. Custa ~(número de rochas + 1) leituras no Firestore.
  /// Sem internet, o Firestore usa o cache offline (se o app já abriu online antes).
  Future<ReferenceIndex> load({bool forceRefresh = false}) async {
    if (_cache != null && !forceRefresh) return _cache!;

    final DocumentSnapshot cfgSnap = await configDoc.get();
    if (!cfgSnap.exists) {
      throw RecognitionException(
          "A base de rochas ainda não foi publicada no Firestore.");
    }
    final config = RecognitionConfig.fromMap(cfgSnap.data() as Map<String, dynamic>);

    // O índice tem que ter sido gerado com o MESMO modelo que está no app.
    if (config.modelVersion != EmbeddingService.modelVersion) {
      throw RecognitionException(
          "A base de rochas é de outra versão do modelo. Atualize o app.");
    }

    final QuerySnapshot rocksSnap = await rockCollection.get();
    final rocks = <RockReference>[];
    for (final doc in rocksSnap.docs) {
      final rock = RockReference.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      if (rock.modelVersion == config.modelVersion) {
        rocks.add(rock);
      } else {
        debugPrint("Rocha ${doc.id} ignorada: modelVersion ${rock.modelVersion}");
      }
    }
    if (rocks.isEmpty) {
      throw RecognitionException("Nenhuma rocha cadastrada na base.");
    }

    _cache = ReferenceIndex(config, rocks);
    return _cache!;
  }
}
